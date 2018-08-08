---
title: SSR探索与实践之三：使用webpack构建vue项目的ssr
tags:
  - SSR探索与实践
  - ssr
categories: ssr
top: false
copyright: true
date: 2018-08-08 15:18:54
---
通过本篇文章我们可快速的将一个vue-cli生成的vue工程快速实现服务端渲染，并针对性的修改部分配置。
<!--more-->

本文github上的demo：[daily-zhihu](https://github.com/zhyjor/daily-zhihu-pwa/tree/master)

## vue-cli初始化工程ssr实现
### 安装ssr官方渲染工具
因为这个不仅仅是开发的时候使用，可以直接安装到依赖中。但是vue-server-renderer需要和vue的版本保持一致。
```
npm i -S vue-server-renderer
```

### 使用webpack构建
我们需要使用 webpack 来打包我们的 Vue 应用程序。事实上，我们可能需要在服务器上使用 webpack 打包 Vue 应用程序，因为：
* **通常 Vue 应用程序是由 webpack 和 vue-loader 构建，并且许多 webpack 特定功能不能直接在 Node.js 中运行（例如通过 file-loader 导入文件，通过 css-loader 导入 CSS）。**
* 尽管 Node.js 最新版本能够完全支持 ES2015 特性，我们还是需要转译客户端代码以适应老版浏览器。这也会涉及到构建步骤。

所以基本看法是，对于客户端应用程序和服务器应用程序，我们都要使用 webpack 打包 - 服务器需要「服务器 bundle」然后用于服务器端渲染(SSR)，而「客户端 bundle」会发送给浏览器，用于混合静态标记。
![](http://oankigr4l.bkt.clouddn.com/201808071502_946.png)

上图是构建vue的过程，我们可以根据这些得出我们的大概的目录结构。大部分源码可以使用通用方式编写，可以使用 webpack 支持的所有功能。

### 修改webpack的入口文件
结构如下图：
```
src
├── components
│   ├── Foo.vue
│   ├── Bar.vue
│   └── Baz.vue
├── App.vue
├── create-app.js # 通用 entry(universal entry)
├── entry-client.js # 仅运行于浏览器
└── entry-server.js # 仅运行于服务器
```
### 修改main.js为create-app.js
```js
import Vue from 'vue'
   import App from './App'
   import { createRouter } from './router'

   export function createApp () {
     // 创建 router 实例
     const router = new createRouter()
     const app = new Vue({
       // 注入 router 到根 Vue 实例
       router,
       render: h => h(App)
     })
     // 返回 app 和 router
     return { app, router }
   }
```

### entry-client.js加入以下内容：
```js
import { createApp } from './main'
   const { app, router } = createApp()
   // 因为可能存在异步组件，所以等待router将所有异步组件加载完毕，服务器端配置也需要此操作
   router.onReady(() => {
     app.$mount('#app')
   })
```

### entry-server.js
```js
// entry-server.js
   import { createApp } from './main'
   export default context => {
     // 因为有可能会是异步路由钩子函数或组件，所以我们将返回一个 Promise，
     // 以便服务器能够等待所有的内容在渲染前，
     // 就已经准备就绪。
     return new Promise((resolve, reject) => {
       const { app, router } = createApp()
       // 设置服务器端 router 的位置
       router.push(context.url)
       // 等到 router 将可能的异步组件和钩子函数解析完
       router.onReady(() => {
         const matchedComponents = router.getMatchedComponents()
         // 匹配不到的路由，执行 reject 函数，并返回 404
         if (!matchedComponents.length) {
           // eslint-disable-next-line
           return reject({ code: 404 })
         }
         // Promise 应该 resolve 应用程序实例，以便它可以渲染
         resolve(app)
       }, reject)
     })
   }
```
### 修改router配置
```js
import Vue from 'vue'
import Router from 'vue-router'

Vue.use(Router)
export default () => {
  return new Router({
    mode: 'history',
    routes: [
      {
        path: '/',
        name: 'main',
        component: () => import('../views/main')
      }
    ]
  })
}
```

### 修改store（没有使用可以不添加）
需要使用asyncData，详细的使用请查看github上的实例。
```js
import Vuex from 'vuex'
import newsList from './modules/newsList'
import * as getters from './getters'

const isDev = process.env.NODE_ENV === 'development'
Vue.use(Vuex)

export default () => {
  const store = new Vuex.Store({
    strict: isDev,
    getters,
    modules: {
      newsList
    }
  })
  return store
}

```

### webpack配置
vue相关代码已处理完毕，接下来就需要对webpack打包配置进行修改了。
官网推荐下面这种配置：
```
build
  ├── webpack.base.conf.js  # 基础通用配置
  ├── webpack.client.conf.js  # 客户端打包配置
  └── webpack.server.conf.js  # 服务器端打包配置
```
但vue-cli初始化的配置文件也有三个：base、dev、prod ，我们依然保留这三个配置文件，只需要增加webpack.server.conf.js即可。

### webpack 客户端的配置

修改webpack.base.conf.js的entry入口配置为: ./src/entry-client.js。这样原 dev 配置与 prod 配置都不会受到影响。
> 服务器端的配置也会引用base配置，但会将entry通过merge覆盖为 server-entry.js。

生成客户端构建清单client manifest，带来的好处官方说法如下：  
* 在生成的文件名中有哈希时，可以取代 html-webpack-plugin 来注入正确的资源 URL。
* 在通过 webpack 的按需代码分割特性渲染 bundle 时，我们可以确保对 chunk 进行最优化的资源预加载/数据预取，并且还可以将所需的异步 chunk 智能地注入为 `<script>` 标签，以避免客户端的瀑布式请求(waterfall request)，以及改善可交互时间(TTI - time-to-interactive)。


在prod配置中引入一个插件，并配置到plugin中即可:
```js
const VueSSRClientPlugin = require('vue-server-renderer/client-plugin')
    // ...
    // ...
    plugins: [
       new webpack.DefinePlugin({
         'process.env': env,
         'process.env.VUE_ENV': '"client"' // 增加process.env.VUE_ENV
       }),
       //...
       
       // new HtmlWebpackPlugin({
       //   filename: config.build.index,
       //   template: 'index.html',
       //   inject: true,
       //   minify: {
       //     removeComments: true,
       //     collapseWhitespace: true,
       //     removeAttributeQuotes: true
       //     // more options:
       //     // https://github.com/kangax/html-minifier#options-quick-reference
       //   },
       //   // necessary to consistently work with multiple chunks via CommonsChunkPlugin
       //   chunksSortMode: 'dependency'
       // }),

       // 此插件在输出目录中
       // 生成 `vue-ssr-client-manifest.json`。
       new VueSSRClientPlugin()
    ]
 // ...
```
**另外需要将 prod 的HtmlWebpackPlugin 去除，因为我们有了vue-ssr-client-manifest.json之后，服务器端会帮我们做好这个工作。**

### webpack 服务器端的配置
server的配置有用到新插件运行安装: 
```
npm i -D webpack-node-externals
```
webpack.server.conf.js配置如下：
```js
  const webpack = require('webpack')
  const merge = require('webpack-merge')
  const nodeExternals = require('webpack-node-externals')
  const baseConfig = require('./webpack.base.conf.js')
  const VueSSRServerPlugin = require('vue-server-renderer/server-plugin')
  // 去除打包css的配置
  baseConfig.module.rules[1].options = ''

  module.exports = merge(baseConfig, {
    // 将 entry 指向应用程序的 server entry 文件
    entry: './src/entry-server.js',
    // 这允许 webpack 以 Node 适用方式(Node-appropriate fashion)处理动态导入(dynamic import)，
    // 并且还会在编译 Vue 组件时，
    // 告知 `vue-loader` 输送面向服务器代码(server-oriented code)。
    target: 'node',
    // 对 bundle renderer 提供 source map 支持
    devtool: 'source-map',
    // 此处告知 server bundle 使用 Node 风格导出模块(Node-style exports)
    output: {
      libraryTarget: 'commonjs2'
    },
    // https://webpack.js.org/configuration/externals/#function
    // https://github.com/liady/webpack-node-externals
    // 外置化应用程序依赖模块。可以使服务器构建速度更快，
    // 并生成较小的 bundle 文件。
    externals: nodeExternals({
      // 不要外置化 webpack 需要处理的依赖模块。
      // 你可以在这里添加更多的文件类型。例如，未处理 *.vue 原始文件，
      // 你还应该将修改 `global`（例如 polyfill）的依赖模块列入白名单
      whitelist: /\.css$/
    }),
    plugins: [
      new webpack.DefinePlugin({
        'process.env.NODE_ENV': JSON.stringify(process.env.NODE_ENV || 'development'),
        'process.env.VUE_ENV': '"server"'
      }),
      // 这是将服务器的整个输出
      // 构建为单个 JSON 文件的插件。
      // 默认文件名为 `vue-ssr-server-bundle.json`
      new VueSSRServerPlugin()
    ]
  })
```
注意此处对baseConfig删除了一个属性
```js
baseConfig.module.rules[1].options = '' // 去除分离css打包的插件

```

### 配置package.json增加打包服务器端构建命令并修改原打包命令
```
"scripts": {
    //...
    "build:client": "node build/build.js",
    "build:server": "cross-env NODE_ENV=production webpack --config build/webpack.server.conf.js --progress --hide-modules",
    "build": "rimraf dist && npm run build:client && npm run build:server"
}   
```
如果出现cross-env找不到，请安装npm i -D cross-env

### 修改index.html
```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>vue-ssr-demo</title>
  </head>
  <body>
    <!--vue-ssr-outlet-->
  </body>
</html>
```
原来的`<div id="app">`删掉，只在 body 中保留一个标记即可:`<!--vue-ssr-outlet-->`。 服务器端会在这个标记的位置自动生成一个`<div id="app" data-server-rendered="true">`，客户端会通过`app.$mount('#app')`挂载到服务端生成的元素上，并变为响应式的。

> 注意一下，此处将模板 html 修改为服务端渲染适用的模板了，但项目中的 dev 模式也适用的这个模板，但会因为找不到#app到报错，可以这样处理一下:

> * 最简单的办法，为dev模式单独建立一个 html 模板。
* 为dev模式也集成服务端渲染模式，这样无论生产环境与开发环境共同处于服务端渲染模式下也是相当靠谱的一件事。(官方例子是这样操作的)

### 运行构建命令
```
npm run build
```
然后在dist目录下可见生成的两个 json 文件: `vue-ssr-server-bundle.json`与`vue-ssr-client-manifest.json`。

这两个文件都会应用在 node 端，进行服务器端渲染与注入静态资源文件。

### 编写服务端代码
```
npm i -S koa
npm i -D koa-static
```
在项目根目录创建server.js，内容如下
```js
const Koa = require('koa')
const app = new Koa()
const fs = require('fs')
const path = require('path')
const { createBundleRenderer } = require('vue-server-renderer')

const resolve = file => path.resolve(__dirname, file)

// 生成服务端渲染函数
const renderer = createBundleRenderer(require('./dist/vue-ssr-server-bundle.json'), {
  // 推荐
  runInNewContext: false,
  // 模板html文件
  template: fs.readFileSync(resolve('./index.html'), 'utf-8'),
  // client manifest
  clientManifest: require('./dist/vue-ssr-client-manifest.json')
})

function renderToString (context) {
  return new Promise((resolve, reject) => {
    renderer.renderToString(context, (err, html) => {
      err ? reject(err) : resolve(html)
    })
  })
}
app.use(require('koa-static')(resolve('./dist')))
// response
app.use(async (ctx, next) => {
  try {
    const context = {
      title: '服务端渲染测试', // {{title}}
      url: ctx.url
    }
    // 将服务器端渲染好的html返回给客户端
    ctx.body = await renderToString(context)

    // 设置请求头
    ctx.set('Content-Type', 'text/html')
    ctx.set('Server', 'Koa2 server side render')
  } catch (e) {
    // 如果没找到，放过请求，继续运行后面的中间件
    next()
  }
})

app.listen(3001)

```
运行启动服务命令:
```
node server.js
```
浏览器访问: localhost:3001/test，截图为服务器渲染成功的页面 

## 总结
* 因为node环境里是没有dom操作的，所以一些dom操作的api不能放在created,beforeCreated里进行
* node里没有window等类似对象，可以放在mounted里进行，但是假如所有的操作都放在mounted里了，服务端渲染就没有意义了。

**优点：**
* 可以做到真实数据实时渲染，完全可供SEO小蜘蛛尽情的爬来爬去
* 完全前后端同构，路由配置共享，不再影响服务器404请求

**缺点：**

* 依旧只支持h5 history的路由模式，(没办法，哈希就是提交不到服务器能咋办呢。。。)
* 配置比较麻烦、处理流程比较复杂 (比对预渲染插件，复杂太多)
* 约束较多，不能随心所欲的乱放大招
* 对服务器会造成较大的压力，既然让浏览器更快的渲染了，那就得以占用服务器的性能来买单了

**参考资料**
[让vue-cli初始化后的项目集成支持SSR](https://blog.csdn.net/ligang2585116/article/details/78533793)
[什么是服务端渲染？](https://www.cnblogs.com/jcscript/p/7574276.html)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)