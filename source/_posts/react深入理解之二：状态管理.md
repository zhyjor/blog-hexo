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
状态管理换句话说就是数据传递，父子，兄弟组件间的数据如何相互获取，如何管理这些状态，都是状态管理需要做的。在react中，被多个组件依赖和影响的状态需要进行状态的提升，升级到父组件进行状态的管理，但是在实际的项目中，随着项目复杂度的提高，这并不是一个好方法。社区有很多解决方案，比如redux、DvaJS等等。状态管理很重要
<!--more-->

##  定义组件间的接口
简单说来，就是要减少组件之间的耦合性（Coupling)，让组件的界面简单，这样才能让整体系统易于理解、易于维护。

更具体一点，在设计 React 组件时，要注意以下原则：

* 保持接口小，props 数量要少；
* 根据数据边界来划分组件，充分利用组合（composition）；
* 把 state 往上层组件提取，让下层组件只需要实现为纯函数。



## 父组件的context


**参考资料**
[React 16 加载性能优化指南](https://juejin.im/post/5b506ae0e51d45191a0d4ec9)
[webpack详解](https://juejin.im/post/5aa3d2056fb9a028c36868aa)
[请问一下 effects 中 yield put() 是一个非阻塞过程，如何做到 effects 中阻塞调用另一个 effect](https://github.com/dvajs/dva/issues/1212)

![](http://static.zhyjor.com/wexin.png)
