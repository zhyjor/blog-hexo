---
title: VirtualDom浅析之一：什么是虚拟DOM
tags:
  - VirtualDom浅析
  - 虚拟DOM
  - vue
  - react
categories: 前端
top: false
copyright: true
date: 2018-07-04 14:17:25
---
目前最流行的两大前端框架，React和Vue，都不约而同的借助Virtual DOM技术提高页面的渲染效率。那么，什么是Virtual DOM？它是通过什么方式去提升页面渲染效率的呢？本系列文章会详细讲解Virtual DOM的创建过程，并实现一个简单的Diff算法来更新页面。本文的内容脱离于任何的前端框架，只讲最纯粹的Virtual DOM。敲单词太累了，下文Virtual DOM一律用VD表示。
<!--more-->

**参考资料**
[你不知道的Virtual DOM（一）：Virtual Dom介绍](https://segmentfault.com/a/1190000016129036)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)