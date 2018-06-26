---
title: css技能之玄学开发
tags:
  - css
categories: css
top: false
copyright: true
date: 2018-06-26 14:20:55
---
css很简单，完全不懂的人大概看个一两天，就可以实现基本的页面效果；但是css也复杂，有些异常的效果，很多有经验的开发者也搞不明白该怎么解释。只能骂一句“又出bug了”。对于css来说，名字就是层叠样式表，关键是这个层叠，多个属性造就一个效果，一个异常也可能有多个属性引起的。还有些规范为定义的实现，这些学起来真的就是活脱脱的玄学开发。让我们从一些现象看起，通过现象看本质，希望玄学水平早日达到天人合一的境界。
<!--more-->
## 背景区域非矩形
问题出现在张大神的《css世界》4.2.2章节，大神的解释没看懂。

### 效果

代码及效果图如下：
```html
<div class="box">
    <span class="son">我国我国我国我国我国我国我国我国我国我国我国</span>
</div>
```
样式如下，因为内联元素的padding只影响视觉层不会影响布局层，所以最好在测试的元素上加点对上边界的margin，否则会看不到padding-top的内容。
```css
.box {
    border: 2px dashed #cd0000;
}
.son {
    padding: 50%;
    background-color: gray;
}
```
![](http://oankigr4l.bkt.clouddn.com/201806261508_98.png)

### 疑问点

疑问如下：
* 第一行、第二行看起来有些字被覆盖了
* 第二行怎么没铺满就换行了
* 最后一行怎么就一个字
* 英文怎么不换行

### 解释
其实如下图所示，有些消失的字时被背景覆盖了
![](http://oankigr4l.bkt.clouddn.com/201806261516_379.png)

对于white-space ：normal，文本自动处理换行.假如抵达容器边界内容会转到下一行，

因为有padding，当padding达到边界时，会带着最后一个字（铺满倒数第二行后，多余的字）换行

然后倒数第二行已经不是边界了，所以没有padding-left和right了，所以假如有多余的字，这一行就肯定铺满

最后因为汉字（东亚文字）最小宽度为每个汉字的宽度，可以在任何需要的时候换行，而西方文字最小宽度由特定的连续的英文字符单元决定。所以全部是是字母，就不会换行，因为找不到能换行的点，中间补上空格（普通空格）、短横线、问号以及其他非英文字符等就看到换行了。



## 父子margin合并的玄学问题
这个有个很神奇的现象，在实际开发的时候，给我们带来麻烦的多半就是这里的父子 margin 合并。

### 效果

我们给值元素设置一个margin-top的值，结果发现父元素的北京掉下来了。
代码如下：
```html
<div class="container">
    <h2>我是标题</h2>
</div>
```

```css
 .container {
    max-width: 356px;
    height: 289px;
    background: url(../assets/3.jpg) no-repeat;
}
.container > h2 {
    font-size: 38px;
    margin-top: 100px;
    color: #fff;
}
```
效果图：
![](http://oankigr4l.bkt.clouddn.com/201806261612_12.png)

### 问题解释

问题产生的原因就是这里的父子 margin 合并。这里大家需要理清楚“合并”这个概念。如果我们按照中文释义理解，应该必须有多个对象才能进行合并，否则根本就没有“合”这一说，确实如此。但是，这样理解也有可能会带来这样一个误区，即你要出点儿力，我要出点儿力，才叫“合”，其实不然。放到我们这里，这个父子 margin 合并的案例上就是：父元素没有出一点力，子元素出了全部的力，然后最终的 margin 全部合到了父元素上。也就是虽然是在子元素上设置的 margin-top，但实际上就等同于在父元素上设置了 margin-top，我想这样大家就能理解为何头图会掉下来了吧。

但是有一点需要注意，“等同于”并不是“就是”的意思，我们使用 getComputedStyle 方法获取父元素的 margin-top 值还是 CSS 属性中设置值，并非 margin 合并的表现值。

### 如何解决问题
那该如何阻止这里 margin 合并的发生呢？对于 margin-top 合并，可以进行如下操作（满足一个条件即可）：
* 父元素设置为块状格式化上下文元素；
* 父元素设置 border-top 值；
* 父元素设置 padding-top 值；
* 父元素和第一个子元素之间添加内联元素进行分隔。

对于 margin-bottom 合并，可以进行如下操作（满足一个条件即可）：
* 父元素设置为块状格式化上下文元素；
* 父元素设置 border-bottom 值；
* 父元素设置 padding-bottom 值；
* 父元素和最后一个子元素之间添加内联元素进行分隔；
* 父元素设置 height、 min-height 或 max-height。

所以，上面因为 margin 合并导致头图掉下来的问题可以添加下面的 CSS 代码进行
修复：
```css
.container {
	overflow: hidden;
}
```
其原理就是通过设置 overflow 属性让父级元素块状格式化上下文。

### 扩展
jQuery 中有个$().slideUp()/$().slideDown()方法，如果在使用这个动画效果的时候，发现这内容在动画开始或结束的时候会跳一下，那八九不离十就是布局存在 margin 合并。 跳动之所以产生，就是因为 jQuery 的 slideUp 和 slideDown方法在执行的时候会被对象元素添加 overflow:hidden 设置，而 overflow: hidden 会阻止 margin 合并，于是一瞬间间距变大，产生了跳动。


**参考资料**
[css玄学之一二](https://www.colabug.com/2627987.html)
[css玄学之一二·蘑菇街大神](https://echizen.github.io/tech/2018/04-05-read-css-world)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)