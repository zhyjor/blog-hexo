---
title: css进阶之二：flex弹性布局
tags:
  - css进阶
  - css
  - flex布局
categories: css
top: false
copyright: true
date: 2018-04-27 08:52:50
---
布局模式是指一个盒子与其兄弟、祖先盒的关系决定其尺寸与位置的算法。css2.1中定义了四种布局模式，分别是块布局、行内布局、表格布局、以及定位布局。css3引入了新的布局模式Flexbox布局，灵活度更高，可以让容器有能力改变子项目的宽高以及排序，以要求的方式填充可用空间，而且其方向有这不可预知性，使用非常灵活。
<!--more-->

本文的最佳实践：[twibo-vue](https://github.com/zhyjor/twibo-vue)

## 基础知识

### 方向：主轴与交叉轴（侧轴）
useragent沿着伸缩容器的主轴配置伸缩项目，从容器的主轴起点边开始往终点边结束。交叉轴的方向与主轴垂直。常规的布局是基于块和内联流方向，而flex布局是基于flex-flow流的。如下图中flexItem在水平方向排列，这样就说明水平方向是主轴，垂直方向就是交叉轴。
![](http://oankigr4l.bkt.clouddn.com/201804271139_706.png)
### 容器：伸缩容器与伸缩项目
通过display属性，显式地给一个元素设置flex或者inline-flex。这个容器就是一个伸缩容器。注意设置为块级和行内元素。若一个元素指定为inline-flex且元素是一个浮动或者绝对定位元素，则display的计算值为flex。
一个伸缩容器内的每个子元素（盒修复元素？）都会成为一个伸缩项目。且用户代理会将任何直接在伸缩容器里的连续文字包起来成为匿名伸缩项目。

## 属性详解与使用
在查资料的的时候发现一张图很好的展示了flex的各个属性：
图片来源[《一劳永逸的搞定 flex 布局》](https://juejin.im/post/58e3a5a0a0bb9f0069fc16bb)
![](http://oankigr4l.bkt.clouddn.com/201804281028_360.png)
### 容器的属性
有六个属性可以作用到容器上
* flex-direction
* flex-wrap
* flex-flow
* justify-content
* align-items
* align-content
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

flex-start：与交叉轴的起点对齐。
flex-end：与交叉轴的终点对齐。
center：与交叉轴的中点对齐。
space-between：与交叉轴两端对齐，轴线之间的间隔平均分布。
space-around：每根轴线两侧的间隔都相等。所以，轴线之间的间隔比轴线与边框的间隔大一倍。
stretch（默认值）：轴线占满整个交叉轴。
```

### 项目的属性
有6个属性，可以设置在项目上。
* order
* flex-grow
* flex-shrink
* flex-basis
* flex
* align-self

#### order属性
order属性定义项目的排列顺序。数值越小，排列越靠前，默认为0。
```
order: <integer>;

```
#### flex-grow属性
flex-grow属性定义项目的放大比例，默认为0，即如果存在剩余空间，也不放大。
```
 flex-grow: <number>; /* default 0 */
```
如果所有项目的flex-grow属性都为1，则它们将等分剩余空间（如果有的话）。如果一个项目的flex-grow属性为2，其他项目都为1，则前者占据的剩余空间将比其他项多一倍。

#### flex-shrink属性
flex-shrink属性定义了项目的缩小比例，默认为1，即如果空间不足，该项目将缩小。
```
flex-shrink: <number>; /* default 1 */
```
如果所有项目的flex-shrink属性都为1，当空间不足时，都将等比例缩小。如果一个项目的flex-shrink属性为0，其他项目都为1，则空间不足时，前者不缩小。

**负值对该属性无效。**

#### flex-basis属性
flex-basis属性定义了在分配多余空间之前，项目占据的主轴空间（main size）。浏览器根据这个属性，计算主轴是否有多余空间。它的默认值为auto，即项目的本来大小。
```
flex-basis: <length> | auto; /* default auto */
```
它可以设为跟width或height属性一样的值（比如350px），则项目将占据固定空间。也就是说这个属性固定了项目在主轴方向上的控制范围，用这个值去计算怎么算剩余空间，但是呢，**假如设置固定值了，即使有空余空间的分配，也和该项目没关系了？**

####  flex属性
flex属性是flex-grow, flex-shrink 和 flex-basis的简写，默认值为0 1 auto。后两个属性可选。
```
flex: none | [ <'flex-grow'> <'flex-shrink'>? || <'flex-basis'> ]
```
该属性有两个快捷值：auto (1 1 auto) 和 none (0 0 auto)。

第一种写法是项目在主轴方向平分容器，第二种写法是项目的大小不会有变化。

有些资料建议优先使用这个属性，而不是单独写三个分离的属性，因为浏览器会推算相关值。

我们最常见的写看到的写法是flex:1，这样的简写其实也是合法的，后面的两个缺省了，就按照默认的值写写法就相当于flex:auto

#### align-self属性

align-self属性允许单个项目有与其他项目不一样的对齐方式，可覆盖align-items属性。默认值为auto，表示继承父元素的align-items属性，如果没有父元素，则等同于stretch。

```
align-self: auto | flex-start | flex-end | center | baseline | stretch;
```
该属性可能取6个值，除了auto，其他都与align-items属性完全一致。

## 浏览器兼容性
经过查询结果如下：
![](http://oankigr4l.bkt.clouddn.com/201804271109_84.png)

兼容性并不好，且Flexbox有新旧版以及混合写法，可以说假如需要兼容旧版本的话可以说非常可怕了。
新版旧版可以用以下方法简单区分：
* display:box,或者box-{*}就是2009年版本
* display：flexbox，或者flex()函数，是2011年版本，也成为混合版本
* display：flex，或者flex-{*}属性，是当前的w3c标准规范的flexbox

flex语法规范的多样性造成在不同的语法版本下的使用方式不同，加上不同的浏览器支持度的不同，在移动端的使用更多，兼容性更好，有兼容需求的同学一定要考虑清楚。

## 总结与最佳实践

在网页布局进入css时代之前，复杂的排版都是通过table实现的，在单元格里可以方便的使用水平和垂直对齐，[table其实对开发者并没有那么友好]()。这些写法随着web语义化流行，逐渐没落，css的日渐强大。根据css提供常见的布局方式：文档流，浮动布局，定位布局，我们可以完美解决大多的常见的需求。

新的的特性，都是为了解决某些痛点的，flex的出现也不例外。一直以来，如何优雅的实现水平、垂直同时居中是一件头疼的事情。水平垂直居中我们可以通过margin:auto实现，可以使用maigin自身距离一半实现，也可以使用transform偏移x,y轴的方式来实现。这些写法当然都可以，但是缺少语义，可维护性极差，且使用时感觉很笨重。

flex布局通过方向轴和容器的概念很优雅的实现了水平垂直居中。通过控制容器元素的主轴对其方式和交叉轴对齐就可以完美实现，对多个伸缩项目的容器的情况，也可以控制各个项目的排序，比例，位置等情况。可以说事非常推荐了。

上一段时间写过一个基于twitter的UI，微博的内容的demo([twibo-vue]((https://github.com/zhyjor/twibo-vue)))，里面大量使用了flex布局,欢迎start,fork。

**参考资料**
[]()

![](http://oankigr4l.bkt.clouddn.com/wexin.png)