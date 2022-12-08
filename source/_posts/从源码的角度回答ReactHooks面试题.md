---
title: 从源码的角度回答ReactHooks面试题
tags:
  - React
  - js
categories: js
top: false
copyright: true
date: 2022-12-08 13:47:37
---
杭州已经不看健康码了，某种程度上来说YQ已经结束了，但某种程度上YQ又刚刚开始。无论是谁在这个冬天都要保护好自己，明年春暖花开的时候，肯定就是真正的春天到了

闲言少叙，开始正文
<!--more-->

## 前言
上篇文章[《都React V18了，还不会正确使用React Hooks吗，万字长文解析Hooks的常见问题》](https://juejin.cn/post/7172903844366516260)说到了React Hooks的一些常见问题，本文让我们继续深入react hooks，结合几个常见的面试题，从源码角度分析一下react hooks，从源码的角度回答一下这些问题。

## 问题一：为什么不要在循环，条件或嵌套函数中调用Hook

## 问题二：hooks的依赖跟踪是怎么实现的

**参考资料**
[React hooks: not magic, just arrays](https://medium.com/@ryardley/react-hooks-not-magic-just-arrays-cd4f1857236e)

![](https://static.zhyjor.com/wexin.png)
