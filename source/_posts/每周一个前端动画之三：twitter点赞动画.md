---
title: 每周一个前端动画之三：twitter点赞动画
tags:
  - 动画
  - 前端
  - 一周一个前端动画
categories: 前端动画
copyright: true
date: 2018-02-24 08:59:47
---
开工大吉，在开工第二天，送上每周一个动画系列的第三篇，新的一年先给自己一个大大的赞。闲话不说，开始我们的正文。

本文分析实现的某些效果，仅仅作为一个思路分享，仅仅作为学习素材使用。

<!--more-->
### 源动画效果
可以看到鼠标在点击红心的时候，有些粒子效果，同时红心填充为红色，效果的确很赞。

![](http://oankigr4l.bkt.clouddn.com/week3_twitter_like.gif)
### 实现分析
我们应该记得在[《每周一个前端动画之一：UC浏览器球队展示动画的实现》](https://juejin.im/post/5a74902e5188257a64266f83)中提到了计时函数`animation-timing-function`，它的属性有个阶跃函数steps()，我们可以使用这个函数。使用包含一组渐变的效果的精灵图（如下图），设置好合适的步数，只要我们在水平轴跳跃的移动图片，就能达到我们的效果。

![](http://oankigr4l.bkt.clouddn.com/week3_twitter_heart.png)

### 代码实现

使用上文提到的一张特殊的精灵图作为背景

```
.HeartAnimation {
    background-image: url(web_heart_animation_edge.png);
    background-position: left;
}
```

设置动画的计时函数steps,这里需要明确一下，steps是一个阶跃函数，函数曲线不是连续的，因为图片一共有29张，存在28个间隔，所以，我们设置阶跃的步数为28

```
.like-active {
    animation-timing-function: steps(28);
    animation-name: heart-burst;
    animation-duration: .8s;
    animation-iteration-count: 1;
    animation-fill-mode: forwards;
    display: inline-block
}
@keyframes heart-burst {
    0% {
        background-position: left
    }

    100% {
        background-position: right
    }
}
```

### 效果展示

![](http://oankigr4l.bkt.clouddn.com/week3_my_like.gif)

### 关键点解读
本文的关键点就在于steps函数的使用，steps函数使用的地方很多，只要是这种特定步骤的动画，都可以实现。steps还有很多其他的使用方式，我们在后续的博文里也会多次的看到的。

[代码已上传到github，欢迎提出Issues。](https://github.com/zhyjor/animation-css-demos.git)

最后的惯例，贴上[我的博客](https://github.com/zhyjor/homepage-index)，欢迎关注



**参考资料**
[]()

![](http://oankigr4l.bkt.clouddn.com/wexin.png)