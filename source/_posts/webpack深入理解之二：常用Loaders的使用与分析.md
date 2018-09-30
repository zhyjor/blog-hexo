---
title: webpack深入理解之二：常用Loaders的使用与分析
tags:
  - webpack深入理解
  - webpack
  - 前端工程化
categories: webpack
top: false
copyright: true
date: 2018-04-18 10:00:50
---
loader是用在某种类型的文件处理上的，用于对模块的源代码进行转换。本文我们了解常用的loader，并且实现一个简单的loader。
<!--more-->

## loader是什么
loader 用于对模块的源代码进行转换。loader 可以使你在 import 或"加载"模块时预处理文件。因此，loader 类似于其他构建工具中“任务(task)”，并提供了处理前端构建步骤的强大方法。loader 可以将文件从不同的语言（如 TypeScript）转换为 JavaScript，或将内联图像转换为 data URL。loader 甚至允许你直接在 JavaScript 模块中 import CSS文件！

### loader的原形
在webpack中，真正起编译作用的便是我们的loader，也就是说，平时我们进行babel的ES6编译，SCSS、LESS等编译都是在loader里面完成的，在你不知道loader的本质之前你一定会觉得这是个很高大上的东西，正如计算机学科里的编译原理一样，里面一定有许多繁杂的操作。但实际上，loader只是一个普通的funciton，他会传入匹配到的文件内容(String)，你只需要对这些字符串做些处理就好了。一个最简单的loader大概是这样：
```js
/**
 * loader Function
 * @param {String} content 文件内容
 */
module.exports = function(content){
    return "{};" + content
}
```

使用它的方式和babel-loader一样，只需要在webpack.config.js的module.rules数组里加上这么一个对象就好了：
```js
{
    test: /\.js$/,
    exclude: /node_modules/,
       use: {
           //这里是我的自定义loader的存放路径
           loader: path.resolve('./loaders/index.js'),
           options: {
              test: 1
           }
       }
}
```
这样，loader会去匹配所有以.js后缀结尾的文件并在内容前追加{};这样一段代码，我们可以在输出文件中看到效果：
![](http://oankigr4l.bkt.clouddn.com/201809301512_658.png)

所以，拿到了文件内容，你想对字符串进行怎样得处理都由你自定义～你可以引入babel库加个 babel(content) ，这样就实现了编译，也可以引入uglifyjs对文件内容进行字符串压缩，一切工作都由你自己定义。

## Loader实战常用技巧
### loader的用户自定义配置

![](http://oankigr4l.bkt.clouddn.com/201809301513_544.png)

在我们在`webpack.config.js`书写loader配置时，经常会见到 options 这样一个配置项，这就是webpack为用户提供的自定义配置，在我们的loader里，如果要拿到这样一个配置信息，只需要使用这个封装好的库 `loader-utils` 就可以了：
```js
const loaderUtils = require("loader-utils");

module.exports = function(content){
    // 获取用户配置的options
    const options = loaderUtils.getOptions(this);
    console.log('***options***', options)
    return "{};" + content
}
```

### loader导出数据的形式
在前面的示例中，因为我们一直loader是一个Funtion，所以我们使用了return的方式导出loader处理后的数据，但其实这并不是我们最推荐的写法，在大多数情况下，我们还是更希望使用 this.callback 方法去导出数据。如果改成这种写法，示例代码可以改写为：
```js
module.exports = function(content){
    //return "{};" + content
    this.callback(null, "{};" + content)
}

```
this.callback 可以传入四个参数（其中后两个参数可以省略），他们分别是：
* error：Error | null，当loader出错时向外跑出一个Error
* content：String | Buffer，经过loader编译后需要导出的内容
* sourceMap：为方便调试生成的编译后内容的source map
* ast: 本次编译生成的AST静态语法树，**之后执行的loader可以直接使用这个AST，可以省去重复生成AST的过程**

### 异步loader
不论是使用return还是 this.callback 的方式，导出结果的执行都是同步的，假如我们的loader里存在异步操作，比如拉取请求等等又该怎么办呢？

熟悉ES6的朋友都知道最简单的解决方法便是封装一个Promise，然后用async-await完全无视异步问题，示例代码如下：
```js
module.exports = async function(content){
    function timeout(delay) {
        return new Promise((resolve, reject) => {
            setTimeout(() => {
                resolve("{};" + content)
            }, delay)
        })
    }
    const data = await timeout(1000)
    return data
}

```
但如果node的版本不够，我们还有原始的土方案 this.async ，调用这个方法会返回一个callback Function，在适当时候执行这个callback就可以了，上面的示例代码可以改写为：
```js
module.exports = function(content){
    function timeout(delay) {
        return new Promise((resolve, reject) => {
            setTimeout(() => {
                resolve("{};" + content)
            }, delay)
        })
    }
    const callback = this.async()
    timeout(1000).then(data => {
        callback(null, data)
    })
}
```
### loaders的执行顺序
还记得我们配置CSS编译时写的loader嘛，它们是长这样的：

![](http://oankigr4l.bkt.clouddn.com/201809301529_792.png)

在很多时候，我们的 use 里不只有一个loader，这些loader的执行顺序是从后往前的，你也可以把它理解为这个loaders数组的出栈过程。

### loader缓存
webpack增量编译机制会观察每次编译时的变更文件，在默认情况下，webpack会对loader的执行结果进行缓存，这样能够大幅度提升构建速度，不过我们也可以手动关闭它（虽然我不知道为什么要关闭它，既然留了这么个API就蛮介绍下吧，欢迎补充），示例代码如下：
```js
module.exports = function(content){
    //关闭loader缓存
    this.cacheable(false);
    return "{};" + content
}
```

### pitch钩子全程传参
在loader文件里你可以exports一个命名为 pitch 的函数，它会先于所有的loader执行，就像这样：
```
module.exports.pitch = (remaining, preceding, data) => {
    console.log('***remaining***', remaining)
    console.log('***preceding***', preceding)
    // data会被挂在到当前loader的上下文this上在loaders之间传递
    data.value = "test"
}

```
它可以接受三个参数，最重要的就是第三个参数data，你可以为其挂在一些所需的值，一个rule里的所有的loader在执行时都能拿到这个值。
```
module.exports = function(content){
    //***this data*** test
    console.log('***this data***', this.data.value)
    return "{};" + content
}

module.exports.pitch = (remaining, preceding, data) => {
    data.value = "test"
}

```

## 常用的loader

### css-loader
```bash
npm i style-loader css-loader --dev
```
在webpack中添加配置到module.rules中：
```
{
    test: /\.css$/,
    use: [
      'style-loader',
      'css-loader'// 这里的执行顺序是从右向左
    ]
  }
```
对于css，可以使用**css module**来进行配置，修改上述的css-loader如下：
```
'css-loader?modules&localIdentName=[name]-[hash:base64:5]'
```

### file-loader
用于处理各种图标、图片文件，这里webapck不能直接读取文件，需要通过file-loader

## 总结
通过上述介绍，我们明白了，loader其实就是一个“平平无奇”的Funtion，能够传入本次匹配到的文件内容供我们自定义修改。

**参考资料**
[]()

![](http://oankigr4l.bkt.clouddn.com/wexin.png)