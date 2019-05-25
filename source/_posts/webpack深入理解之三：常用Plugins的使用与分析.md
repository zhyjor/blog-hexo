---
title: webpack深入理解之三：常用Plugins的使用与分析
tags:
  - webpack
  - webpack深入理解
  - 前端工程化
categories: webpack
top: false
copyright: true
date: 2018-05-08 10:00:32
---
插件目的在于解决 loader 无法实现的其他事。本文简单介绍插件的使用方法，对于重要的plugin从原理的角度分析其实现的方法。插件是 webpack 的支柱功能。webpack 自身也是构建于，你在 webpack 配置中用到的相同的插件系统之上！
<!--more-->

## Plugins是什么
> 插件是 webpack 的支柱功能。webpack 自身也是构建于，你在 webpack 配置中用到的相同的插件系统之上！

### webpack事件流
还记得webpack有哪些常用的事件吗？webpack插件起到的作用，就是为这些事件挂载回调，或者执行指定脚本。webpack的事件流是通过 Tapable 实现的，它就和我们的EventEmit一样，是这一系列的事件的生成和管理工具，它的部分核心代码就像下面这样：
```
class SyncHook{
    constructor(){
        this.hooks = [];
    }

    // 订阅事件
    tap(name, fn){
        this.hooks.push(fn);
    }

    // 发布
    call(){
        this.hooks.forEach(hook => hook(...arguments));
    }
}

```
在 webpack hook 上的所有钩子都是 Tapable 的示例，所以我们可以通过 tap 方法监听事件，使用 call 方法广播事件，就像官方文档介绍的这样：
```js
compiler.hooks.someHook.tap(/* ... */);
```
几个比较常用的hook我们也已经在前文介绍过了。

### Plugins是什么

插件目的在于解决 loader 无法实现的其他事。**如果剖析webpack plugin的本质，它实际上和webpack loader一样简单，其实它只是一个带有apply方法的class。**
```js
//@file: plugins/myplugin.js
class myPlugin {
    constructor(options){
        //用户自定义配置
        this.options = options
        console.log(this.options)
    }
    apply(compiler) {
        console.log("This is my first plugin.")
    }
}

module.exports = myPlugin

```
这样就实现了一个简单的webpack plugin，如果我们要使用它，只需要在`webpack.config.js` 里 require 并实例化就可以了：
```js
const MyPlugin = require('./plugins/myplugin-4.js')

module.exports = {
    ......,
    plugins: [
        new MyPlugin("Plugin is instancing.")
    ]
}

```
每次我们需要使用某个plugin的时候都需要new一下实例化，自然，实例过程中传递的参数，也就成为了我们的构造函数里拿到的options了。

而实例化所有plugin的时机，便是在webpack初始化所有参数的时候，也就是事件流开始的时候。**所以，如果配合 shell.js 等工具库，我们就可以在这时候执行文件操作等相关脚本**，这就是webpack plugin所做的事情。

如果你想在指定时机执行某些脚本，自然可以使用在webpack事件流上挂载回调的方法，在回调里执行你所需的操作。

## Tapable新用

如果我们想赋予webpack事件流我们的自定义事件能够实现嘛？答案是肯定的，可以通过下面的4步实现：

**引入Tapable并找到你想用的hook**
引入Tapable并找到你想用的hook，同步hook or 异步hook 。
```js
const { SyncHook } = require("tapable");
```
**实例化hook**
实例化Tapable中你所需要的hook并挂载在compiler或compilation上
```js
compiler.hooks.myHook = new SyncHook(['data'])
```

**监听tap**
在你需要监听事件的位置tap监听:
```js
compiler.hooks.myHook.tap('Listen4Myplugin', (data) => {
    console.log('@Listen4Myplugin', data)
})
```

**执行call方法**
在你所需要广播事件的时机执行call方法并传入数据:
```js
compiler.hooks.environment.tap(pluginName, () => {
       //广播自定义事件
       compiler.hooks.myHook.call("It's my plugin.")
});

```
完整代码实现可以参考我在文章最前方贴出的项目，大概就是下面这样：

现在我的自定义插件里实例化一个hook并挂载在webpack事件流上:

```js
// @file: plugins/myplugin.js
const pluginName = 'MyPlugin'
// tapable是webpack自带的package，是webpack的核心实现
// 不需要单独install，可以在安装过webpack的项目里直接require
// 拿到一个同步hook类
const { SyncHook } = require("tapable");
class MyPlugin {
    // 传入webpack config中的plugin配置参数
    constructor(options) {
        // { test: 1 }
        console.log('@plugin constructor', options);
    }

    apply(compiler) {
        console.log('@plugin apply');
        // 实例化自定义事件
        compiler.hooks.myPlugin = new SyncHook(['data'])

        compiler.hooks.environment.tap(pluginName, () => {
            //广播自定义事件
            compiler.hooks.myPlugin.call("It's my plugin.")
            console.log('@environment');
        });

        // compiler.hooks.compilation.tap(pluginName, (compilation) => {
            // 你也可以在compilation上挂载hook
            // compilation.hooks.myPlugin = new SyncHook(['data'])
            // compilation.hooks.myPlugin.call("It's my plugin.")
        // });
    }
}
module.exports = MyPlugin

```
在监听插件里监听我的自定义事件
```js
// @file: plugins/listen4myplugin.js
class Listen4Myplugin {
    apply(compiler) {
        // 在myplugin environment 阶段被广播
        compiler.hooks.myPlugin.tap('Listen4Myplugin', (data) => {
            console.log('@Listen4Myplugin', data)
        })
    }
}

module.exports = Listen4Myplugin

```
在webpack配置里引入两个插件并实例化:
```js
// @file: webpack.config.js
const MyPlugin = require('./plugins/myplugin-4.js')
const Listen4Myplugin = require('./plugins/listen4myplugin.js')

module.exports = {
    ......,
    plugins: [
        new MyPlugin("Plugin is instancing."),
        new Listen4Myplugin()
    ]
}

```
输出结果就是这样：

![](http://static.zhyjor.com/201809301548_290.png)

我们拿到了call方法传入的数据，并且成功在environment时机里成功输出了。

## 实战剖析
来看一看已经被众人玩坏的 html-webpack-plugin ，我们发现在readme底部有这样一段demo：
```js
function MyPlugin(options) {
  // Configure your plugin with options...
}

MyPlugin.prototype.apply = function (compiler) {
  compiler.hooks.compilation.tap('MyPlugin', (compilation) => {
    console.log('The compiler is starting a new compilation...');

    compilation.hooks.htmlWebpackPluginAfterHtmlProcessing.tapAsync(
      'MyPlugin',
      (data, cb) => {
        data.html += 'The Magic Footer'

        cb(null, data)
      }
    )
  })
}

module.exports = MyPlugin

```
如果你认真读完了上个板块的内容，你会发现，这个 htmlWebpackPluginAfterHtmlProcessing 不就是这个插件自己挂载在webpack事件流上的自定义事件嘛，它会在生成输出文件准备注入HTML时调用你自定义的回调，并向回调里传入本次编译后生成的资源文件的相关信息以及待注入的HTML文件的内容（字符串形式）供我们自定义操作。在项目搜一下这个钩子：

![](http://static.zhyjor.com/201809301552_106.png)

这不和我们在2.0里说的一样嘛，先实例化我们所需要的hook，从名字就可以看出来只有第一个是同步钩子，另外几个都是异步钩子。然后再找找事件的广播：

![](http://static.zhyjor.com/201809301554_687.png)

和我们刚刚介绍的一模一样对吧，只不过异步钩子使用promise方法去广播，其他不就完全是我们自定义事件的流程。大家如果有兴趣可以去打下console看看 `htmlWebpackPluginAfterHtmlProcessing` 这个钩子向回调传入的数据，或许你能发现一片新大陆哦。


## 常用插件

### html-webpack-plugin
插件的基本作用就是生成html文件，可以生成创建html入口文件，比如单页面可以生成一个html文件入口，配置N个html-webpack-plugin可以生成N个页面入口。另外可以为html文件中引入的外部资源如script、link动态添加每次compile后的hash，防止引用缓存的外部文件问题。

html-webpack-plugin的一个实例生成一个html文件，如果单页应用中需要多个页面入口，或者多页应用时配置多个html时，那么就需要实例化该插件多次；

即有几个页面就需要在webpack的plugins数组中配置几个该插件实例：
```js
...
    plugins: [
        new HtmlWebpackPlugin({
             template: 'src/html/index.html',// 源模板文件
              excludeChunks: ['list', 'detail']// 用来配置不允许注入的thunk。
        }),
        new HtmlWebpackPlugin({
            filename: 'list.html',// 输出文件【注意：这里的根路径是module.exports.output.path】
            template: 'src/html/list.html',
            thunks: ['common', 'list']// 不配置此项默认会将entry中所有的thunk注入到模板中。
        }), 
        new HtmlWebpackPlugin({
          filename: 'detail.html',
          template: 'src/html/detail.html',
           thunks: ['common', 'detail']
        })
    ]
    ...
```

### clean-webpack-plugin
使用webpack4时，使用到了clean-webpack-plugin插件，正常情况下，使用webpack命令进行打包，配置文件如下：
```js
plugins: [
	new CleanWebpackPlugin(
        ['dist/main.*.js','dist/manifest.*.js',],　 //匹配删除的文件,可以设置成匹配所有的dist下文件。
        {
            root: __dirname,       　　　　　　　　　　//根目录
            verbose:  true,        　　　　　　　　　　//开启在控制台输出信息
            dry:      false        　　　　　　　　　　//启用删除文件
        }
    )
]
```
这时由于clean-webpack-plugin作用在打包前都会清除之前的文件，生成新的带有hash值的文件.
### extract-text-webpack-plugin【4.0已废弃】

Extact text from bundle into a file, 从bundle中提取出特定的text到一个文件中，使用`extract-text-webpack-plugin`就可将css从js中独立抽离出来。简单使用如下：

```js
$ npm install extract-text-webpack-plugin --save-dev

var ExtractTextPlugin = require("extract-text-webpack-plugin");
module.exports = {
    module: {
        loaders: [
            { test: /\.css$/, loader: ExtractTextPlugin.extract("style-loader", "css-loader") }
        ]
    },
    plugins: [
        new ExtractTextPlugin("styles.css")
    ]
}
```
它将从每一个用到了require("*.css")的entry chunks文件中抽离出css到单独的output文件





**参考资料**
**[webpack官方文档](https://www.webpackjs.com/concepts/)**
**[HtmlWebpackPlugin官方教程](http://www.css88.com/doc/webpack2/plugins/html-webpack-plugin/)**
[webpack4-用之初体验，一起敲它十一遍](https://juejin.im/post/5adea0106fb9a07a9d6ff6de)
[Webpack 常见静态资源处理 - 模块加载器（Loaders）+ExtractTextPlugin插件](https://www.cnblogs.com/sloong/p/5826818.html)
[webpack官方文档](https://webpack.js.org/concepts/)
[手摸手，带你用合理的姿势使用webpack4（上）](https://juejin.im/post/5b56909a518825195f499806)

![](http://static.zhyjor.com/wexin.png)
