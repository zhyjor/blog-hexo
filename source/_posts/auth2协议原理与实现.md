---
title: auth2协议原理与实现
tags:
  - dev
categories: dev
top: false
copyright: true
date: 2020-12-12 10:42:05
---
OAuth只是一个授权协议，不是一个实现或是一个中间件。

OAuth协议是一个授权的开放协议，主要是用来解决第三方登录的
<!--more-->
auth1协议在处理签名上更加繁琐，而且不够通用，优化后的版本更简单

**参考资料**
[OAuth2.0原理和验证流程分析](https://www.jianshu.com/p/d74ce6ca0c33)

![](http://static.zhyjor.com/wexin.png)