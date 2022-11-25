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

##

**参考资料**
[]()

![](https://static.zhyjor.com/wexin.png)
