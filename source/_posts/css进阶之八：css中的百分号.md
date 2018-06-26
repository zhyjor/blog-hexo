---
title: css进阶之八：css中的百分号
tags:
  - css
  - css进阶
categories: css
top: false
copyright: true
date: 2018-06-04 16:36:10
---
在我们编写CSS的时候，经常会用到百分比赋值（%）实现自适应。像我们最常使用的流式布局设计模式，基本所有的column的宽度都是通过%来取值的。或者比如经常会遇到的元素水平垂直居中问题，我们常常会使用下面这样的CSS代码加以实现（absolute+transform思路）：

<!--more-->
## padding 的百分比值
关于 padding 的属性值
* 其一，和 margin 属性不同， padding 属性是不支持负值的；
* 其二， padding 支持百分比值，但是，和 height 等属性的百分比计算规则有些差异，差异在于： padding 百分比值无论是水平方向还是垂直方向均是相对于宽度计算的！

## margin 的百分比值
和 padding 属性一样， margin 的百分比值无论是水平方向还是垂直方向都是相对于宽度计算
的。不过相对于 padding， margin 的百分比值的应用价值就低了一截，根本原因在于和padding不同，元素设置 margin 在垂直方向上无法改变元素自身的内部尺寸，往往需要父元素作为载体，此外，由于 margin 合并的存在，垂直方向往往需要双倍尺寸才能和 padding 表现一致。例如：

```css
.box {
	background-color: olive;
	overflow: hidden;
}
.box > div {
	margin: 50%;
}
```
结果**.box 是一个宽高比为 2:1 的橄榄绿长方形。**是不是有点儿奇怪： 50%+50%应该是 100%，应该上下一样，是 1:1 的正方形，怎么最后是 2:1 的长方形呢？这就涉及margin 合并的内容了。




**参考资料**
[你知道我们平时在CSS中写的%都是相对于谁吗？](https://juejin.im/post/5b0bc994f265da092918d421)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)