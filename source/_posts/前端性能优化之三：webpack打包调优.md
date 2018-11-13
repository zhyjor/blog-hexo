---
title: 前端性能优化之三：webpack打包调优
tags:
  - 前端性能优化
categories: 前端性能
top: false
copyright: true
date: 2018-2-13 10:44:19
---
相信每个用过 webpack 的同学都对“打包”和“压缩”这样的事情烂熟于心，但是有些时候，我们在打包时会发现问题，**构建的时间过长，打包体积过大**。
<!--more-->

## 构建过程提速策略
### 不要让 loader 做太多事情
最常见的优化方式是，用 include 或 exclude 来帮我们避免不必要的转译，比如 webpack 官方在介绍 babel-loader 时给出的示例：
```js
module: {
  rules: [
    {
      test: /\.js$/,
      exclude: /(node_modules|bower_components)/,
      use: {
        loader: 'babel-loader',
        options: {
          presets: ['@babel/preset-env']
        }
      }
    }
  ]
}
```
这段代码帮我们规避了对庞大的 node_modules 文件夹或者 bower_components 文件夹的处理。但通过限定文件范围带来的性能提升是有限的。除此之外，如果我们选择开启缓存将转译结果缓存至文件系统，则至少可以将 babel-loader 的工作效率提升两倍。要做到这点，我们只需要为 loader 增加相应的参数设定：
```js
loader: 'babel-loader?cacheDirectory=true'
```
以上都是在讨论针对 loader 的配置，但我们的优化范围不止是 loader 们。尽管我们可以在 loader 配置时通过写入 exclude 去避免 babel-loader 对不必要的文件的处理，但是考虑到这个规则仅作用于这个 loader，**像一些类似 UglifyJsPlugin 的 webpack 插件在工作时依然会被这些庞大的第三方库拖累，webpack 构建速度依然会因此大打折扣。**所以针对这些庞大的第三方库，我们还需要做一些额外的努力。

### 第三方库的处理
第三方库以 node_modules 为代表，它们庞大得可怕，却又不可或缺。处理第三方库的姿势有很多，其中，Externals 不够聪明，一些情况下会引发重复打包的问题；而CommonsChunkPlugin 每次构建时都会重新构建一次 vendor；出于对效率的考虑，我们这里为大家推荐 DllPlugin。

DllPlugin 是基于 Windows 动态链接库（dll）的思想被创作出来的。这个插件会把第三方库单独打包到一个文件中，这个文件就是一个单纯的依赖库。**这个依赖库不会跟着你的业务代码一起被重新打包，只有当依赖自身发生版本变化时才会重新打包。**

用 DllPlugin 处理文件，要分两步走：
* 基于 dll 专属的配置文件，打包 dll 库
* 基于 webpack.config.js 文件，打包业务代码

### 将 loader 由单进程转为多进程
webpack 是单线程的，就算此刻存在多个任务，你也只能排队一个接一个地等待处理。这是 webpack 的缺点，好在我们的 CPU 是多核的，Happypack 会充分释放 CPU 在多核并发方面的优势，帮我们把任务分解给多个子进程去并发执行，大大提升打包效率。

HappyPack 的使用方法也非常简单，只需要我们把对 loader 的配置转移到 HappyPack 中去就好，我们可以手动告诉 HappyPack 我们需要多少个并发的进程：
```js
const HappyPack = require('happypack')
// 手动创建进程池
const happyThreadPool =  HappyPack.ThreadPool({ size: os.cpus().length })

module.exports = {
  module: {
    rules: [
      ...
      {
        test: /\.js$/,
        // 问号后面的查询参数指定了处理这类文件的HappyPack实例的名字
        loader: 'happypack/loader?id=happyBabel',
        ...
      },
    ],
  },
  plugins: [
    ...
    new HappyPack({
      // 这个HappyPack的“名字”就叫做happyBabel，和楼上的查询参数遥相呼应
      id: 'happyBabel',
      // 指定进程池
      threadPool: happyThreadPool,
      loaders: ['babel-loader?cacheDirectory']
    })
  ],
}
```

## 构建结果体积压缩

### 文件结构可视化，找出导致体积过大的原因
这里为大家介绍一个非常好用的包组成可视化工具——`webpack-bundle-analyzer`，配置方法和普通的 plugin 无异，它会以矩形树图的形式将包内各个模块的大小和依赖关系呈现出来。在使用时，我们只需要将其以插件的形式引入：
```js
const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin;
 
module.exports = {
  plugins: [
    new BundleAnalyzerPlugin()
  ]
}
```

### 拆分资源
可以使用 DllPlugin 进行。

### 删除冗余代码
一个比较典型的应用，就是 Tree-Shaking。

从 webpack2 开始，webpack 原生支持了 ES6 的模块系统，并基于此推出了 Tree-Shaking。**基于 import/export 语法，Tree-Shaking 可以在编译的过程中获悉哪些模块并没有真正被使用，这些没用的代码，在最后打包的时候会被去除。**Tree-Shaking 的针对性很强，它更适合用来处理模块级别的冗余代码。至于粒度更细的冗余代码的去除，往往会被整合进 JS 或 CSS 的压缩或分离过程中。

这里我们以当下接受度较高的 UglifyJsPlugin 为例，看一下如何在压缩过程中对碎片化的冗余代码（如 console 语句、注释等）进行自动化删除：
```js
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');
module.exports = {
 plugins: [
   new UglifyJsPlugin({
     // 允许并发
     parallel: true,
     // 开启缓存
     cache: true,
     compress: {
       // 删除所有的console语句    
       drop_console: true,
       // 把使用多次的静态值自动定义为变量
       reduce_vars: true,
     },
     output: {
       // 不保留注释
       comment: false,
       // 使输出的代码尽可能紧凑
       beautify: false
     }
   })
 ]
}
```
手动引入 UglifyJsPlugin 的代码其实是 webpack3 的用法，webpack4 现在已经默认使用 uglifyjs-webpack-plugin 对代码做压缩了——在 webpack4 中，我们是通过配置 optimization.minimize 与 optimization.minimizer 来自定义压缩相关的操作的。

### 按需加载
对于单页应用，如果页面很多就需要采用按需加载了，否则每次的加载时间会非常可怕，有很大机率会卡死。更好的做法肯定是先给用户展示主页，其它页面等请求到了再加载。当然这个情况也比较极端，但却能很好地引出按需加载的思想：
* 一次不加载完所有的文件内容，只加载此刻需要用到的那部分（会提前做拆分）
* 当需要更多内容时，再对用到的内容进行即时加载

为了开启按需加载，我们要稍作改动。

首先 webpack 的配置文件要走起来：
```js
output: {
    path: path.join(__dirname, '/../dist'),
    filename: 'app.js',
    publicPath: defaultSettings.publicPath,
    // 指定 chunkFilename
    chunkFilename: '[name].[chunkhash:5].chunk.js',
}
```
路由处的代码也要做一下配合：
```js
const getComponent => (location, cb) {
  require.ensure([], (require) => {
    cb(null, require('../pages/BugComponent').default)
  }, 'bug')
},
...
<Route path="/bug" getComponent={getComponent}>

// 核心就是这个方法
require.ensure(dependencies, callback, chunkName)
```

这是一个异步的方法，webpack 在打包时，BugComponent 会被单独打成一个文件，只有在我们跳转 bug 这个路由的时候，这个异步方法的回调才会生效，才会真正地去获取 BugComponent 的内容。这就是按需加载。

按需加载的粒度，还可以继续细化，细化到更小的组件、细化到某个功能点，都是 ok 的。

在 React-Router4 中，我们确实是用 Code-Splitting 替换掉了楼上这个操作。使用过 React-Router4 实现过路由级别的人，可能会对 React-Router4 里用到的一个叫“Bundle-Loader”的东西印象深刻。

看一下 Bundle Loader 并不长的源代码的话，**你会发现它竟然还是使用 require.ensure 来实现的**——这也是我要把 require.ensure 单独拎出来的重要原因。所谓按需加载，根本上就是在正确的时机去触发相应的回调。理解了这个 require.ensure 的玩法，大家甚至可以结合业务自己去修改一个按需加载模块来用。

### webpack的Gzip
启用gzip需要客户端和服务端的支持，如果客户端支持gzip的解析，那么只要服务端能够返回gzip的文件就可以启用gzip了。**除了服务器端的压缩，配合webpack进行gzip压缩效果更好。**
```
var CompressionWebpackPlugin = require('compression-webpack-plugin');

    //在 plugin 中添加
    new CompressionWebpackPlugin({ //gzip 压缩
        asset: '[path].gz[query]',
        algorithm: 'gzip',
        test: new RegExp(
            '\\.(js|css)$'    //压缩 js 与 css
        ),
        threshold: 10240,
        minRatio: 0.8
    })
```

## 总结
优化是没有止境的，webpack就是一个工具，会不断的迭代，我们需要掌握其核心思想，达到举一反三。

**参考资料**
[关于 webpack 打包后文件过大的那些事……](https://segmentfault.com/a/1190000007892189)
[webpack 代码gzip压缩、注释、警告去除配置，设置缓存](https://juejin.im/post/5ac44443518825557e789a6d)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)