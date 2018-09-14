---
title: 理解Babel之一：js的解析与抽象语法树（AST）
tags:
  - babel
  - 理解babel
categories: babel
top: false
copyright: true
date: 2018-03-13 22:43:20
---

我们对babel的认识基本都是从ES6代码的编译开始的，当然我们不能仅仅停留在会有的阶段，我们需要理解其深层次的实现原理，以达到触类旁通，在整体层次上提高自己。本系列对babel的使用以及其实现原理进行深入分析，争取最终可以实现一个babel插件。
<!--more-->
在理解babel之前，我们了解一下js的解析与抽象语法树。我们写的一个个字符究竟怎么被机器理解并正确执行的呢，这些都要从js解析引擎慢慢说起。


## 什么是JavaScript解析引擎
简单说js解析引擎的存在就是为了看懂你写的程序，将你写程序告诉机器怎么去执行。比如对于这样一句代码`var x = 1`，解析引擎最终做的事情就是在栈内存中确定一个名字为a的变量，且赋值为1.
在编译原理中，对于静态语言，处理上述事情的叫编译器（Complier）,而在动态语言中这称为解释器（Interpreter）。两者的区别就是：编译器是将源代码编译为另外一种代码（比如机器码，或者字节码），而解释器是直接解析并将代码运行结果输出。 比方说，firebug的console就是一个JavaScript的解释器。

但是有些资料表明V8引擎（Chrome使用的js解析引擎），为了提高js的运行性能，在运行之前会先将JS编译为本地的机器码（native machine code），然后再去执行机器码（这样速度就快很多），这就是常见的JIT(Just In Time Compilation)。在某种程度上，其步骤可以简单的分为Js源码—>抽象语法树—>本地机器码。关于浏览器引擎的在[《浏览器渲染系列博客》]()中有详细的介绍，本文点到为止。

至于为什么解析引擎能够看懂你写的js代码，这就是接下来的抽象语法树所要做的事情了。

### JavaScript解析引擎与ECMAScript是什么关系？



**参考资料**
[Babel 从入门到插件开发](http://web.jobbole.com/91277/)
[理解 Babel 插件](http://web.jobbole.com/88236/)
[Babel是如何编译JS代码的及理解抽象语法树(AST）](https://www.cnblogs.com/tugenhua0707/p/7863616.html)
[JS的解析与执行过程](https://www.cnblogs.com/foodoir/p/5977950.html)
[JavaScript运行原理解析](https://blog.csdn.net/liaodehong/article/details/50488098)
[Node.js编程之路之——与V8引擎共舞](http://cnodejs.org/topic/57590ff62ad3c06f1aa3d571)
[认识 V8 引擎](https://zhuanlan.zhihu.com/p/27628685)
[Babel是如何读懂JS代码的](https://zhuanlan.zhihu.com/p/27289600)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)

