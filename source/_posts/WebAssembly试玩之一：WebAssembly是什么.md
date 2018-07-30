---
title: WebAssembly试玩之一：WebAssembly是什么
tags:
  - WebAssembly试玩
categories: WebAssembly
top: false
copyright: true
date: 2018-07-10 13:56:32
---
你可能已经听说过，WebAssembly 执行的更快。但是 WebAssembly 为什么执行的更快呢？要回答这个问题，我们还是要确定WebAssembly到底是什么。
<!--more-->

## WebAssembly是什么
WebAssembly 是除了 JavaScript 以外，另一种可以在浏览器中执行的编程语言。所以当人们说 WebAssembly 更快的时候，一般来讲是与 JavaScript 相比而言的。当然这里并不是暗示大家说开发时只能选择 WebAssembly或 JavaScript。实际上，我们更希望在同一个工程中，两个你同时使用。

## 一些关于性能的历史
JavaScript 于 1995 年问世，它的设计初衷并不是为了执行起来快，在前 10 个年头，它的执行速度也确实不快。

紧接着，浏览器市场竞争开始激烈起来。

被人们广为传播的“性能大战”在 2008 年打响。许多浏览器引入了 Just-in-time 编译器，也叫 JIT。基于 JIT 的模式，JavaScript 代码的运行渐渐变快。

正是由于这些 JIT 的引入，使得 JavaScript 的性能达到了一个转折点，JS 代码执行速度快了 10 倍。

![](http://oankigr4l.bkt.clouddn.com/201807301404_160.png)

随着性能的提升，JavaScript 可以应用到以前根本没有想到过的领域，比如用于后端开发的 Node.js。性能的提升使得 JavaScript 的应用范围得到很大的扩展。

现在通过 WebAssembly，我们很有可能正处于第二个拐点。

![](http://oankigr4l.bkt.clouddn.com/201807301406_200.png)

所以，接下来，我们深入了解一下为什么 WebAssembly 更快、执行效率更高。

**参考资料**
[WebAssembly 系列（一）：生动形象地介绍 WebAssembly](https://blog.csdn.net/GarfieldEr007/article/details/68215694)
[WebAssembly最新发展路线图来了！](https://mp.weixin.qq.com/s/CCIlP56acmBWe1KDkujNSQ)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)