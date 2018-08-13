---
title: JavaScript常见问题之八：堆栈溢出之谜
tags:
  - JavaScript常见问题
  - js
categories: js
top: false
copyright: true
date: 2018-05-23 11:38:33
---
在JS中，不小心的操作或者编程习惯，很容易造成堆栈溢出，特别是进行回调，递归或者循环的时候。浏览器一般会报这样的错误：
```
Uncaught RangeError: Maximum call stack size exceeded
```
<!--more-->
每次执行代码时，都会分配一定尺寸的栈空间（Windows系统中为1M），每次方法调用时都会在栈里储存一定信息（如参数、局部变量、返回值等等），这些信息再少也会占用一定空间，成千上万个此类空间累积起来，自然就超过线程的栈空间了。那么如何解决此类问题？



## 实例
下面的代码将会造成栈溢出，请问如何优化，不改变原有逻辑
```js
var list = readHugeList();

var nextListItem = function() {
    var item = list.pop();

    if (item) {
        // process the list item...
        nextListItem();
    }
};
```



这里介绍两个思路解决此问题.

## 解决方式

### 异步
显然，这里就是使用的第一种方法，闭包。为什么使用setTimeout就可以解决问题？我们看下与没用之前的差别。如果没有使用setTimeout，那么函数将在大数据前不断的回调，直到最后走到重点，最初的函数才运行结束，释放内存。 但是如果使用了setTimeout，我们知道它是异步的，即使设置了时间为0，它也允许先执行下面的内容，可以释放堆栈，从而避免堆栈溢出的问题。
换言之，加了setTimeout，nextListItem函数被压入事件队列，函数可以退出，因此每次会清空调用堆栈。

答案：
```js
var nextListItem = function() {
    var item = list.pop();

    if (item) {
        // process the list item...
        setTimeout(nextListItem,0}
};

```

### 闭包
闭包 也是一样的道理，因为这道题要求不修改原有逻辑，第一种是最合适的答案，当然用闭包避免的方法就是返回出来一个函数。
```js
var nextListItem = function() {
    var item = list.pop();

    if (item) {
        // process the list item...
        return nextListItem()
    }
};
```
当然，这样做会改变函数的调用方式，我们就需要不断的调用 nextListItem()()() 为了处理这个办法，可以对其进行进一步的封装

```js
var nextListItem = function() {
    var item = list.pop();

    if (item) {
        // process the list item...
        return function() {
            return nextListItem()
        }
    }
};

function autoRun(fun) {
    var value = nextListItem();
    while(typeof value === 'function') {
        value = nextListItem()
    }
    return
}
```
这样，就解决堆栈溢出的问题。 这里闭包的思路来源与堆栈溢出解决方案。

**这里也可以利用bind函数进行封装：**
```
function isEven(n) {
    /**
     * [isEvenInner 递归]
     * @param  {[type]}  num [description]
     * @return {Boolean}     [description]
     */
    function isEvenInner (n) {
        if (n === 0) {
            return true;
        }

        if (n === 1) {
            return false;
        }

        return function() {
            return isEvenInner(Math.abs(n) - 2);
        }
    }
    /**
     * [trampoline 迭代]
     * @param  {[type]} func [description]
     * @param  {[type]} arg  [description]
     * @return {[type]}      [description]
     */
    function trampoline (func, arg) {
        var value = func(arg);

        while(typeof value === "function") {
            value = value();
        }

        return value;
    }

    return trampoline.bind(null, isEvenInner)(n);
}
//Outputs: true
console.log(isEven(10000));

//Outputs: false
console.log(isEven(10001));
```


**参考资料**
[Javascript中递归造成的堆栈溢出及解决方案](http://www.zuojj.com/archives/1115.html)
[前端面试&笔试&错题指南（二）堆栈溢出之谜](https://juejin.im/post/5b5749cbe51d453467550494)
**[underscore-contrib中源码](http://documentcloud.github.io/underscore-contrib/)**

![](http://oankigr4l.bkt.clouddn.com/wexin.png)