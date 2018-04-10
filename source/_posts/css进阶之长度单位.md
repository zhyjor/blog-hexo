---
title: css进阶之长度单位
tags:
  - css
  - css进阶
categories: css
copyright: true
date: 2018-03-22 19:37:24
---
`<length>`是表示距离尺寸的一种css数据格式。它由一个` <number> `后紧随一个长度单位（px，em，pt，in，mm，...）组成。和任何 CSS 尺寸一样，数字和单位之间没有空格。`<number>` 0之后的长度单位是可选的。

许多CSS属性使用<length>值，比如width、margin、padding、font-size、border-width、text-shadow...

对于某些属性，长度使用负值会有语法错误，但是有一些属性是允许负长度的。请注意虽然<percentage>也是CSS尺寸并且可以被一些 CSS属性接受为`<length>`值，但它们本身不是`<length>`值。
<!--more-->

### 相对长度单位
#### 相对字体大小单位

**em**
相对长度单位，这个单位表示元素的font-size的计算值。如果用在font-size 属性本身，它会继承父元素的font-size。
> 这个单位常用于创建可伸缩布局，这样即便用户更改了字体尺寸，也可以保持 vertical rhythm of the page。CSS属性line-height，font-size，margin-bottom和margin-top常具有一个用em表示的值。

**ex**
这个单位表示元素font的 x-height 。在含有“X”字母的字体中，它是该字体的小写字母的高度；对于很多字体， 1ex ≈ 0.5em。

**ch**
这一单位代表元素所用字体 font中“0”这一字形的宽度（“0”，Unicode字符U+0030），或更准确地说是“0”这一字形的预测尺寸（advance measure）。

**rem**
这个单位代表根元素的 font-size 大小（例如 <html> 元素的font-size）。当用在根元素的font-size上面时 ，它代表了它的初始值(译者注:默认的初始值是html的默认的font-size大小,比如当未在根元素上面设置font-size大小的时候,此时的1rem==1em,当设置font-size=2rem的时候,就使得页面中1rem的大小相当于html的根字体默认大小的2倍,当然此时页面中字体的大小也是html的根字体默认大小的2倍)。
> 该单位在实际使用中一般用于创建完美的可扩展布局。如果不被目标浏览器支持，可以使用em单位，虽然会稍微复杂一些。

**lh**
等于元素行高line-height的计算值

**rlh**
等于根元素行高line-height的计算值。当用于设置根元素的行高line-height或是字体大小font-size 时，该rlh指的是根元素行高line-height或字体大小font-size 的初始值

#### 视口比例的长度
视口比例长度定义了相对于视口的长度大小，视口即文档可视的部分。 当视口的大小被修改（通过更改桌面计算机窗口大小或旋转手机或平板设备的方向）时，只有基于Gecko的浏览器才动态更新视口值。

如果html和body设置了overflow:auto，滚动条占据的空间不会从视口中减去（译者注：大概就是说会算在视口里，视口大小是包括滚动条的），但当设置为overflow:scroll时，滚动条占据的空间反而会从视口中减去（译者注：大概就是此时视口大小不包括滚动条）。

overflow:auto，滚动条最终占用的空间大小不是减去视口大小之后的宽度，而 overflow:scroll 才是。

在 @page 在规则声明块的长度，视口使用无效，声明将被丢弃。

**vh**
视口高度的 1/100。

**vw**
视口宽度的 1/100。

**vi**
Equal to 1% of the size of the initial containing block, in the direction of the root element’s inline axis（axis:轴）.

**vb**
Equal to 1% of the size of the initial containing block, in the direction of the root element’s block axis（axis:轴）.

**vmin**
视口高度和宽度之间的最小值的 1/100。

**vmax**
视口高度和宽度之间的最大值的 1/100。


### 绝对长度单位
绝对长度单位代表一个物理测量，当输出介质的物理性质是已知的，如用于打印布局。这是通过将一个单元锚定到一个物理单元，并将其定义为相对于它的另一个。对于低分辨率的设备，如屏幕、高分辨率设备，如打印机，该锚定是不同的。

低DPI设备，单位像素代表物理参考像素和其他人是指相对于它。因此，在定义为96px等于72pt。这个定义的结果是，在这样的设备，长度在英寸（in），厘米（cm），毫米（mm），没有必要匹配的物理单位的长度相同的名称。

高DPI设备，英寸（in），厘米（cm），毫米（mm）被定义为他们对应的实体。因此，px单位和他们相关（1 / 96 英寸）。

> 用户可以增加字体大小，用于辅助功能。为了允许使用的布局，无论是所使用的字体大小，只使用绝对长度单位时，输出介质的物理特性是已知的，如位图图像。设置字体大小相关的长度时，更喜欢相对单位像EM或REM。

**px**
与显示设备相关。
对于屏幕显示，通常是一个设备像素（点）的显示。
对于打印机和高分辨率的屏幕，一个CSS像素意味着多个设备像素，因此，每英寸的像素的数量保持在96左右。

**mm**
毫米。

**cm**
厘米（10毫米）。

**in**
英寸（2.54厘米）。

**pt**
磅（1/72 英寸）。

**pc**
12 点活字 (1 pc 等于 12 点)。

**mozmm **
一个实验单位，无论显示器的尺寸或分辨率如何，都会尝试在一毫米处进行渲染。很少会用到，但可能在移动设备特别有用。

### CSS 单位和每英寸点数（DPI）

> CSS 的单位不是根据物理上的英寸来表现的，而是表现为 96px（译注：这里指的应该是 1in = 96px）。这意味着无论真实屏幕的像素密度是多少，（在 CSS 中）它都假设为 96dpi。在一个高像素密度的设备中，1in 会小于实际的 1 物理英寸。类似地 mm、cm 和 pt 都不是一个绝对的长度单位。

一些具体的例子：

* 1in 总是（等于）96px
* 3pt 总是（等于）4px
* 25.4mm 总是（等于）96px

**参考资料**
[`<length>`](https://developer.mozilla.org/zh-CN/docs/Web/CSS/length#px)
[CSS的长度单位-w3c](https://www.w3cplus.com/css/the-lengths-of-css.html)


![](http://oankigr4l.bkt.clouddn.com/wexin.png)