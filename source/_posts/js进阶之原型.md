---
title: js进阶之原型
tags:
  - js进阶
  - js
copyright: true
date: 2017-11-28 10:29:38
categories: js
---
理解原型链
<!--more-->
什么是`__proto__`
什么是prototype
为什么只有函数对象才有prototype属性，普通对象只有`__proto__`属性
为什么`Function.prototype === Function.__proto__`
为什么说`typeof`比较的是原型，而`instanceof`比较的是`constructor`这个属性

为什么说js就没有类，只有原型链
为什么`Object.prototype.toString()==='[object Object]'//true`，内部怎么实现的

内置构造器的proto与constructor是怎么实现的


// Object的构造函数是Function
`Object.__proto__ === Function.prototype // true`

`Function.__proto__ === Object.__proto__`
`Function.prototype.__proto__ === Object.prototype`
`Object.prototype.__proto__ === null`

// Array.prototype的构造函数是什么呢
`Array.prototype.__proto__ ===Object.prototype`
// Array的构造函数是Function
`Array.__proto__ === Function.prototype`

** 所有的构造器都来自于 Function.prototype，甚至包括根构造器Object及Function自身。所有构造器都继承了`Function.prototype`的属性及方法。如length、call、apply、bind **

**参考资料**
[最详尽的 JS 原型与原型链终极详解](https://www.jianshu.com/p/a4e1e7b6f4f8)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)