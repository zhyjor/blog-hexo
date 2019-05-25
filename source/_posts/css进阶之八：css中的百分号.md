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

## 为什么 border-width 不支持百分比值
虽然同属盒模型基本成员，但是 border-width 却不支持百分比。这一点和 margin 和padding 都不一样，下面问题来了：为什么border-width 不支持百分比呢？

* 首先看语义。顾名思义， border-width 是“边框宽度”，所谓“边框”，是不会因为设备大就按比例变大的。因此，如果支持百分比值，是不是就意味着设备大了边框也跟着变大？这显然不合“边框”的语义嘛！
* 然后再看使用场景，CSS 世界创造的背景主要是为图文展示服务的，我们给图片套个 1px 灰色边框，区域就明显了,没有需要使用百分比值的场景。

## line-height 
他的数值属性和百分比属性，都是是相对于 font-size 计算的

## vertical-align 
相对于 line-height 的计算值计算的，对于vertical-align默认的对齐方式时基线对齐。

vertical的对齐选择的属性值分为以下四类：
* 线类，如base-line,top
* 文本类，如text-top,text-bottom
* 上下标类，如sub,super
* 数值百分比类

数值的正负是相对于基线的上下位移，百分比则是相对于line-height的计算值

## font-size
父元素的font-size

## text-indent
百分比值是相对于当前元素的“包含块”计算的，而不是当前元素。

## background-position 百分比

支持 1～4 个值，可以是具体数值，也可以是百分比值，还可以是 left、top、 right、 center 和 bottom 等关键字.

其实就是相对于剩余空间的百分比

```js
positionX = (容器的宽度 - 图片的宽度) * percentX;
positionY = (容器的高度 - 图片的高度) * percentY;
```

**支持负的百分比**
假如图片宽度大于容器的话，会有些需要注意的地方：
```css
(容器的宽度−图片的宽度) × (-50%) 的结果是个正值；
(容器的高度−图片的高度) × (-50%) 的结果也是个正值。
```

**参考资料**
[你知道我们平时在CSS中写的%都是相对于谁吗？](https://juejin.im/post/5b0bc994f265da092918d421)


![](http://static.zhyjor.com/wexin.png)
