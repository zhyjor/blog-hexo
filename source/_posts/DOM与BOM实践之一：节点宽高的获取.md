---
title: DOM与BOM实践之一：节点宽高的获取
tags:
  - DOM与BOM实践
  - js
categories: js
top: false
copyright: true
date: 2018-07-11 11:04:42
---
网页可见区域宽或高、网页正文全文宽或高以及网页正文部分左或右
<!--more-->



```
网页可见区域宽： document.body.clientWidth 
网页可见区域高： document.body.clientHeight 
网页可见区域宽： document.body.offsetWidth (包括边线的宽) 
网页可见区域高： document.body.offsetHeight (包括边线的高) 
网页正文全文宽： document.body.scrollWidth 
网页正文全文高： document.body.scrollHeight 
网页被卷去的高： document.body.scrollTop 
网页被卷去的左： document.body.scrollLeft 
网页正文部分上： window.screenTop 
网页正文部分左： window.screenLeft 
屏幕分辨率的高： window.screen.height 
屏幕分辨率的宽： window.screen.width 
屏幕可用工作区高度： window.screen.availHeight 
屏幕可用工作区宽度： window.screen.availWidth 
```

注意内联元素没有可视宽度可视高度的说法（clientHeight,clientWidht永远是0）

在jquery中也有相应的获取尺寸的api
**元素尺寸：**$().width()，$().height()包括padding,border，类似offsetwidht

**元素内部尺寸：**对应$().innerWidth()表示内部区域，包括padding，不包括border,对应clientHeight，也称为元素可视尺寸

**元素外部尺寸：**对应$().outerWidth(true)还包括margin，没有原生的dom api

这里需要注意外部尺寸是个有可能是负数的值，物体的尺寸不会是负数，这里可以理解为是元素占据的空间尺寸，将尺寸理解为空间。



**参考资料**
[js获取dom的高度和宽度(可见区域及部分等等)](https://www.jb51.net/article/38419.htm)

![](http://static.zhyjor.com/wexin.png)
