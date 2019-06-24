---
title: react源码分析之一：优秀的框架
tags:
  - react
  - 源码分析
  - react源码
categories: react
top: false
copyright: true
date: 2019-06-22 16:51:25
---
看源码是提高能力最好的方式，一直打算看，最近刚好有时间，提高一下自己。react的确是最优秀的框架之一，撸一遍源码真的受益匪浅
<!--more-->
## 源码的目录：
```
package
 -events
react目录
react-dom包
 ->react-reconciler
scheduler
 ->16之后异步渲染的东西，单独发npm了要
shared
```

### react与react-dom
react本身是一个定于，dom里才是具体的操作实现，是平台相关的代码。

### flow.js类型检查


**参考资料**
[]()

![](http://static.zhyjor.com/wexin.png)