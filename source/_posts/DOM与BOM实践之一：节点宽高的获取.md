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


**参考资料**
[js获取dom的高度和宽度(可见区域及部分等等)](https://www.jb51.net/article/38419.htm)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)