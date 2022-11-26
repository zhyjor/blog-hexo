---
title: 我是如何从eggjs升级到midwayjs的
tags:
  - nodejs,eggjs,midwayjs,前端
categories: node
top: false
copyright: true
date: 2022-11-25 14:46:47
---
今天突然发现园区的银杏叶突然全黄了，想起来两周前到临安去玩的时候还是青黄交加的一片呢。虽然最近温度似乎也没怎么降，但从最近路边的落叶上看，真的是深秋了，可能就再需要一场秋雨，杭州就要开始入冬了吧

最近笔者在维护一个旧的node项目，项目基于eggjs开发的，数据库是mysql，缓存redis，消息中间件用的是rocketMQ。项目早期用的是js，在改造typescript的过程中，越来越感觉到eggjs对typescript兼容性不好，加上midwayjs的Ioc机制是开发中的一个爽点，还是决定畅通不如短痛，升级midwayjs

<!--more-->

## midwayjs简介
先放[官方文档](https://midwayjs.org/docs/intro)传送门

> Midway 是阿里巴巴 - 淘宝前端架构团队，基于渐进式理念研发的 Node.js 框架，通过自研的依赖注入容器，搭配各种上层模块，组合出适用于不同场景的解决方案

先看看关键字，**依赖注入**，对于前端同学来说，这是个相对陌生的点。也难怪，日常开发中这些使用的确实不多，java同学会了解的相对多一点，毕竟IoC能力是Java Spring 体系中非常重要的核心，而这也是MidWay的核心竞争力了。另外Midway全量使用TypeScript，结合TS装饰器，让开发体验有质的提升。项目使用中类型推导很好用，这对日常维护能起到非常正面的作用。下面是一个简单的🌰
·

### 为什么不是nestjs
社区内还有类似的[nestjs框架](https://docs.nestjs.com/)，两者都是走的IoC方式，两者都是框架的封装（midwayjs-->eggjs-->koajs,nestjs-->express.js，当然midwayjs支持切换依赖的web框架），提供一些开发中过于模版化的能力，简化日常开发中的配置复杂度，让你更能专注于业务，两者并没有什么本质上的区别。midwayjs是阿里的团队开源的，nestjs是国外Trilon团队的，性能上没有做对比，应该也不会有太大的差异，没必要太纠结具体去用哪个框架

所以笔者并不太在意到底用什么框架，但是团队内的同学更熟悉eggjs，eggjs到midwayjs的学习曲线相对平滑，而且midway的文档更友好一些，基于后续维护成本的考虑，在体验并没有打折的情况下，就选定了midwayjs了

接下来先看看IoC机制，以及Typescript装饰器是什么

## IoC机制
IoC（Inversion of Control）即是“控制反转”，这并非是一种技术，是面向对象编程的一种设计思想。在Java中，IoC意味着你将设计好的对象交给容器控制，而不是在对象内直接控制，理论很抽象，看个🌰
```js

```
##  Typescript装饰器


**参考资料**
[控制反转（IOC）和依赖注入（DI）的关系](https://developer.aliyun.com/article/680405)

![](https://static.zhyjor.com/wexin.png)
