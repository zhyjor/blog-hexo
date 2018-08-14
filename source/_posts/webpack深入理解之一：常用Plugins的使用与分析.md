---
title: webpack深入理解之一：常用Plugins的使用与分析
tags:
  - webpack
  - webpack深入理解
  - 前端工程化
categories: webpack
top: false
copyright: true
date: 2018-04-18 10:00:32
---
插件目的在于解决 loader 无法实现的其他事。本文简单介绍插件的使用方法，对于重要的plugin从原理的角度分析其实现的方法。插件是 webpack 的支柱功能。webpack 自身也是构建于，你在 webpack 配置中用到的相同的插件系统之上！
<!--more-->

## Plugins是什么
> 插件是 webpack 的支柱功能。webpack 自身也是构建于，你在 webpack 配置中用到的相同的插件系统之上！
插件目的在于解决 loader 无法实现的其他事。

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



## 其他常用Plugins
### 修改行为
### 优化
### 其他


**参考资料**
**[webpack官方文档](https://www.webpackjs.com/concepts/)**
**[HtmlWebpackPlugin官方教程](http://www.css88.com/doc/webpack2/plugins/html-webpack-plugin/)**
[webpack4-用之初体验，一起敲它十一遍](https://juejin.im/post/5adea0106fb9a07a9d6ff6de)
[Webpack 常见静态资源处理 - 模块加载器（Loaders）+ExtractTextPlugin插件](https://www.cnblogs.com/sloong/p/5826818.html)
[webpack官方文档](https://webpack.js.org/concepts/)
[手摸手，带你用合理的姿势使用webpack4（上）](https://juejin.im/post/5b56909a518825195f499806)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)