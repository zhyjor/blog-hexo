---
title: Ant Design 5.0 正式发布了，你要升级吗
tags:
  - javascript
categories: javascript
top: false
copyright: true
date: 2022-11-18 14:31:46
---
周五了，这周忙里偷闲去了两天桐庐，淡季加上工作日，人好少。而且作为一个标准的江南小城，山青水秀，慢生活的基调就会让人整个松弛下来，即使就简单的在酒店附近走走，就已经是很舒服了。

好了，闲话少说，今天antd正式发布了5.0版本，笔者是antd重度用户，公司的B端业务组件就是基于antd定制开发的，在5.0发布之前，也在一直在关注beta版本，让我们一起看看5.0在技术上引入了什么新的变化吧

<!--more-->

本文不对设计的变化做评价，仅在技术选型、工程化等技术角度进行分析

## css-in-js
antd动态主题使用了css-in-js方案，抛弃了一直以来的less，放弃了css variables能力，这算是5.0引入的最大变化了，说到css-in-js旧不得不说最近关于css-in-js的一些争议

### css-in-js争议
最近由于Sam的那篇[Why We're Breaking Up with CSS-in-JS](https://dev.to/srmagura/why-were-breaking-up-wiht-css-in-js-4g9b)，直接将css-in-js推到了风口浪尖上，其实这个时候发布了强依赖css-in-js的5.0多少有些尴尬，官方也没有对这个问题进行过多的说明，只是复述了一下使用场景

归根结底，还是Sam这篇文章写的太客观，作为[Emotion](https://emotion.sh/docs/introduction)主要开发者，对css-in-js的有着更深的理解，很客观的说明了方案的优缺点，最后抛出弃用css-in-js最核心的原因：性能问题，这一点是无解的，css-in-js需要在react重渲染组件时序列化className，这就不可避免地带来运行时的性能损失

目前作者使用的方案是css module，除了在css中直接使用js变量需要特定的方式兼容外，其他css-in-js提供的有点，都可以直接兼容，并且没有性能的损失，这应该就是作者弃用css-in-js的核心原因了

### ant design 5.0用css-in-js做了什么
对于动态定制主题而言，关键也是在于如何在性能和维护成本之间做取舍，css-in-js方案可以直接在样式中使用js变量，这对定制主题而言确实可以省掉一些模版代码。and design 5.0使用了[@ant-design/cssinjs](https://github.com/ant-design/cssinjs)作为自己的css-in-js方案，打开源码去看看，star数暂时不多

**参考资料**
[]()

![](https://static.zhyjor.com/wexin.png)
