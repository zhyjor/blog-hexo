---
title: koa与express分析与实践之二：深入理解koa
tags:
  - koa与express分析与实践
categories: 后端
top: false
copyright: true
date: 2018-07-10 10:14:35
---
Koa 就是一种简单好用的 Web 框架。它的特点是优雅、简洁、表达力强、自由度高。本身代码只有1000多行，所有功能都通过插件实现，很符合 Unix 哲学。本文，我们不介绍初级的用法，主要介绍常用模块、以及中间件的使用，了解koa的源码实现。
<!--more-->
## 常用的模块
### koa-route 模块
通过ctx.request.path可以获取用户请求的路径，由此实现简单的路由。
```js
const main = ctx => {
  if (ctx.request.path !== '/') {
    ctx.response.type = 'html';
    ctx.response.body = '<a href="/">Index Page</a>';
  } else {
    ctx.response.body = 'Hello World';
  }
};
```
原生路由用起来不太方便，我们可以使用封装好的[koa-route模块](https://www.npmjs.com/package/koa-route)。





**参考资料**
[]()

![](http://oankigr4l.bkt.clouddn.com/wexin.png)