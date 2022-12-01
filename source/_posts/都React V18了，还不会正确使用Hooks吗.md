---
title: 都React V18了，还不会正确使用Hooks吗
tags:
  - React
  - js
categories: React
top: false
copyright: true
date: 2022-12-01 14:13:21
---
杭州下雪了，想去西湖看雪了，雪后的杭州更有水墨画里的感觉了，一下雪杭州就成了临安

今天主要想说一下react hooks，react hooks是react v16.8 之后引入的API，现在react都已经到18了，hooks怎么还能不会用呢。hooks引入的目的是给函数式组件增加数据状态管理的能力，同时增加代码的可复用能力。但是同时hooks也是一个潘多拉魔盒，因为函数式组件不再只是单纯的一个纯函数了，可以在内部处理副作用了，使用不好就会经常遇到各种各样的问题，而且错误的使用方式也会引起re-render，引起一些性能上的问题

本文主要介绍hooks的常见的几个问题与最优实践，同时介绍一下随着react版本迭代的API的变化

闲言少叙，直接进入正文
<!--more-->
##


**参考资料**

![](http://static.zhyjor.com/wexin.png)
