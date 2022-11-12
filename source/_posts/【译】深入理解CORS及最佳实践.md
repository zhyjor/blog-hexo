---
title: 【译】深入理解CORS及最佳实践
tags:
  - dev
categories: dev
top: false∏
copyright: true
date: 2021-05-31 10:57:14
---
5月，将将入夏的天气让人感觉慵懒，这又和最近的忙碌的工作状态形成了对比。特别想在这种刚刚开始热的时候出去玩，一切都是充满生机的样子，没有暑夏的沉闷和无聊。好了，💐不多说，今天搬运一篇写的很好的文章，也在深入理解一下CORS。
<!--more-->
[原文地址-Deep dive in CORS: History, how it works, and best practices](https://ieftimov.com/post/deep-dive-cors-history-how-it-works-best-practices/)

写本文的目的是了解`同源策略`和CORS的历史演进，深入理解CORS和跨域访问的几种类型，了解CORS的最佳实践

## 出现在浏览器console的报错
> No ‘Access-Control-Allow-Origin’ header is present on the requested resource.

> Cross-Origin Request Blocked: The Same Origin Policy disallows reading the remote resource at https://example.com/

> Access to fetch at ‘https://example.com’ from origin ‘http://localhost:3000’ has been blocked by CORS policy.

几乎所有的开发者都会在浏览器的控制台看到过这些报错，

**参考资料**
[]()

![](http://static.zhyjor.com/wexin.png)
