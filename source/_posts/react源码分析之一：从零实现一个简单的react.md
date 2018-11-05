---
title: react源码分析之一：从零实现一个简单的react
tags:
  - react源码分析
  - react
categories: react
top: false
copyright: true
date: 2018-10-20 17:27:34
---
React 中的元素、组件、实例和节点，是React中关系密切的4个概念，也是很容易让React 初学者迷惑的4个概念。现在，老干部就来详细地介绍这4个概念，以及它们之间的联系和区别，满足喜欢咬文嚼字、刨根问底的同学
<!--more-->

**参考资料**
[React 深入系列5：事件处理](https://mp.weixin.qq.com/s?__biz=MzU1ODQ0NzM2NA==&mid=2247483706&idx=1&sn=7682fa5f5db94bc2e975f82c9060554e&chksm=fc272f51cb50a6473137d51daabaeb684b58e97898f12391d46dcf730b6f5ed06382aefc773c#rd)
[React事件系统和源码浅析](https://juejin.im/post/5bdf0741e51d456b8e1d60be)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)