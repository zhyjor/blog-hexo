---
title: 每周一个前端动画之一：UC浏览器球队展示动画的实现
tags:
  - 动画
  - 前端
  - 一周一个前端动画
categories: 前端动画
copyright: true
date: 2018-02-02 20:24:30
---
作为一个眼中有码的人，看见某个网页或者app的炫酷效果时，第一反应就是这怎么实现的。这个系列就是把自己见到的一些动画效果分析实现出来，本文分析实现的某些效果，仅仅作为一个思路分享，仅仅作为学习素材使用。闲话不说，这篇文章是前端动画系列的第一篇。
<!--more-->
### 源动画效果
作为一个轻度伪球迷，经常会看些赛事比分，比如英超（利物浦是冠军）。使用UC的朋友应该发现过，UC在展示比赛时的效果还是很炫的，动画很简单，但是效果的确不错。效果图如下：

![](http://oankigr4l.bkt.clouddn.com/UC_football_logo.gif)

### 实现分析
经过观察不难发现：

* 动画效果是左右对称的，只要实现了一侧即可。
* 球队的logo只是在x轴进行了移动，但是停的位置以及停顿时机都需要注意
* 球队logo有一个从大到小的缩放
* logo的透明度逐渐增大

分析出以上四点，就会发现效果实现起来也不复杂。

### 代码实现
动画使用CSS3的帧动画实现`animation`,不熟悉该属性用法的同学需要补补课了。注意该属性的兼容性写法，**Safari 和 Chrome需要写成`-webkit-animation`**

我们只分析左侧曼联logo的实现即可。从logo进入到动画定格，我们将整个过程分成4个部分，可以确定4个关键帧：
```
@-webkit-keyframes team-logo-left {}
```

**关键帧1**：logo放大一倍，x轴偏离初始位置到窗体外部。

```
0% {
      -webkit-transform: translate3d(-145px, 0, 0) scale(2);
      -webkit-transform-origin: center;
      -webkit-animation-timing-function: ease-out;
      opacity: .05
   }
```
**关键帧2**：logo放大一倍，x轴偏离初始位置到窗体中间部分，并稍作停顿，所以使用了50%，60%作停顿，时间函数使用了cubic-bezier来调整。

```
50%, 60% {
            -webkit-transform: translate3d(76px, 0, 0) scale(2);
            -webkit-transform-origin: center;
            -webkit-animation-timing-function: cubic-bezier(.33, .95, .77, 1.01);
            opacity: .8
        }
```

**关键帧3**：logo恢复到正常大小，x轴偏离初始位置略左侧，透明度已经变成完全不透明。

```
85% {
            -webkit-transform: translate3d(-10px, 0, 0) scale(1);
            -webkit-animation-timing-function: ease-in;
            -webkit-transform-origin: center;
            opacity: 1
        }
```

**关键帧4**：即从偏左位置到达最终的停留位置

```
100% {
            -webkit-transform: translate3d(0, 0, 0) scale(1);
            -webkit-transform-origin: center;
            opacity: 1
        }
```

### 效果展示


![](http://oankigr4l.bkt.clouddn.com/my_football_logo.gif)

### 关键点解读
#### 计时函数`animation-timing-function`

* 属性可以作用于整个动画中，定义了动画的每次循环是如何随时间递进的。
* 该属性还可以作用于关键帧，如本例的用法，各个关键帧都有单独的计时函数。**这时的计时其实指的的帧之间的时间函数**，顺序播放的动画，结尾关键帧的计时函数不会生效。
* 属性的值可选，有`linear,ease,ease-in,ease-out,ease-in-out,cubic-bezier(n,n,n,n)`,以及还有阶跃函数`steps(n,start/end)`,有兴趣的同学可以深入了解一下。

动画的实现其实很简单，[代码已上传到github，欢迎提出Issues](https://github.com/zhyjor/animation-css-demos.git)



**参考资料**
[CSS3的关键帧动画(KeyframeAnimations)简介](http://blog.csdn.net/u012447000/article/details/48852915)
[深入理解CSS3 Animation 帧动画](https://www.cnblogs.com/aaronjs/p/4642015.html)


![](http://oankigr4l.bkt.clouddn.com/wexin.png)