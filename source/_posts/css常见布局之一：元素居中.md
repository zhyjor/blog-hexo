---
title: css常见布局之一：元素居中
tags:
  - css
  - css常见布局
categories: css
top: false
copyright: true
date: 2018-04-20 15:26:23
---
css中居中是个永恒的话题，“人类都已经可以登上月球，但还实现不了垂直居中”。当然不是实现不了，是各种实现的方法都需要太多条件。本文将块级，内联级元素以及可替换元素的各种居中方法一一解读，希望给大家带来思路。
<!--more-->

### 绝对布局的margin:auto法
由于绝对定位元素的格式化高度即使父元素 height:auto 也是支持的，因此，其应用场
景可以相当广泛，可能唯一的不足就是此居中计算 IE8 及以上版本浏览器才支持。至少对我来
讲，如果项目无须兼容 IE7 浏览器，绝对定位下的 margin:auto 居中是我用得最频繁的块级
元素垂直居中对齐方式

### translation 50%法
比 top:50%然后 margin 负一半元素高度的方法要好使得多。

### 内联元素（小图标）的1ex法

### 为什么 line-height 可以让内联元素“垂直居中”
**参考资料**
[]()

![](http://oankigr4l.bkt.clouddn.com/wexin.png)