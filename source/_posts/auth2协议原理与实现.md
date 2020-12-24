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

auth2协议分两种，基于token和基于code两种，基于code的方式是服务端获取token的方式，基于token的方式是无服务端的场景，前端直接获取token，用来获取资源服务器的资源

## Q 
目前遇到的问题是gitlab回跳有问题

gitlab回跳的时候遇到无法跳转的问题

**参考资料**
[OAuth2.0原理和验证流程分析](https://www.jianshu.com/p/d74ce6ca0c33)
[The OAuth 2.0 Authorization Framework](https://tools.ietf.org/html/rfc6749)
[Auth 2.0 协议原理与实现：协议原理](https://my.oschina.net/wangzhenchao/blog/851773)
[Run your own OAuth2 Server](https://www.ory.sh/run-oauth2-server-open-source-api-security/)

![](http://static.zhyjor.com/wexin.png)