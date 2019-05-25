---
title: 深入学习【ECMA-262-3】之三：This
tags:
  - ECMA262
  - js
categories: js
top: false
copyright: true
date: 2017-03-12 15:49:55
---
[原文：JavaScript. The Core.](http://dmitrysoshnikov.com/ecmascript/javascript-the-core/)
<!--more-->

可以看个奇怪的栗子：
```js
var length = 10;
function fn() {
	console.log(this.length);
}

var obj = {
  length: 5,
  method: function(fn) {
    fn();
	// 这个时候已经将fn函数绑定到arguments对象上了
    arguments[0]();
  }
};

obj.method(fn, 1);

// 10
// 2
```
**那么这里第二次执行arguments[0]为什么结果是2？**

这里绑定的this是不同的。



**参考资料**
[深入理解JavaScript系列（13）：This? Yes,this!](http://www.cnblogs.com/TomXu/archive/2012/01/17/2310479.html)

![](http://static.zhyjor.com/wexin.png)
