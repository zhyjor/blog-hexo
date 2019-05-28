---
title: 每周一个前端动画之五：B站视频预览动画
tags:
  - 动画
  - 前端
  - 每周一个前端动画
categories: 每周一个前端动画
top: false
copyright: true
date: 2019-05-25 14:44:00
---
春衫犹是，小蛮针线，曾湿西湖雨，转眼来杭州已经小半年了，最忆是杭州，很喜欢的一个城市。因为换厂子的原因，这个系列中断了一段时间，是时候再次更新起来了。闲言少叙，开始我们的正文。

本文分析实现的某些效果，仅仅作为一个思路分享，仅仅作为学习素材使用。
<!--more-->
### 源动画效果
在B站逛的时候发现一个小功能挺好玩的，当鼠标hover到卡片上的时候，可以进行视频的预览。而且当在卡片上移动鼠标的时候，预览的位置可以随之改变。如下图，可以很直观的观察到效果：
![](https://ws2.sinaimg.cn/large/006tNc79ly1g3gyzjcc44g30a005iqv5.gif)

### 实现分析
弹幕效果先略去，分析一下预览效果的实现，看到上面的效果，我们可以想到在[之前的的文章中](https://juejin.im/post/5a918bcf6fb9a063475f9bf1)，我们用到过动画时间函数中的steps()阶跃函数实现了Twitter的点赞动画。这个效果可以用类似的方式实现，但是有个区别是这个预览效果是根据鼠标的位置实现的，所以需要用到js进行辅助。具体步骤实现可以：
* 生成视频的预览图，预览图是按照类似精灵图的方式拼到一张图片上
* 页面根据当前鼠标的位置确定加载精灵图的不同位置为背景

### 代码实现
这里我们不考虑如何生成视频截图，有很多工具可以做，也能自己写脚本实现。
先看一下代码生成的精灵图：
![](https://ws3.sinaimg.cn/large/006tNc79ly1g3gz36c0bdj30k505rjsm.jpg)
这里将图片设置为背景，根据鼠标hover位置，修改背景图的位置：
```js
$('.cover').css({
  backgroundImage: "url(./bg-mult.png)",
  backgroundPosition: self.x + "px " + self.y + "px",
  backgroundSize: self.size + "px"
})
```
上面代码中的`this.x`与`this.y`是根据图片位置生成的背景图片的位置，原理和代码都很简单，可以看一下源码。

### 效果展示
![](https://ws4.sinaimg.cn/large/006tNc79ly1g3gz092qewg30ba0cab2c.gif)
### 关键点解读
实现的关键点在于如何将鼠标hover的相对位置，映射到对应的图片背景位置上，可以通过简单的计算，设置背景位置，和精灵图的用法基本一致。

[代码已上传到github，欢迎提出Issues。](https://github.com/zhyjor/animation-css-demos.git)

最后的惯例，贴上[我的博客](https://github.com/zhyjor/homepage-index)，欢迎关注


**参考资料**
[]()

![](http://static.zhyjor.com/wexin.png)