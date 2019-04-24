---
title: 动效开发之二：css动画中常用属性
tags:
  - 动效开发
  - 前端
categories: 前端动画
top: false
copyright: true
date: 2018-06-05 09:57:55
---
在之前整理的一些动画中，更偏向于应用、实现，今天讲点理论的。animation、transition、transform、translate，这几个属性需要再整理一下。
<!--more-->
## 混淆属性
css属性很多，并且有些无论是字母的拼写还是字面上的意思，都容易混淆，比如我列出来的几个属性，是不是也混淆过你～

|属性|含义|
|---|---|
	|animation（动画）|用于设置动画属性，他是一个简写的属性，包含6个属性|
|transition（过渡）|用于设置元素的样式过度，和animation有着类似的效果，但细节上有很大的不同|
|transform（变形）|用于元素进行旋转、缩放、移动或倾斜，和设置样式的动画并没有什么关系，就相当于color一样用来设置元素的“外表”|
|translate（移动）|translate只是transform的一个属性值，即移动。|

### animation
我们最常用到的属性，在官方的介绍上介绍这个属性是transition属性的扩展，弥补了transition的很多不足。结合`@keyframes`实现帧动画。

#### 常见用法

```css
.box {
      height: 100px;
      width: 100px;
      border: 15px solid black;
      animation: changebox 1s ease-in-out 1s infinite alternate running forwards;
    }

    .box:hover {
      animation-play-state: paused;
    }

    @keyframes changebox {
      10% {
        background: red;
      }
      50% {
        width: 80px;
      }
      70% {
        border: 15px solid yellow;
      }
      100% {
        width: 180px;
        height: 180px;
      }
    }

```

#### 语法

通过控制animation的每个值，控制动画变得非常灵活，我们来具体了解它的语法以及各个值代表着什么：
```css
animation: name duration timing-function delay iteration-count direction play-state fill-mode;
```
|值|描述|
	|--|--|
|name|用来调用@keyframes定义好的动画，与@keyframes定义的动画名称一致|
|duration|指定元素播放动画所持续的时间|
|timing-function|规定速度效果的速度曲线，是针对每一个小动画所在时间范围的变换速率|
|delay|定义在浏览器开始执行动画之前等待的时间，值整个animation执行之前等待的时间|
|iteration-count|定义动画的播放次数，可选具体次数或者无限(infinite)|
|direction|设置动画播放方向：normal(按时间轴顺序),reverse(时间轴反方向运行),alternate(轮流，即来回往复进行),alternate-reverse(动画先反运行再正方向运行，并持续交替运行)|
|play-state|控制元素动画的播放状态，通过此来控制动画的暂停和继续，两个值：running(继续)，paused(暂停)|
|fill-mode|控制动画结束后，元素的样式，有四个值：none(回到动画没开始时的状态)，forwards(动画结束后动画停留在结束状态)，backwords(动画回到第一帧的状态)，both(根据animation-direction轮流应用forwards和backwards规则)，注意与iteration-count不要冲突(动画执行无限次)|

animation与transition 不同的是，keyframes提供更多的控制，尤其是时间轴的控制，这点让css animation更加强大，使得flash的部分动画效果可以由css直接控制完成，而这一切，仅仅只需要几行代码，也因此诞生了大量基于css的动画库，用来取代flash的动画部分。


### transition
什么叫过渡？字面意思上来讲，就是元素从这个属性(color)的某个值(red)过渡到这个属性(color)的另外一个值(green)，这是一个状态的转变，需要一种条件来触发这种转变，比如我们平时用到的:hoever、:focus、:checked、媒体查询或者JavaScript。

#### 常见用法

```css
 #box {
      height: 100px;
      width: 100px;
      background: green;
      transition: transform 1s ease-in 1s;
    }

    #box:hover {
      transform: rotate(180deg) scale(.5, .5);
    }


```

首先transition给元素设置的过渡属性是transform，当鼠标移入元素时，**元素的transform发生变化，那么这个时候就触发了transition，产生了动画**，当鼠标移出时，transform又发生变化，这个时候还是会触发transition，产生动画，所以transition产生动画的条件是transition设置的property发生变化，这种动画的特点是需要“一个驱动力去触发”，有着以下几个不足：

* 需要事件触发，所以没法在网页加载时自动发生
* 是一次性的，不能重复发生，除非一再触发
* 只能定义开始状态和结束状态，不能定义中间状态，也就是说只有两个状态
* 一条transition规则，只能定义一个属性的变化，不能涉及多个属性。

#### 语法
```css
transition: property duration timing-function delay;
```
|值|描述|
	|--|--|
|transition-property|规定设置过渡效果的 CSS 属性的名称|
|transition-duration	|规定完成过渡效果需要多少秒或毫秒|
|transition-timing-function	|规定速度效果的速度曲线|
|transition-delay|定义过渡效果何时开始|

### 小结
简单一次性的动画中推荐使用transition，比较逻辑清晰，可维护性较好。如果遇到比较复杂的动画，这个时候便可以拿出animation。而且使用js的requestAnimationFrame，也能够高性能地执行动画。
	

## 时间函数（animation-timing-function）
速度曲线定义动画从一套 CSS 样式变为另一套所用的时间。

**参考资料**
[CSS动画：animation、transition、transform、translate傻傻分不清](https://juejin.im/post/5b137e6e51882513ac201dfb)
[【CSS3】transition过渡和animation动画](https://blog.csdn.net/XIAOZHUXMEN/article/details/52003135)

![](http://static.zhyjor.com/wexin.png)
