---
title: webpack实践之四：webpack4升级不完全指南
tags:
  - webpack实践
  - webpack
categories: webpack
top: false
copyright: true
date: 2018-07-17 10:49:35
---
2018年2月25日，webpack大版本升级到4.x了。由此带来一大波包的升级。旧的项目能升级就升级，新项目该用的就可以用了，毕竟我们守着祖传的代码升不了值的。
<!--more-->
## 支持零配置（Zero Configuration）
该特性主要用于解决webpack的门槛高问题，webpack是一个配置声明式的操作模式，npm、gulp是指令式的，需要描述每一步是干什么的，而webpack的配置项凌乱且无序，让很多开发者头疼。

webpack4提供了零配置方案，默认入口属性为 ./src ，默认输出路径为 ./dist ，不再需要配置文件，实现了开箱即用的封装能力，更通俗的讲，webpack会自动查找项目中src目录下的index.js文件，然后选择的模式进行相应的打包操作，最后新建dist目录并生成一个main.js文件。

此外针对开发环境和线上环境提供了两种打包模式： "production" 和 "development" ， "production" 模式内置了项目产出时的基本配置项， "development" 模式基本满足了快速构建和开发体验。使用的方法是在运行webapck命令的时候，设置好mode参数的值即可，默认是production属性。
```
"scripts": {
    "dev": "webpack --mode development",
    "build": "webpack --mode production" 
}
```

### Production模式
提供了发布程序时的优化配置项，旨在更小的产出文件、更快的运行速度、不暴露源码和路径。会默认采用代码压缩（minification），作用域提升（scope hoisting），tree-shaking，NoEmitOnErrorsPlugin，无副作用模块修剪（side-effect-free module pruning）等。

### Development模式
旨在提升开发调试过程中的体验，如更快的构建速度、调试时的代码易读性、暴露运行时的错误信息等。会默认采用bundle的输出包含路径名和 eval-source-map 等，提升代码的可读性和构建速度。

两种模式就是两个箱子，箱子里面就是各种插件工具，只是有些是开启的，有些是关闭的，具体有哪些工具可以参考[这篇文章](https://www.colabug.com/goto/aHR0cHM6Ly9tZWRpdW0uY29tL3dlYnBhY2svd2VicGFjay00LW1vZGUtYW5kLW9wdGltaXphdGlvbi01NDIzYTZiYzU5N2E=) 。


## 配置项
### 废弃CommonsChunkPlugin
先介绍一下code splitting下的CommonsChunkPlugin有什么缺点，然后仔介绍一下chunk split是怎么进行优化的。
#### CommonsChunkPlugin的问题
CommmonsChunkPlugin的思路是 Create this chunk and move all modules matching minChunks into the new chunk ，即将满足 minChunks 配置想所设置的条件的模块移到一个新的chunk文件中去，这个思路是基于 父子关系 的，也就是这个新产出的new chunk是所有chunk的父亲，在加载孩子chunk的时候，父亲chunk是必须要提前加载的。举个例子：
```
example：
entryA:  vue  vuex  someComponents
entryB:  vue axios someComponents
entryC: vue vux axios someComponents
minchunks: 2
```
产出后的chunk：
```
vendor-chunk：vue vuex axios
chunkA~chunkC: only the components
```
**带来的问题是：对entryA和entryB来说，vendor-chunk都包含了多余的module。**

CommonsChunkPlugin另外一个问题是：对异步的模块不友好。下面也举例说明：
```
example：
entryA:  vue  vuex  someComponents
asyncB：vue axios someComponents
entryC: vue vux axios someComponents
minchunks: 2
```
产出后的chunk：
```
vendor-chunk：vue vuex 
chunkA: only the components
chunkB: vue axios someComponents
chunkC: axios someComponents
```
带来的问题是：如果asyncB在entryA中动态引入，则会引入多余的module。

总的来说CommonsChunkPlugin有以下三个问题：
* 产出的chunk在引入的时候，会包含重复的代码；
* 无法优化异步chunk；
* 高优的chunk产出需要的minchunks配置比较复杂。


#### SplitChunksPlugin
与CommonsChunkPlugin的 父子关系 思路不同的是，SplitChunksPlugin引入了 chunkGroup 的概念，在入口chunk和异步chunk中发现被重复使用的模块，将重叠的模块以vendor-chunk的形式分离出来，也就是vendor-chunk可能有多个，不再受限于是所有chunk中都共同存在的模块，原理的示意如下图所示：

![](http://static.zhyjor.com/201807251344_871.png)

其中，可以发现SplitChunksPlugin产出的vendor-chunk有多个，对于入口A来说，引入的代码只有chunkA、vendor-chunkA-B、vendor-chunkA-C、vendor-chunkA-B-C；这时候chunkA、vendor-chunkA-B、vendor-chunkA-C、vendor-chunkA-B-C形成了一个chunkGroup。下面举个列子：

```
example：
entryA:  vue  vuex  someComponents
entryB：vue axios someComponents
entryC: vue vux axios someComponents
```
产出后的chunk：
```
vendor-chunkA-C：vuex 
vendor-chunkB-C：axios
vendor-chunkA-B-C：vue
chunkA: only the components
chunkB: only the components
chunkC: only the components
```

SplitChunksPlugin能够解决掉CommonsChunkPlugin中提到的三个问题，SplitChunksPlugin在 production 模式下是默认开启的，但是它默认只作用于异步chunk，如果要作用于入口chunk的话，需要配置 optimization.splitChunks.chunks: "all" ，同时webpack自动split chunks是有几个限制条件的：

* 新产出的vendor-chunk是要被共享的，或者模块来自npm包；
* 新产出的vendor-chunk的大小得大于30kb；
* 并行请求vendor-chunk的数量不能超出5个；
* 对于entry-chunk而言，并行加载的vendor-chunk不能超出3个。


#### 功能更新
上述的这些限制可以在SplitChunks的默认配置项中可以一一对应的看到。
```
splitChunks: {
    chunks: "async",
    minSize: 30000,
    minChunks: 1,
    maxAsyncRequests: 5,
    maxInitialRequests: 3,
    name: true,
    cacheGroups: {
        default: {
            minChunks: 2,
            priority: -20
            reuseExistingChunk: true,
        },
        vendors: {
            test: /[/]node_modules[/]/,
            priority: -10
        }
    }
}
```

#### runtimeChunkPlugin
在使用CommonsChunkPlugin的时候，我们通常会把webpack runtime的基础函数提取出来，单独作为一个chunk，毕竟code splitting想把不变的代码单独抽离出来，方便浏览器缓存，提升加载速度。webpack4废弃了CommonsChunkPlugin，采用了runtimeChunkPlugin可以将每个entry chunk中的runtime部分的函数分离出来，只需要一个简单的配置： optimization.runtimeChunk: true 。

原来基础配置中，废弃commonsChunkPlugin，可以添加一个spliteChunk配置为Chunk：all，如下可以将所有需要的node_modules中代码打包为vendor，将runtime打包为一个runtime文件。
```
new webpack.optimize.CommonsChunkPlugin({
	name: 'vendor'
}),
new webpack.optimize.CommonsChunkPlugin({
	name: 'runtime'
}),
new webpack.NamedChunksPlugin()
```
修改为在同等module的配置等效下，添加一个optimization：
```js
optimization：{
	soliteChunk:{
		chunk:all
	},
	runtimeChunk:true
}
```

### sideEffects

在webapck2开始支持ESModule后，webpack提出了tree-shaking进行无用模块的消除，主要依赖ES Module的静态结构。在webapck4之前，主要通过在.babelrc文件中设置 "modules": false 来开启无用的模块检测，该方法显然比较粗暴。webapck4灵活扩展了如何对某模块开展无用代码检测，主要通过在 package.json 文件中设置 sideEffects: false 来告诉编译器该项目或模块是pure的，可以进行无用模块删除。

官方的github上提供了一个sideEffects的[demo示例](https://github.com/webpack/webpack/tree/master/examples/side-effects)供参考，如果对tree-shaking的概念不是太了解，可去官方的文档中tree-shaking部分详细了解。下面是官方提供的一个减包效果示例，仅供欣赏。
![](http://static.zhyjor.com/201807251356_353.png)

### 支持压缩ES6+代码
在webapck4之前，webpack.prod.conf.js中关于UglifyJsPlugin的注释会有这么一段话：
> // UglifyJs do not support ES6+, you can also use babel-minify for better treeshaking: https://github.com/babel/minify

意思就是UglifyJs无法对ES6+的代码进行压缩，需使用babel-minify获取更好的treeshaking效果。webapck4目前已经支持压缩ES6+的代码。
```js
// 源代码
import {sayHello} from './libs/js/util.js'
let output = sayHello('hwm');
console.log(output);

// 产出
...let r=(e=>`Hello ${e}!`)("hwm");console.log(r)}...
```

### 支持更多的模块类型
webpack4支持以 import 和 export 形式加载和导出本地的WebAssembly模块，这一块本人实际项目并未使用到，暂不做介绍；此外，webpack4支持json模块和tree-shaking，之前json文件的加载需要 json-loader 的支持，webpack4已经能够支持json模块（JSON Module），不需要额外的配置；此外，当json文件用ESModule的语法import引入的时候，webpack4还能支持对json模块进行tree-shaking处理，把用不到的字段过滤掉，起到减包的作用。下面是个示例：
```
// 引用数据的三种方法
let jsonData = require('./data/test.json');

import jsonData from './data/test.json'

// 打包时只会提取test.json文件中onePart部分。
import { onePart } from './data/test.json'
```

## 迁移升级到webpack4

### 0配置的局限性
webpack4声称能够0配置，但是0配置有很多局限性，比如只能是单入口的项目，入口和产出的文件名是固定的，entry是src目录下的index.js，产出是dist目录下的main.js，很明显不能满足实际项目应用。于是，开发者还是得自己配置webpack.config.js文件。

### webpack-cli
新的webpack需要安装一下包
```
npm i webpack webpack-dev-server webpack-merge webpack-cli -D
```
这里的webpack包在4.x环境中已经不能再命令行中执行了，只能作为一个普通的npm包进行require，然后使用。取而代之的是webpack-cli作为命令行工具。这是一个比较大的变化。

## loader的重新安装
有些loader不支持的话，需要安装beta版的。



### 增加mode配置
在同等module等级下，增加mode的配置，确认当前环境是开发还是生产：
```
mode: development|production
```
**MODE：开发模式 development,**在这个情况下：
* 开启dev-tool，方便浏览器调试
* 提供详细的错误提示
* 利用缓存机制，实现快速构建
* 开启output.pathinfo，在产出的bundle中显示模块路径信息
* 开启NamedModulesPlugin
* 开启NoEmitOnErrorsPlugin

**MODE：生产模式 PRODUCTION**
* 启动各种优化插件（ModuleConcatenationPlugin、optimization.minimize、ModuleConcatenationPlugin、Tree-shaking），压缩、合并、拆分，产出更小体积的chunk
* 关闭内存缓存
* 开启NoEmitOnErrorsPlugin

所以相关的dev-tool,NoEmitOnErrorsPlugin等，都不用再配置了。

### PLUGIN
* 内置optimization.minimize来压缩代码，不用再显示引入UglifyJsPlugin；
* 废弃CommonsChunkPlugin插件，使用optimization.splitChunks和optimization.runtimeChunk来代替；
* 使用optimization.noEmitOnErrors来替换NoEmitOnErrorsPlugin插件
* 使用optimization.namedModules来替换NamedModulesPlugin插件


### LOADER
废弃json-loader，友好支持json模块，以ESMoudle的语法引入，还可以对json模块进行tree-shaking处理；

[其他的改动信息建议查看webpack的 中文升级日志 。](https://www.colabug.com/goto/aHR0cHM6Ly9qdWVqaW4uaW0vcG9zdC81YTk1MWJmODUxODgyNTI0ZDg0MmVjOGI=)

## vue-cli项目如何改造
介绍完了webpack4中核心配置项的变化，接下来结合vue-cli示例项目介绍一下，如何配置webpack.conf.js文件。
### 升级npm包版本
建议升级webpack4，同时升级涉及到的loaders和plugins。webpack4 中 cli 工具分离成了 webpack 核心库 与 webpack-cli 命令行工具两个模块，需要使用 CLI ，必安装 webpack-cli 至项目中。
```
npm i webpack webpack-cli webpack-dev-server -D
```
涉及到的插件有：
```
"vue-loader": "^15.0.10",
"vue-style-loader": "^4.1.0",
"vue-template-compiler": "^2.5.16",
"copy-webpack-plugin": "^4.0.1",
"extract-text-webpack-plugin": "^4.0.0-beta.0",
"html-webpack-plugin": "^3.1.0",
"optimize-css-assets-webpack-plugin": "^4.0.0",
"webpack-bundle-analyzer": "^2.11.1",
"webpack-dev-middleware": "^3.1.2",
"webpack-dev-server": "^3.1.3",
"webpack-merge": "^4.1.0"
```

### 修改webpack.base.conf.js
webpack4推荐使用了最新版本的vue-loader（"vue-loader": "^15.0.10"），但是最新的vue-loader需要在webapck config文件中设置 VueLoaderPlugin 插件，否则会报以下错误：
> vue-loader was used without the corresponding plugin. Make sure to include VueLoaderPlugin in your webpack config.


webpack.base.conf.js文件中的改动主要是添加VueLoaderPlugin插件。
```js
const { VueLoaderPlugin } = require('vue-loader');
module.exports = {
    ...
    plugins: [
        // 添加VueLoaderPlugin，以响应vue-loader
        new VueLoaderPlugin()
  ],
    ...
}
```

### 修改webpack.dev.conf.js
添加mode属性，并设置为development模式；然后注释掉 webpack4开发模式已经内置的插件，如 webpack.NamedModulesPlugin 和 webpack.NoEmitOnErrorsPlugin 插件。

![](http://static.zhyjor.com/201807251408_745.png)

### 修改webpack.prod.conf.js
添加mode属性，并设置为production模式；然后注释掉 webpack4生产模式已经内置的插件，如 CommonsChunkPlugin 、 uglifyjs-webpack-plugin 、 ModuleConcatenationPlugin 插件；最后根据webpack4提供的文档配置optimization，使用 splitChunks 和 runtimeChunk 完成chunk的提取和优化。

![](http://static.zhyjor.com/201807251410_976.png)

```js
const webpackConfig = merge(baseWebpackConfig, {
...
    optimization: {
    // 采用splitChunks提取出entry chunk的chunk Group
    splitChunks: {
      cacheGroups: {
        // 处理入口chunk
        vendors: {
          test: /[/]node_modules[/]/,
          chunks: 'initial',
          name: 'vendors',
        },
        // 处理异步chunk
        'async-vendors': {
          test: /[/]node_modules[/]/,
          minChunks: 2,
          chunks: 'async',
          name: 'async-vendors'
        }
      }
    },
    // 为每个入口提取出webpack runtime模块
    runtimeChunk: { name: 'manifest' }
  }
...
})
```
经过以上操作，我们已经基本完成了vue-cli项目的改造。运行项目的时候，注意看控制台的报错，是哪个插件报的错就去升级那个插件，如果存在找不到模块之类的错误就去升级对应的loader。vue-cli项目webapck4下配置demo已经上传到github，欢迎 [下载](https://github.com/huangwenming/learning-notes/tree/master/webpack4-demo/vue-cli-config) 。

## webpack4的性能如何
webapck4旨在开发模式下提升构建速度、提升用户体验，在生产模式下减小产出包的大小，提升加载和运行速度，两种模式下，webapck4性能上的确是精进不少，虽然有各种坑，还是建议把坑填了，升级到webpack4。

## webpack的未来
想了解webpack的未来，建议先过一下webpack的历史。

webpack1支持CMD和AMD，同时拥有丰富的plugin和loader，webpack逐渐得到广泛应用。

webpack2相对于webpack最大的改进就是支持ES Module，可以直接分析ES Module之间的依赖关系，而webpack1必须将ES Module转换成CommonJS模块之后，才能使用webpack进行下一步处理。除此之外webpack2支持tree sharking，与ES Module的设计思路高度契合。

webpack3相对于webpack2，过渡相对平稳，但是新的特性大都围绕ES Module提出，如Scope Hoisting和Magic Comment。

webpack4集中发力在用户体验、构建性能（速度和产出大小）、通用和适配性（es module、typescript、web assemble）。

展望未来，webpack的未来肯定持续提升用户体验、降低使用门槛，进一步提升构建速度和产出代码的性能，同时webpack的团队已经承诺会根据社区的投票来决定新特性开发优先权。以下是公告中给出的未来的重点关注点：

* 继续修订长期缓存
* webapck任务多线程化，提升初始化速度和增量构建效率
* 提升CSS到一等公民，引入CSS Module Type ，废弃ExtractTextWebpackPlugin
* 提升HTML到一等公民，引入HTML Module Type
* 继续扩展0CJS（0配置文件），加入更多扩展
* 优化支持WASM 模块，从实验阶段过渡到稳定阶段
* 持续提升用户体验


**参考资料**
[webpack4：连奏中的进化](https://www.colabug.com/2907164.html)
[webpack4-用之初体验，一起敲它十一遍](https://juejin.im/post/5adea0106fb9a07a9d6ff6de)

![](http://static.zhyjor.com/wexin.png)
