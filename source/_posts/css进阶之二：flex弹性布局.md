---
title: css进阶之二：flex弹性布局
tags:
  - dev
categories: dev
top: false
copyright: true
date: 2018-04-27 08:52:50
---
布局模式是指一个盒子与其兄弟、祖先盒的关系决定其尺寸与位置的算法。css2.1中定义了四种布局模式，分别是块布局、行内布局、表格布局、以及定位布局。css3引入了新的布局模式Flexbox布局，灵活度更高，可以让容器有能力改变子项目的宽高以及排序，以要求的方式填充可用空间，而且其方向有这不可预知性，使用非常灵活。
<!--more-->
## 基础知识

### 主轴与侧轴（交叉轴）
useragent沿着伸缩容器的主轴配置伸缩项目，从容器的主轴起点边开始往终点边结束。交叉轴的方向与主轴垂直。常规的布局是基于块和内联流方向，而flex布局是基于flex-flow流的。如下图中flexItem在水平方向排列，这样就说明水平方向是主轴，垂直方向就是交叉轴。
![](http://oankigr4l.bkt.clouddn.com/201804271139_706.png)
### 伸缩容器与伸缩项目
通过display属性，显式地给一个元素设置flex或者inline-flex。这个容器就是一个伸缩容器。注意设置为块级和行内元素。若一个元素指定为inline-flex且元素是一个浮动或者绝对定位元素，则display的计算值为flex。
一个伸缩容器内的每个子元素（盒修复元素？）都会成为一个伸缩项目。且用户代理会将任何直接在伸缩容器里的连续文字包起来成为匿名伸缩项目。

**伸缩容器的属性**
* 伸缩流方向：flex-direction，主轴方向，默认为row，和书写模式有关系（旧版本通过box-orient设置）
* 伸缩行换行：flex-warp,设置伸缩项目在溢出伸缩容器时，是单行还是多行显示（还可以决定交叉轴的方向？），默认是nowrap。类似传统盒模型的overflow属性处理溢出内容的显示方式，设置伸缩项目是否换行。
* 伸缩方向与换行：flex-flow,伸缩流的方向与伸缩换行的结合物。同时设置flex-direction与flex-warp
* 主轴对齐：伸缩项目在主轴方向上的对齐方式，如何在伸缩项目之间分布伸缩容器额外空间。
* 交叉轴对齐：指定伸缩项目当前行在伸缩容器中如何放置
* 堆栈伸缩行：伸缩项目行在布局轴的堆放方式

**伸缩项目的属性**
伸缩项目是一个伸缩容器的子元素，伸缩容器中的文本也被视为一个伸缩项目。伸缩项目中放置一个浮动元素也是可以的。伸缩项目有一个主轴长度和一个交叉轴的长度。
* 显示顺序：可以对伸缩项目进行排序组合
* 交叉轴对齐：对伸缩容器中包含匿名伸缩项目的所有项目设置对齐方式。可以用align-items,align-self
* 伸缩性：可以填补的可用空间

### 浏览器兼容性
经过查询结果如下：
![](http://oankigr4l.bkt.clouddn.com/201804271109_84.png)

兼容性并不好，且Flexbox有新旧版以及混合写法，可以说假如需要兼容旧版本的话可以说非常可怕了。
新版旧版可以用以下方法简单区分：
* display:box,或者box-{*}就是2009年版本
* display：flexbox，或者flex()函数，是2011年版本，也成为混合版本
* display：flex，或者flex-{*}属性，是当前的w3c标准规范的flexbox

flex语法规范的多样性造成在不同的语法版本下的使用方式不同，加上不同的浏览器支持度的不同，有兼容需求的同学一定要考虑清楚。

## 属性详解与使用
### 伸缩容器
#### flex-direction属性
决定主轴的方向（即项目的排列方向）。
```
flex-direction: row | row-reverse | column | column-reverse

row（默认值）：主轴为水平方向，起点在左端。
row-reverse：主轴为水平方向，起点在右端。
column：主轴为垂直方向，起点在上沿。
column-reverse：主轴为垂直方向，起点在下沿。
```
#### flex-wrap属性
决定怎么换行，是否换行
```
flex-wrap: nowrap | wrap | wrap-reverse;

nowrap（默认）：不换行。
wrap：换行，第一行在上方。
wrap-reverse：换行，第一行在下方。
```
#### flex-flow
flex-flow属性是flex-direction属性和flex-wrap属性的简写形式，默认值为row nowrap。
```
flex-flow: <flex-direction> || <flex-wrap>;
```

#### justify-content属性
justify-content属性定义了项目在主轴上的对齐方式。
```
justify-content: flex-start | flex-end | center | space-between | space-around;

flex-start（默认值）：左对齐
flex-end：右对齐
center： 居中
space-between：两端对齐，项目之间的间隔都相等。
space-around：每个项目两侧的间隔相等。所以，项目之间的间隔比项目与边框的间隔大一倍。
```
#### align-items属性
align-items属性定义项目在交叉轴上如何对齐。

```
 align-items: flex-start | flex-end | center | baseline | stretch;

flex-start：交叉轴的起点对齐。
flex-end：交叉轴的终点对齐。
center：交叉轴的中点对齐。
baseline: 项目的第一行文字的基线对齐。
stretch（默认值）：如果项目未设置高度或设为auto，将占满整个容器的高度。
```
#### align-content属性

align-content属性定义了多根轴线的对齐方式。如果项目只有一根轴线，该属性不起作用。

```
align-content: flex-start | flex-end | center | space-between | space-around | stretch;
```

**参考资料**
[]()

![](http://oankigr4l.bkt.clouddn.com/wexin.png)