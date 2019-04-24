---
title: ES6探索之四：Generator函数
tags:
  - ES6
  - ES6探索
categories: ES6
copyright: true
date: 2018-03-19 09:23:47
---
Generato顾名思义，就是一个生成器函数，生成什么？生成遍历器。换句话说 Generator 函数就是遍历器生成函数。
<!--more-->

执行到第一个yield的位置的过程中发生了什么，每次的返回值是什么

```js
function* helloGen () {
    console.log('1')
    console.log('2',yield 'hellp')
    yield 'world'
    return 'ending'
}

var hwg = helloGen()

utils.Logger(hwg.next())
```
next 表示上一个yield的返回值，因此他的值应该打印在上一个yield语句所在的地方。V8 引擎直接忽略第一次使用next方法时的参数，只有从第二次使用next方法开始，参数才是有效的。从语义上讲，第一个next方法用来启动遍历器对象，所以不用带有参数。

```js
function* dataConsumer() {
  console.log('Started');
  console.log(`1. ${yield}`);
  console.log(`2. ${yield}`);
  return 'result';
}

let genObj = dataConsumer();
genObj.next();
// Started
genObj.next('a')
// 1. a
genObj.next('b')
// 2. b
```



**参考资料**
[异步Promise及Async/Await可能最完整入门攻略](https://segmentfault.com/a/1190000016788484)

![](http://static.zhyjor.com/wexin.png)
