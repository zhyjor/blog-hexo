---
title: 前端路由探索之三：vue-router原理分析
tags:
  - 前端路由探索
  - 路由
categories: 前端
top: false
copyright: true
date: 2018-07-12 15:24:24
---
本文由浅入深观摩vue-router源码是如何通过hash与History interface两种方式实现前端路由，介绍了相关原理，并对比了两种方式的优缺点与注意事项。最后分析了如何实现可以直接从文件系统加载而不借助后端服务器的Vue单页应用。
<!--more-->

**参考资料**
[【源码拾遗】从vue-router看前端路由的两种实现](https://zhuanlan.zhihu.com/p/27588422)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)