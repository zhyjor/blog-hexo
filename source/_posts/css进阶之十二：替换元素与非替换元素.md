---
title: css进阶之十二：替换元素与非替换元素
tags:
  - css进阶
  - css
categories: css
top: false
copyright: true
date: 2018-06-24 14:57:31
---
CSS 世界中的替换元素和非替换元素看上去也是两个对立的派别，立场清晰，区分明显，老死不相往来的感觉，但是，一旦深入研究我们就会发现，两者之间的距离要比我们所有人想象得都要近！
<!--more-->

## 替换元素和非替换元素之间只隔了一个 src 属性！
由于我们平时使用图片肯定都会使用 src 属性，所以难免会思维定式，认为`<img>`等同于图片，实际上完全不是的。如果我们把 src 属性去掉，`<img>`其实就是一个和`<span>`类似的普通的内联标签，也就是成了一个非替换元素。

## 替换元素和非替换元素之间只隔了一个 CSS content 属性！
替换元素之所以为替换元素，就是因为其内容可替换，而这个内容就是 margin、 border、padding 和 content 这 4 个盒子中的 content box，对应的 CSS 属性是 content，所以，从理论层面讲， content 属性决定了是替换元素还是非替换元素。

**参考资料**
[]()

![](http://oankigr4l.bkt.clouddn.com/wexin.png)