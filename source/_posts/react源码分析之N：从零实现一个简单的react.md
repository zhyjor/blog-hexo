---
title: react源码分析之N：从零实现一个简单的react
tags:
  - react源码分析
  - react
categories: react
top: false
copyright: true
date: 2018-10-29 17:27:34
---
经过一段时间资料的收集，发现很少有高质量的介绍react源码的文章。掌握这个技能最好的方式就是阅读其源码并进行其最小子集的实现。本文先实现一个最简的react原型，后续介绍其源码中值得玩味的地方。
<!--more-->

## 前言
react源码还是很复杂的，直接看起来比较吃力，但是其核心内容却并不复杂，主要可以分为以下几个部分：
* 虚拟dom对象，对应vue里的VNode
* 虚拟dom diff算法
* 单向数据流的实现，类似vue里的数据劫持和watch
* 组件声明周期
* 事件处理

实现了这些基本一个react就实现了

**参考资料**
[React 深入系列5：事件处理](https://mp.weixin.qq.com/s?__biz=MzU1ODQ0NzM2NA==&mid=2247483706&idx=1&sn=7682fa5f5db94bc2e975f82c9060554e&chksm=fc272f51cb50a6473137d51daabaeb684b58e97898f12391d46dcf730b6f5ed06382aefc773c#rd)
[React事件系统和源码浅析](https://juejin.im/post/5bdf0741e51d456b8e1d60be)
[React源码解析(一):组件的实现与挂载](https://juejin.im/post/5983dfbcf265da3e2f7f32de)
[基于React版本16.2.0的源码解析（一）：组件实现（小白也可读）](https://juejin.im/post/5a9b95156fb9a028b86d7c4a)
[React 源码解析](https://zhuanlan.zhihu.com/p/28697362)

**[reactjs源码分析-上篇（首次渲染实现原理）](https://github.com/purplebamboo/blog/issues/2)**

**[《React源码解析》系列完结！](https://juejin.im/post/5a84682ef265da4e83266cc4)**

[React源码分析](https://icepy.gitbooks.io/react/content/di_yi_zhang_ff1a_mu_lu_yi_ji_wen_jian_fen_xi.html)

![](http://static.zhyjor.com/wexin.png)
