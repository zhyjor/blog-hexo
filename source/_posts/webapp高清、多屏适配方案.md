---
title: webapp高清、多屏适配方案
tags:
  - 适配
  - 前端
categories: 前端
top: false
copyright: true
date: 2017-10-13 10:05:15
---
其实对于移动端而言，不管是native app还是web app适配总是一个头疼的问题。像素在web开发中几乎天天用到，但到底什么是像素，**像素是一个相对长度还是绝对长度？**，移动端和pc端的像素有区别吗，retina屏和普通的屏幕有什么区别？让我们看下去。
<!--more-->
## 屏幕相关概念
其实对于移动端而言，不管是native app还是web app适配总是一个头疼的问题。像素在web开发中几乎天天用到，但到底什么是像素，**像素是一个相对长度还是绝对长度？**，移动端和pc端的像素有区别吗，retina屏和普通的屏幕有什么区别？让我们看下去。

### 什么是像素
“像素”（Pixel）为图像显示的基本单位，是用来计算数码影像的一种单位。译自英文“pixel”，pix是英语单词picture的常用简写，加上英语单词“元素”element，就得到pixel，故“像素”表示“图像元素”之意，有时亦被称为pel（picture element）。每个这样的信息元素不是一个点或者一个方块，而是一个抽象的采样。仔细处理的话，一幅图像中的像素可以在任何尺度上看起来都不像分离的点或者方块；但是在很多情况下，它们采用点或者方块显示。像素是网页布局的基础。一个像素就是计算机能够显示一种特定颜色的最小区域。当设备尺寸相同但像素变得更密集时，屏幕能显示的画面的过渡更细致，网站看起来更明快。
![](http://oankigr4l.bkt.clouddn.com/201805211521_476.png)

#### 像素分类
实际上像素分为两种：设备像素和CSS像素
* 物理像素(physical pixel)：物理像素又被称为设备像素，他是显示设备中一个最微小的物理部件。**每个像素可以根据操作系统设置自己的颜色和亮度。**
* 设备像素(device independent pixels): 设备独立像素也称为密度无关像素，可以认为是计算机坐标系统中的一个点，这个点代表一个可以由程序使用的虚拟像素(比如说CSS像素)，然后由相关系统转换为物理像素。
* CSS像素(CSS pixels): 又称为逻辑像素，是为web开发者创造的，在CSS和javascript中使用的一个抽象的层。一般情况之下，CSS像素称为与设备无关的像素(device-independent pixel)

每一个CSS声明和几乎所有的javascript属性都使用CSS像素，因此实际上从来用不上设备像素 

### 常见概念
* dip：Density independent pixels ，设备无关像素。
* dp：Android中，dp是Density-independent Pixels简写
* dpi：dots per inch ， 直接来说就是一英寸多少个像素点。常见取值 120，160，240。一般称作像素密度，简称密度（针对打印或者显示设备）
* ppi (pixels per inch)：图像分辨率 （在图像中，每英寸所包含的像素数目）
* 屏幕密度：屏幕密度是指一个设备表面上存在的像素数量，它通常以每英寸有多少像素来计算(PPI)。
* dpr设备像素比(device pixel ratio):设备像素比简称为dpr，其定义了物理像素和设备独立像素的对应关系。它的值可以按下面的公式计算得到：
**设备像素比 ＝ 物理像素 / 设备独立像素**
**参考资料**
[使用Flexible实现手淘H5页面的终端适配](https://github.com/amfe/article/issues/17)
[走向视网膜（Retina）的Web时代](http://www.w3cplus.com/css/towards-retina-web.html)

http://www.html-js.com/article/Mobile-terminal-H5-mobile-terminal-HD-multi-screen-adaptation-scheme%203041

http://www.w3cplus.com/css/when-to-use-em-vs-rem.html

https://segmentfault.com/a/1190000008774953
[]()

![](http://oankigr4l.bkt.clouddn.com/wexin.png)