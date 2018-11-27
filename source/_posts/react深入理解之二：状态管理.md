---
title: react深入理解之二：状态管理
tags:
  - react深入理解
  - react
categories: react
top: false
copyright: true
date: 2018-10-14 10:24:28
---
状态管理换句话说就是数据传递，父子，兄弟组件间的数据如何相互获取，如何管理这些状态，都是状态管理需要做的。在react中，被多个组件依赖和影响的状态需要进行状态的提升，升级到父组件进行状态的管理，但是在实际的项目中，随着项目复杂度的提高，这并不是一个好方法。社区有很多解决方案，比如redux、DvaJS等等。
<!--more-->

## 父组件的context


**参考资料**
[]()

![](http://oankigr4l.bkt.clouddn.com/wexin.png)