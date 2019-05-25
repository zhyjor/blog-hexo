---
title: SSR探索与实践之二：vue服务端渲染基础
tags:
  - SSR探索与实践
  - ssr
categories: ssr
top: false
copyright: true
date: 2018-08-07 13:48:05
---
与传统的spa相比，服务器端渲染可以有更好的seo,更快的内容到达时间（time to content）。但是服务器端渲染并不是必须的，是否使用，需要细细斟酌。本文是一个完整的服务器渲染的实现，结合一个例子实现。同时假如是仅仅几个静态页面，完全可以使用预渲染实现，没必要完全使用服务器实时动态编译html.

本文主要是参考[vue-ssr官方指南](https://ssr.vuejs.org/zh/)，对其中的一些关键点的总结。
<!--more-->

## 基本用法
### vue-server-renderer
vue-server-renderer 和 vue 必须匹配版本。**vue-server-renderer 依赖一些 Node.js 原生模块，因此只能在 Node.js 中使用。**
### 使用页面模板
可以直接在创建 renderer 时提供一个页面模板。多数时候，我们会将页面模板放在特有的文件中，例如 index.template.html：
```html
<!DOCTYPE html>
<html lang="en">
  <head><title>Hello</title></head>
  <body>
    <!--vue-ssr-outlet-->
  </body>
</html>
```
我们可以读取和传输文件到 Vue renderer 中：

```js
const renderer = createRenderer({
  template: require('fs').readFileSync('./index.template.html', 'utf-8')
})

renderer.renderToString(app, (err, html) => {
  console.log(html) // html 将是注入应用程序内容的完整页面
})
```

模板还可以进行简单的插值,我们可以通过传入一个"渲染上下文对象"，作为 renderToString 函数的第二个参数，来提供插值数据：
```js
const context = {
  title: 'hello',
  meta: `
    <meta ...>
    <meta ...>
  `
}

renderer.renderToString(app, context, (err, html) => {
  // 页面 title 将会是 "Hello"
  // meta 标签也会注入
})
```

### 避免状态单例
我们为每个请求创建一个新的根 Vue 实例。这与每个用户在自己的浏览器中使用新应用程序的实例类似。如果我们在多个请求之间使用一个共享的实例，很容易导致交叉请求状态污染(cross-request state pollution)。

因此，我们不应该直接创建一个应用程序实例，而是应该暴露一个可以重复执行的工厂函数，为每个请求创建新的应用程序实例：
```js
// app.js
const Vue = require('vue')

module.exports = function createApp (context) {
  return new Vue({
    data: {
      url: context.url
    },
    template: `<div>访问的 URL 是： {{ url }}</div>`
  })
}
```

**同样的规则也适用于 router、store 和 event bus 实例。你不应该直接从模块导出并将其导入到应用程序中，而是需要在 createApp 中创建一个新的实例，并从根 Vue 实例注入。**

> 在使用带有 { runInNewContext: true } 的 bundle renderer 时，可以消除此约束，但是由于需要为每个请求创建一个新的 vm 上下文，因此伴随有一些显著性能开销。

### 使用webpack构建
我们需要使用 webpack 来打包我们的 Vue 应用程序。事实上，我们可能需要在服务器上使用 webpack 打包 Vue 应用程序，因为：
* **通常 Vue 应用程序是由 webpack 和 vue-loader 构建，并且许多 webpack 特定功能不能直接在 Node.js 中运行（例如通过 file-loader 导入文件，通过 css-loader 导入 CSS）。**
* 尽管 Node.js 最新版本能够完全支持 ES2015 特性，我们还是需要转译客户端代码以适应老版浏览器。这也会涉及到构建步骤。

所以基本看法是，对于客户端应用程序和服务器应用程序，我们都要使用 webpack 打包 - 服务器需要「服务器 bundle」然后用于服务器端渲染(SSR)，而「客户端 bundle」会发送给浏览器，用于混合静态标记。
![](http://static.zhyjor.com/201808071502_946.png)

上图是构建vue的过程，我们可以根据这些得出我们的大概的目录结构。大部分源码可以使用通用方式编写，可以使用 webpack 支持的所有功能。

```
src
├── components
│   ├── Foo.vue
│   ├── Bar.vue
│   └── Baz.vue
├── App.vue
├── app.js # 通用 entry(universal entry)
├── entry-client.js # 仅运行于浏览器
└── entry-server.js # 仅运行于服务器
```
#### app.js
app.js 是我们应用程序的「通用 entry」。在纯客户端应用程序中，我们将在此文件中创建根 Vue 实例，并直接挂载到 DOM。但是，对于服务器端渲染(SSR)，责任转移到纯客户端 entry 文件。app.js 简单地使用 export 导出一个 createApp 函数：
```js
import Vue from 'vue'
import App from './App.vue'

// 导出一个工厂函数，用于创建新的
// 应用程序、router 和 store 实例
export function createApp () {
  const app = new Vue({
    // 根实例简单的渲染应用程序组件。
    render: h => h(App)
  })
  return { app }
}
```
#### entry-client.js:
客户端 entry 只需创建应用程序，并且将其挂载到 DOM 中：
```js
import { createApp } from './app'

// 客户端特定引导逻辑……

const { app } = createApp()

// 这里假定 App.vue 模板中根元素具有 `id="app"`
app.$mount('#app')
```
#### entry-server.js:
**服务器 entry 使用 default export 导出函数，并在每次渲染中重复调用此函数。**此时，除了创建和返回应用程序实例之外，它不会做太多事情 - 但是稍后我们将在此执行服务器端路由匹配(server-side route matching)和数据预取逻辑(data pre-fetching logic)。
```js
import { createApp } from './app'

export default context => {
  const { app } = createApp()
  return app
}
```

### 路由代码写法

你可能已经注意到，我们的服务器代码使用了一个 * 处理程序，它接受任意 URL。这允许我们将访问的 URL 传递到我们的 Vue 应用程序中，然后对客户端和服务器复用相同的路由配置！

为此，建议使用官方提供的 vue-router。我们首先创建一个文件，在其中创建 router。注意，类似于 createApp，我们也需要给每个请求一个新的 router 实例，所以文件导出一个 createRouter 函数：
```js
// router.js
import Vue from 'vue'
import Router from 'vue-router'

Vue.use(Router)

export function createRouter () {
  return new Router({
    mode: 'history',
    routes: [
      // ...
    ]
  })
}
```
这个是需要在app.js中加上router相关的内容。在createApp()函数中，创建router实例，并将router注入到根vue中。

对于entry-server.js，我们需要实现服务器端路由逻辑（server-side routing logic）:

### 数据预取和状态
在服务器端渲染(SSR)期间，我们本质上是在渲染我们应用程序的"快照"，**所以如果应用程序依赖于一些异步数据，那么在开始渲染过程之前，需要先预取和解析好这些数据。**

**另一个需要关注的问题是在客户端，在挂载(mount)到客户端应用程序之前，需要获取到与服务器端应用程序完全相同的数据 - 否则，客户端应用程序会因为使用与服务器端应用程序不同的状态，然后导致混合失败。**这里是为什么会错误呢？其实跟最新的写法有关

因此获取数据需位于视图组件之外，即放置在专门的数据预取存储容器(data store)或"状态容器(state container)）"中。
* 首先，在服务器端，我们可以在渲染之前预取数据，并将数据填充到 store 中。
* 此外，我们将在 HTML 中序列化(serialize)和内联预置(inline)状态。这样，在挂载(mount)到客户端应用程序之前，可以直接从 store 获取到内联预置(inline)状态。


#### 带有逻辑配置的组件(Logic Collocation with Components)
**那么，我们在哪里放置「dispatch 数据预取 action」的代码？**

我们需要通过访问路由，来决定获取哪部分数据 - 这也决定了哪些组件需要渲染。事实上，给定路由所需的数据，也是在该路由上渲染组件时所需的数据。所以在路由组件中放置数据预取逻辑，是很自然的事情。

我们将在路由组件上暴露出一个自定义静态函数 asyncData。**注意，由于此函数会在组件实例化之前调用，所以它无法访问 this。需要将 store 和路由信息作为参数传递进去：**

```js
<!-- Item.vue -->
<template>
  <div>{{ item.title }}</div>
</template>

<script>
export default {
  asyncData ({ store, route }) {
    // 触发 action 后，会返回 Promise
    return store.dispatch('fetchItem', route.params.id)
  },
  computed: {
    // 从 store 的 state 对象中的获取 item。
    item () {
      return this.$store.state.items[this.$route.params.id]
    }
  }
}
</script>
```

#### 服务器端数据预取(Server Data Fetching)
在 entry-server.js 中，我们可以通过路由获得与 router.getMatchedComponents() 相匹配的组件，如果组件暴露出 asyncData，我们就调用这个方法。然后我们需要将解析完成的状态，附加到渲染上下文(render context)中。
```js
// 对所有匹配的路由组件调用 `asyncData()`
Promise.all(matchedComponents.map(Component => {
if (Component.asyncData) {
  return Component.asyncData({
    store,
    route: router.currentRoute
  })
}
})).then(() => {
// 在所有预取钩子(preFetch hook) resolve 后，
// 我们的 store 现在已经填充入渲染应用程序所需的状态。
// 当我们将状态附加到上下文，
// 并且 `template` 选项用于 renderer 时，
// 状态将自动序列化为 `window.__INITIAL_STATE__`，并注入 HTML。
context.state = store.state

resolve(app)
}).catch(reject)
```

#### 客户端数据预取(Client Data Fetching)
在客户端，处理数据预取有两种不同方式：
##### 在路由导航之前解析数据：
使用此策略，应用程序会等待视图所需数据全部解析之后，再传入数据并处理当前视图。好处在于，可以直接在数据准备就绪时，传入视图渲染完整内容，但是如果数据预取需要很长时间，用户在当前视图会感受到"明显卡顿"。因此，如果使用此策略，建议提供一个数据加载指示器(data loading indicator)。

我们可以通过检查匹配的组件，并在全局路由钩子函数中执行 asyncData 函数，来在客户端实现此策略。注意，在初始路由准备就绪之后，我们应该注册此钩子，这样我们就不必再次获取服务器提取的数据。

##### 匹配要渲染的视图后，再获取数据：
此策略将客户端数据预取逻辑，放在视图组件的 beforeMount 函数中。当路由导航被触发时，可以立即切换视图，因此应用程序具有更快的响应速度。然而，传入视图在渲染时不会有完整的可用数据。因此，对于使用此策略的每个视图组件，都需要具有条件加载状态。

这两种策略是根本上不同的用户体验决策，应该根据你创建的应用程序的实际使用场景进行挑选。**但是无论你选择哪种策略，当路由组件重用（同一路由，但是 params 或 query 已更改，例如，从 user/1 到 user/2）时，也应该调用 asyncData 函数。**我们也可以通过纯客户端(client-only)的全局 mixin 来处理这个问题：
```js
Vue.mixin({
  beforeRouteUpdate (to, from, next) {
    const { asyncData } = this.$options
    if (asyncData) {
      asyncData({
        store: this.$store,
        route: to
      }).then(next).catch(next)
    } else {
      next()
    }
  }
})
```

## 客户端激活
所谓客户端激活，指的是 Vue 在浏览器端接管由服务端发送的静态 HTML，使其变为由 Vue 管理的动态 DOM 的过程。

由于服务器已经渲染好了 HTML，我们显然无需将其丢弃再重新创建所有的 DOM 元素。相反，我们需要"激活"这些静态的 HTML，然后使他们成为动态的（能够响应后续的数据变化）。

如果你检查服务器渲染的输出结果，你会注意到应用程序的根元素上添加了一个特殊的属性：

```js
<div id="app" data-server-rendered="true">
```
data-server-rendered 特殊属性，让客户端 Vue 知道这部分 HTML 是由 Vue 在服务端渲染的，并且应该以激活模式进行挂载。注意，这里并没有添加 id="app"，而是添加 data-server-rendered 属性：你需要自行添加 ID 或其他能够选取到应用程序根元素的选择器，否则应用程序将无法正常激活。

在开发模式下，Vue 将推断客户端生成的虚拟 DOM 树(virtual DOM tree)，是否与从服务器渲染的 DOM 结构(DOM structure)匹配。如果无法匹配，它将退出混合模式，丢弃现有的 DOM 并从头开始渲染。在生产模式下，此检测会被跳过，以避免性能损耗。

**使用「SSR + 客户端混合」时，需要了解的一件事是，浏览器可能会更改的一些特殊的 HTML 结构。**
```html
<table>
  <tr><td>hi</td></tr>
</table>
```
浏览器会在 `<table>` 内部自动注入 `<tbody>`，然而，由于 Vue 生成的虚拟 DOM(virtual DOM) 不包含`<tbody>`，所以会导致无法匹配。为能够正确匹配，请确保在模板中写入有效的 HTML。

## Bundle Renderer 指引
### 使用基本 SSR 的问题
我们假设打包的服务器端代码，将由服务器通过 require 直接使用：
```js
const createApp = require('/path/to/built-server-bundle.js')
```
这是理所应当的，然而在每次编辑过应用程序源代码之后，都必须停止并重启服务。这在开发过程中会影响开发效率。此外，Node.js 本身不支持 source map。

### 传入 BundleRenderer
vue-server-renderer 提供一个名为 createBundleRenderer 的 API，用于处理此问题，通过使用 webpack 的自定义插件，server bundle 将生成为可传递到 bundle renderer 的特殊 JSON 文件。所创建的 bundle renderer，用法和普通 renderer 相同，但是 bundle renderer 提供以下优点：
* 内置的 source map 支持（在 webpack 配置中使用 devtool: 'source-map'）
* 在开发环境甚至部署过程中热重载（通过读取更新后的 bundle，然后重新创建 renderer 实例）
* 关键 CSS(critical CSS) 注入（在使用 *.vue 文件时）：自动内联在渲染过程中用到的组件所需的CSS。更多细节请查看 CSS 章节。
* 使用 clientManifest 进行资源注入：自动推断出最佳的预加载(preload)和预取(prefetch)指令，以及初始渲染所需的代码分割 chunk。


## 构建配置
建议将配置分为三个文件：base, client 和 server。基本配置(base config)包含在两个环境共享的配置，例如，输出路径(output path)，别名(alias)和 loader。服务器配置(server config)和客户端配置(client config)，可以通过使用 webpack-merge 来简单地扩展基本配置。

### 服务器配置(Server Config)
服务器配置，**是用于生成传递给 createBundleRenderer 的 server bundle**。它应该是这样的：

**参考资料**

![](http://static.zhyjor.com/wexin.png)
