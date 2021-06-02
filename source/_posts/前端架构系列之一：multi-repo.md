---
title: 前端架构系列之一：multi-repo
tags:
  - 前端架构
  - 前端
  - lerna
categories: 前端
top: false
copyright: true
date: 2021-05-25 10:47:12
---
在开发维护npm包的时候，在包的数量还比较少的时候维护起来并没有什么问题，但是当package的数量增加是，比如babel的那种地狱级的包数量，已经很难用多个仓库去维护，且package需要相互link+版本升级的时候，需要对处理方案进行收敛
<!--more-->

**参考资料**
[lerna管理前端packages的最佳实践](http://www.sosout.com/2018/07/21/lerna-repo.html)

![](http://static.zhyjor.com/wexin.png)