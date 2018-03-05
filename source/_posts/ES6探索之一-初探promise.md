---
title: 'ES6探索之一:初探promise'
tags:
  - ES6
  - promise
categories: ES6
copyright: true
date: 2018-03-05 09:21:57
---
本文对ES6中promise进行入门级的理解，对其源码进行分析，达到能用，知道为什么这样用即可
<!--more-->

### 实战Promise
####  Promise.resolve
创建promise的快捷方式
静态方法Promise.resolve(value) 可以认为是 new Promise() 方法的快捷方式。这句语句可以看成下述代码的语法糖
```
new Promise(function(resolve){
resolve(42);
});
```
#### Thenable
Promise.resolve 方法另一个作用就是将 thenable 对象转换为promise对象。
```
var promise = Promise.resolve($.ajax('/json/comment.json'));// => promise对象
    promise.then(function(value){
    console.log(value);
});
```

#### Promise的执行顺序
> 在使用Promise.resolve(value) 等方法的时候， 如果promise对象立刻就能进入resolve状态的话， 那么你是不是觉得 .then 里面指定的方法就是同步调用的呢？

```
var promise = new Promise(function (resolve){
	console.log("inner promise"); // 1
	resolve(42);
});
promise.then(function(value){
	console.log(value); // 3
});
console.log("outer promise"); // 2

//输出结果
inner promise // 1
outer promise // 2
42 // 3
```
即使在调用 promise.then 注册回调函数的时候promise对象已经是确定的状态， Promise
也会以异步的方式调用该回调函数， 这是在Promise设计上的规定方针。
**为什么要对明明可以以同步方式进行调用的函数， 非要使用异步的调用方式呢？**

其实在Promise之外也存在这个问题， 这里我们以一般的使用情况来考虑此问题。
这个问题的本质是接收回调函数的函数， 会根据具体的执行情况， 可以选择是以同步还是异步的方式对回调函数进行调用。

**同步调用和异步调用同时存在导致的混乱**。
```
async-onready.js
function onReady(fn) {
	var readyState = document.readyState;
	if (readyState === 'interactive' || readyState === 'complete') {
		setTimeout(fn, 0);
	} else {
		window.addEventListener('DOMContentLoaded', fn);
	}
	} 
	onReady(function () {
		console.log('DOM fully loaded and parsed');
});
console.log('==Starting==');
```
为了避免代码在不同的位置有不同的打印顺序，都采用了异步的方式`setTimeout(fn, 0);`

**参考资料**
[]()

![](http://oankigr4l.bkt.clouddn.com/wexin.png)