---
title: 跟着underscore写代码之二：实现一个表单操作
tags:
  - 跟着underscore写代码
  - js
categories: js
top: false
copyright: true
date: 2018-06-21 10:13:21
---
随着开发的深入，对表单的理解也逐渐有些不同，一个好的组件库，需要一个优秀的表单处理逻辑，验证安全，使用方便，可维护是基本的属性。
<!--more-->
## button
按钮就是 CSS 世界中极具代表性的 inline-block 元素，可谓展示“包裹性”最好的例子，具体表现为：按钮文字越多宽度越宽（内部尺寸特性），但如果文字足够多，则会在容器的宽度处自动换行（自适应特性）。`<button>`标签按钮才会自动换行， `<input>`标签按钮，默认 `white-space:pre`，是不会换行的，需要将 pre 值重置为默认的 normal。

**参考资料**
[]()

![](http://oankigr4l.bkt.clouddn.com/wexin.png)