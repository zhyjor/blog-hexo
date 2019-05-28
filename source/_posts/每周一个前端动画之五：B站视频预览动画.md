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
<!--more-->
本文分析实现的某些效果，仅仅作为一个思路分享，仅仅作为学习素材使用。

### 源动画效果
在B站逛的时候发现一个小功能挺好玩的，当鼠标hover到卡片上的时候，可以进行视频的预览。而且在卡片上移动鼠标的时候，预览的位置可以随之改变。如下图，可以很直观地观察到效果：
![](https://user-gold-cdn.xitu.io/2019/5/28/16afef6a82398560?w=360&h=198&f=gif&s=1834459)

### 实现分析
弹幕效果先略去，分析一下预览效果的实现。看到上面的效果，我们可以想到在[之前的的文章中](https://juejin.im/post/5a918bcf6fb9a063475f9bf1)用过的时间函数steps()，用这个函数实现了Twitter的点赞动画。本文的效果可以用类似的方式实现，但是有个区别是本文的预览效果是根据鼠标的位置变化的，所以需要用到js进行辅助。大概的步骤实现可以为：
* 生成视频的截图，截图按照类似精灵图的方式按先后顺序拼到一张图片上
* 页面根据当前鼠标的位置比例，确定加载精灵图的不同位置为背景

### 代码实现
这里我们不考虑如何生成视频截图和拼接，有很多工具可以做，也能自己写脚本实现。
先看一下最终获得的精灵图片段：
![](https://user-gold-cdn.xitu.io/2019/5/28/16afef6a1234a742?w=725&h=207&f=jpeg&s=42262)
这里将图片设置为背景，根据鼠标hover位置，修改背景图的位置，伪代码如下：
```js
$(".card").mousemove(function (e) {
    $('.cover').css({
      backgroundImage: "url(./bg-mult.png)",
      backgroundPosition: x + "px " + y + "px",
      backgroundSize: size + "px"
    })
    $('.progress').css({
      width: progress + "%"
    })
  });
```
上面代码中的`x、y、size、progress`是根据鼠标位置生成的背景图片的位置信息，原理和代码都很简单，详细的实现可以看一下源码，文末有链接。

### 效果展示
![](https://user-gold-cdn.xitu.io/2019/5/28/16afef6ab292c96d?w=406&h=442&f=gif&s=4492390)
### 关键点解读
实现的关键点在于如何将鼠标hover的相对位置，映射到对应的图片背景位置上，可以通过简单的计算，设置背景位置，和精灵图的用法基本一致。

[代码已上传到github，欢迎提出Issues。](https://github.com/zhyjor/animation-css-demos.git)

最后的惯例，贴上[我的博客](https://github.com/zhyjor/homepage-index)，欢迎关注

**参考资料**
[]()
<img width="360px" src="http://static.zhyjor.com/QQ2019-qun.png">
![](http://static.zhyjor.com/wexin.png)