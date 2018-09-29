---
title: webpack深入理解之一：webpack的运行机制
tags:
  - webpack深入理解
  - webpack
  - 前端工程化
categories: webpack
top: false
copyright: true
date: 2018-03-29 14:01:49
---
前端工程化的确在不停的发展与完善，webpack也日渐成为前端开发不可或缺的构建工具。webpack在不断迭代，更多的零配置的方式在出现，虽然使用的越来越舒适，但是不了解其内部的构建过程无论如何都是不合适的。本系列对webpack的深层实现进行分析。
<!--more-->
## 运行机制概述
webpack的运行过程可以分为以下：
```
初始化配置参数 -> 绑定事件钩子回调 -> 确定Entry逐一遍历 -> 使用loader编译文件 -> 输出文件
```

## 运行流程

### webpack事件流
在分析webpack运行流程时，我们可以借助一个概念，便是webpack的事件流机制。

**什么是webpack事件流？**
> Webpack 就像一条生产线，要经过一系列处理流程后才能将源文件转换成输出结果。 这条生产线上的每个处理流程的职责都是单一的，多个流程之间有存在依赖关系，只有完成当前处理后才能交给下一个流程去处理。 插件就像是一个插入到生产线中的一个功能，在特定的时机对生产线上的资源做处理。Webpack 通过 Tapable 来组织这条复杂的生产线。 Webpack 在运行过程中会广播事件，插件只需要监听它所关心的事件，就能加入到这条生产线中，去改变生产线的运作。 Webpack 的事件流机制保证了插件的有序性，使得整个系统扩展性很好。     
--吴浩麟《深入浅出webpack》

我们将webpack事件流理解为webpack构建过程中的一系列事件，他们分别表示着不同的构建周期和状态，我们可以像在浏览器上监听click事件一样监听事件流上的事件，并且为它们挂载事件回调。我们也可以自定义事件并在合适时机进行广播，这一切都是使用了webpack自带的模块 Tapable 进行管理的。我们不需要自行安装 Tapable ，在webpack被安装的同时它也会一并被安装，如需使用，我们只需要在文件里直接 require 即可。

Tapable的原理其实就是我们在前端进阶过程中都会经历的EventEmit，通过发布者-订阅者模式实现，它的部分核心代码可以概括成下面这样：
```js
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
webpack4重写了事件流机制，其hook比较繁杂，但是有些重要的事件需要详细了解。


### 运行流程详解
这里先放一张盗到的图，
![](http://oankigr4l.bkt.clouddn.com/201809291735_592.png)

首先，webpack会读取你在命令行传入的配置以及项目里的 `webpack.config.js` 文件，初始化本次构建的配置参数，并且执行配置文件中的插件实例化语句，生成Compiler传入plugin的apply方法，为webpack事件流挂上自定义钩子。


**参考资料**
[webpack4.0源码分析之Tapable](https://juejin.im/post/5abf33f16fb9a028e46ec352)
[ webpack hook](https://webpack.js.org/api/compiler-hooks/)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)