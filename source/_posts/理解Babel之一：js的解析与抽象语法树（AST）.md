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


**参考资料**
[Babel 从入门到插件开发](http://web.jobbole.com/91277/)
[理解 Babel 插件](http://web.jobbole.com/88236/)
[Babel是如何编译JS代码的及理解抽象语法树(AST）](https://www.cnblogs.com/tugenhua0707/p/7863616.html)
[JS的解析与执行过程](https://www.cnblogs.com/foodoir/p/5977950.html)
[JavaScript运行原理解析](https://blog.csdn.net/liaodehong/article/details/50488098)
![](http://oankigr4l.bkt.clouddn.com/wexin.png)