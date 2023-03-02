---
title: 开发者需要弄懂的 Babel Polyfill
tags:
  - Babel
  - PWA
categories: Babel
top: false
copyright: true
date: 2023-03-02 11:11:20
---
楼下的白玉兰花开了，树梢已经悄悄爬到了6楼高了，一树的玉兰花开的特别热烈。在家里的阳台上就能看到，仔细闻还能花香。春风不燥，阳光正好，春天也终于到了

今天分享一下Babel Polyfill的一些使用的总结。闲言少叙，进入正题

本文主要解答两个问题
1. 我是业务开发者，我该如何配置Polyfill
2. 我是Library开发者，我该如何配置Polyfill

<!--more-->
## 前言
作为前端开发者，babel配置问题是一个绕不开的问题，也是一个相对复杂的问题，因为babel有太多的包了，比如：`@babel/preset-env`、`@babel/plugin-transform-runtime`、`@babel/runtime`、`core-js`、`@babel/polyfills`、`babel-polyfills`等等。

很多时候脚手架比如CRA、dva等，已经帮我们完成了项目最初的配置了，让我们能做到开箱即用，这样隐藏了一些配置，让Babel配置变得更黑盒，当我们想手动改一些配置的时候就会遇到很多奇奇怪怪的错误。想手动配置好一个项目，或者想学习一下babel的配置，就需要先弄懂这些包都是做什么的，正式解决本文的两个问题之前，先简单了解一下相关的基础知识

### @babel/preset-env
从 babel@v7 开始，正式移除了对 stage presets 的支持，提供了新的`@babel/preset-env`方案，这里贴上官方的解释[Removing Babel's Stage Presets](https://babeljs.io/blog/2018/07/27/removing-babels-stage-presets)。主要原因是维护基于stage0-state4的方案维护成本过高，另外就是过早的提供某些提案的支持，可能存在被滥用的风险。

> @babel/preset-env is a smart preset that allows you to use the latest JavaScript without needing to micromanage which syntax transforms (and optionally, browser polyfills) are needed by your target environment(s). This both makes your life easier and JavaScript bundles smaller!

通过[官方文档](https://babeljs.io/docs/babel-preset-env.html)的描述，我们可以看到`@babel/preset-env` 做的是按需转换 JavaScript 最新的 syntax（主要指一些关键字），同时可以通过配置支持 JavaScript 中的一些最新的api（比如Array.from等）。index

## 补充知识

