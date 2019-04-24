---
title: react实践之一：按需加载与代码拆分
tags:
  - dev
categories: dev
top: false
copyright: true
date: 2018-11-16 10:27:19
---
打开这个之前做的[后台管理系统](http://www.zhyjor.com:9000/cms/index.html)，会发现首页打开特别慢，这很明显是按需加载没做好，根据腾讯的数据：**加载超过5秒就会有74%的用户离开页面**，首页的优化很有必要。
<!--more-->

**参考资料**
[React 16 ,webpack4加载性能优化指南](https://blog.csdn.net/sinat_17775997/article/details/81699437)

![](http://static.zhyjor.com/wexin.png)
