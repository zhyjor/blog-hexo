---
title: 玩转canvas之二：基本用法
tags:
  - 玩转canvas
  - canvas
  - 数据可视化
categories: 数据可视化
top: false
copyright: true
date: 2018-12-01 15:51:27
---
如何使用Canvas，比如怎么绘制图形，怎么做Canvas动画等。
<!--more-->

## Canvas坐标系统
在Canvas中有2D和3D之分，可以通过getContext('2d')让Canvas得到一个2D环境。言外之意，它还有一个3D环境。只不过我们现在只聊Canvas中的2D。这样一来，在Canvas中坐标系统也是有分的。

在Canvas中2D环境中其坐标系统和Web的坐标系统是一致的。坐标原点(0,0)在<canvas>画布的的左上角。同样的分为x和y两个轴。x轴向右为正值，y轴向下为正值。同样在canvas中，是没有办法直接看到。但同样，在canvas中使用负坐标不会导致canvas不能使用，只不过会移到canvas画布的外面。



**参考资料**
[]()

![](http://oankigr4l.bkt.clouddn.com/wexin.png)