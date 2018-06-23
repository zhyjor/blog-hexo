---
title: css进阶之十一：内联盒模型中的幽灵空白节点
tags:
  - css进阶
  - css
categories: css
top: false
copyright: true
date: 2018-06-23 16:45:52
---
“幽灵空白节点”是内联盒模型中非常重要的一个概念，具体指的是：在 HTML5 文档声明中，内联元素的所有解析和渲染表现就如同每个行框盒子的前面有一个“空白节点”一样。这个“空白节点”永远透明，不占据任何宽度，看不见也无法通过脚本获取，就好像幽灵一样，但又确确实实地存在，表现如同文本节点一样，因此，我称之为“幽灵空白节点”。
<!--more-->

**注意，这里有一个前提，文档声明必须是 HTML5 文档声明（HTML 代码如下），如果还是很多年前的老声明，则不存在“幽灵空白节点”**
```html
<!doctype html>
<html>
```
## 栗子
我们可以举一个最简单的例子证明“幽灵空白节点”确实存在， CSS 和 HTML 代码如下：
```html
div {
	background-color: #cd0000;
}
span {
	display: inline-block;
}
<div><span></span></div>
```
结果，此`<div>`的高度并不是 0，作祟的就是这里的“幽灵空白节点”，如果我们认为在`<span>`元素的前面还有一个宽度为 0 的空白字符，是不是一切就解释得通呢？

## 规范中怎么解释
规范中实际上对这个“幽灵空白节点”是有提及的，“幽灵空白节点”实际上也是一个盒子，不过是个假想盒，名叫“strut”，中文直译为“支柱”，是一个存在于每个“行框盒子”前面，同时具有该元素的字体和行高属性的 0 宽度的内联盒。规范中的原文如下：
> Each line box starts with a zero-width inline box with the element’s font and line height properties. We call that imaginary box a “strut”.

明白“幽灵空白节点”的存在是理解后续很多内联元素为何会这么表现的基础。

**参考资料**
[]()

![](http://oankigr4l.bkt.clouddn.com/wexin.png)