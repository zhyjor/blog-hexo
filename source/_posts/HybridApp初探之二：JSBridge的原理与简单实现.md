---
title: HybridApp初探之二：JSBridge的原理与简单实现
tags:
  - HybridApp初探
  - HybridApp
categories: HybridApp
top: false
copyright: true
date: 2017-10-26 09:28:27
---
JSBridge是Native代码与JS代码的通信桥梁。目前的一种统一方案是:H5触发url scheme->Native捕获url scheme->原生分析,执行->原生调用h5。
<!--more-->

**参考资料**
[Hybrid APP基础篇(四)->JSBridge的原理](https://www.cnblogs.com/dailc/p/5931324.html)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)