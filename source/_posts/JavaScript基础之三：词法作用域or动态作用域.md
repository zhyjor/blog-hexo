---
title: JavaScript基础之三：词法作用域or动态作用域
tags:
  - JavaScript基础
  - js
categories: js
top: false
copyright: true
date: 2017-03-09 10:08:48
---
很多人都知道作用域这个概念，非常熟悉JavaScript的局部作用域与全局作用域，但今天要说的是比较多人不知道的词法作用域与动态作用域。

<!--more-->

## 先看个栗子
在《js权威指南》中：
```js
// demo1:返回执行结果
var scope = "global scope";
function checkscope(){
    var scope = "local scope";
    function f(){
        return scope;
    }
    return f();
}
checkscope();

// demo2：返回一个函数
var scope = "global scope";
function checkscope(){
    var scope = "local scope";
    function f(){
        return scope;
    }
    return f;
}
checkscope()();
```
这两段代码都会打印：local scope。至于原因如下.

## 作用域
作用域是指程序源代码中定义定义变量的区域，规定了如何寻找变量，确定代码对变量的访问权限。

js采用了词法作用域（lexical scoping）,也就是静态作用域。

### 静态与动态作用域
什么是静态作用域，就是函数在定义的时候就已经决定了函数的作用域了，与之对应的动态作用域，函数的作用域是在函数调用的时候才决定的。

不明白？看个小栗子：
```js
var value = 1;

function foo() {
    console.log(value);
}

function bar() {
    var value = 2;
    foo();
}

bar();

// 1
```
**分析一：**因为js采用了静态作用域，执行 foo 函数
* 先从 foo 函数内部查找是否有局部变量 value
* 如果没有，就根据书写的位置，查找上面一层的代码，也就是 value 等于 1，所以结果会打印 1。

**分析二：**假如js采用了动态作用域，执行 foo 函数
* 依然是从 foo 函数内部查找是否有局部变量 value。
* 如果没有，就从调用函数的作用域，也就是 bar 函数内部查找 value 变量，所以结果会打印 2。

所以采用了静态作用域的js打印了1，**至于动态作用域，bash的执行使用的是动态作用域，这里不做详细的说明了。**

## 总结
回到最初的栗子，犀牛书上给出的解释是：
> avaScript 函数的执行用到了作用域链，这个作用域链是在函数定义的时候创建的。嵌套的函数 f() 定义在这个作用域链里，其中的变量 scope 一定是局部变量，不管何时何地执行函数 f()，这种绑定在执行 f() 时依然有效。

这两段代码的执行结果是相同的，但是在js引擎里的执行栈里是不同的。

**参考资料**
[]()

![](http://static.zhyjor.com/wexin.png)
