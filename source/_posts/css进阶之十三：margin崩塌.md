---
title: css进阶之十三：margin崩塌
tags:
  - css进阶
  - css
categories: css
top: false
copyright: true
date: 2018-06-26 10:54:38
---
margin是css中常见且基础的概念，都是有套路可寻的，有时候只要把握住关键，很多玄学的点也都是可以解释的。
<!--more-->
## 和padding为什么不同
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
## 什么是 margin 合并
块级元素的上外边距（ margin-top）与下外边距（margin-bottom）有时会合并为单个外边距，这样的现象称为“margin 合并”。从此定义上，我们可以捕获两点重要的信息。
* 块级元素，但不包括浮动和绝对定位元素，尽管浮动和绝对定位可以让元素块状化。
* 只发生在垂直方向，需要注意的是，这种说法在不考虑 writing-mode 的情况下才是正确的，严格来讲，应该是只发生在和当前文档流方向的相垂直的方向上。由于默认文档流是水平流，因此发生 margin 合并的就是垂直方向。

## margin 合并的 3 种场景

### 相邻兄弟元素 margin 合并。
```
p { margin: 1em 0; }
<p>第一行</p>
<p>第二行</p>
```
则第一行和第二行之间的间距还是 1em，因为第一行的 margin-bottom 和第二行的
margin-top 合并在一起了，并非上下相加。

### 父级和第一个/最后一个子元素

在默认状态下，下面 3 种设置是等效的：
```html
<div class="father">
	<div class="son" style="margin-top:80px;"></div>
</div>
<div class="father" style="margin-top:80px;">
	<div class="son"></div>
</div>
<div class="father" style="margin-top:80px;">
	<div class="son" style="margin-top:80px;"></div>
</div>
```
这个有个很神奇的现象，在实际开发的时候，给我们带来麻烦的多半就是这里的父子 margin 合并。
#### 父子margin合并的玄学问题
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

问题产生的原因就是这里的父子 margin 合并。这里大家需要理清楚“合并”这个概念。如果我们按照中文释义理解，应该必须有多个对象才能进行合并，否则根本就没有“合”这一说，确实如此。但是，这样理解也有可能会带来这样一个误区，即你要出点儿力，我要出点儿力，才叫“合”，其实不然。放到我们这里，这个父子 margin 合并的案例上就是：父元素没有出一点力，子元素出了全部的力，然后最终的 margin 全部合到了父元素上。也就是虽然是在子元素上设置的 margin-top，但实际上就等同于在父元素上设置了 margin-top，我想这样大家就能理解为何头图会掉下来了吧。

但是有一点需要注意，“等同于”并不是“就是”的意思，我们使用 getComputedStyle 方法获取父元素的 margin-top 值还是 CSS 属性中设置值，并非 margin 合并的表现值。

#### 如何解决问题
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

说到此处，忍不住再多说几句。 jQuery 中有个$().slideUp()/$().slideDown()方法，如果在使用这个动画效果的时候，发现这内容在动画开始或结束的时候会跳一下，那八九不离十就是布局存在 margin 合并。 跳动之所以产生，就是因为 jQuery 的 slideUp 和 slideDown方法在执行的时候会被对象元素添加 overflow:hidden 设置，而 overflow: hidden 会阻止 margin 合并，于是一瞬间间距变大，产生了跳动。

### 空块级元素的 margin 合并
```
.father { overflow: hidden; }
.son { margin: 1em 0; }
<div class="father">
	<div class="son"></div>
</d
```
结果，此时.father 所在的这个父级`<div>`元素高度仅仅是 1em，因为.son 这个空`<div>`元素的 margin-top 和 margin-bottom 合并在一起了。这也是上一节 margin:50%最终宽高比是 2:1 的原因，因为垂直方向的上下 margin 值合二为一了，所以垂直方向的外部尺寸只有水平方向的一半.

这种空块级元素的 margin 合并特性即使自身没有设置 margin 也是会发生的，所谓“合”并不一定要自己出力，只要出人就可以。比方说，我们一开始的“相邻兄弟元素 margin 合并”，其实，就算兄弟不相邻，也是可以发生合并的，前提是中间插手的也是个会合并的家伙。比方说：
```
p, div {
    margin: 1em 0;
}
<p>第一行</p>
<div></div>
<p>第二行</p>
```
此时第一行和第二行之间的距离还是 1em，中间看上去隔了一个`<div>`元素，但对最终效果却
没有任何影响。如果非要细究，则实际上这里发生了 3 次 margin 合并， `<div>`和第一行`<p>`的 margin-bottom 合并，然后和第二行`<p>`的 margin-top 合并，这两次合并是相邻兄弟合并。由于自身是空`<div>`，于是前两次合并的 margin-bottom 和 margin-top 再次合并，这次合并是空块级元素合并，于是最终间距还是 1em。

由于空块级元素的 margin 合并发生不愉快事情的情况非常之少。一来，我们很少会在页面上放置没什么用的空`<div>`；二来，即使使用空`<div>`也是画画分隔线之类的，一般都是使用 border 属性，正好可以阻断 margin 合并；三来， CSS 开发人员普遍没有 margin 上下同时开工的习惯，比方说一个列表，间距都是一样的，开发人员一般都是单独设定 margin-top 或 margin-bottom 值，因为这会让他们内心觉得更安全。于是，最终，空块级元素的 margin 合并就变成了一个对 CSS 世界有着具有巨大意义但大多数人都不知道的特性。

#### 如何避免
如果有人不希望空`<div>`元素有 margin 合并，可以进行如下操作：
* 设置垂直方向的 border；
* 设置垂直方向的 padding；
* 里面添加内联元素（直接 Space 键空格是没用的）；
* 设置 height 或者 min-height。

## margin 合并的计算规则
我把 margin 合并的计算规则总结为“正正取大值”“正负值相加”“负负最负值” 3 句话。
下面来分别举例说明。

### 如果是相邻兄弟合并
```
<div class="a"></a>
<div class="b"></a>

.a { margin-bottom: 50px; }
.b { margin-top: 20px; }
此时.a 和.b 两个<div>之间的间距是 50px，取大的那个值。

.a { margin-bottom: 50px; }
.b { margin-top: -20px; }
此时.a 和.b 两个<div>之间的间距是 30px，是-20px+50px 的计算值。

.a { margin-bottom: -50px; }
.b { margin-top: -20px; }
此时.a 和.b 两个<div>之间的间距是-50px，取绝对负值最大的值。
```


### 父子合并
```
<div class="father">
	<div class="son"></div>
</div>

.father { margin-top: 20px; }
.son { margin-top: 50px; }
此时.father 元素等同于设置了 margin-top:50px，取大的那个值。


.father { margin-top: -20px; }
.son { margin-top: 50px; }
此时.father 元素等同于设置了 margin-top:30px，是-20px+50px 的计算值。

.father { margin-top: -20px; }
.son { margin-top: -50px; }
则此时.a 元素的外部尺寸是-50px，取绝对负值最大的值。
```

### 自身合并
```
<div class="a"></div>

.a {
	margin-top: 20px;
	margin-bottom: 50px;
}
则此时.a 元素的外部尺寸是 50px，取大的那个值。

.a {
	margin-top: -20px;
	margin-bottom: 50px;
}
则此时.a 元素的外部尺寸是 30px，是-20px+50px 的计算值。

.a {
	margin-top: -20px;
	margin-bottom: -50px;
}
则此时.a 元素的外部尺寸是-50px，取绝对负值最大的值。

```
## margin 合并的意义
margin合并是bug吗，还是正常的？有何意义

### bug？
这种特性是故意这么设计的，在实际内容呈现的时候是有着重要意义的，根本就不是 bug！不要遇到出乎自己意料或者自己无法理解的现象就称其为 bug

### 为何需要margin
CSS 世界的设计本意就是图文信息展示，有了默认的 margin 值，我们的文章、新闻就不会挤在一起，垂直方向就会层次分明、段落有致，阅读体验就会好！为何使用 em 作为单位也很好理解，大家应该知道浏览器默认的字号大小是可以自定义的吧，例如，默认的是 16 像素，假如我们设置成更大号的字号，同时 HTML标签的 margin 是像素大小，则会发生文字变大但是间距不变的情况，原本段落有致的阅读体验必然又会变得令人窒息。 em 作为相对单位，则可以让我们的文章或新闻无论多大的字体都排版良好。可以看到， HTML 标签默认内置的 CSS 属性值完全就是为了更好地进行图文信息展示而设计的。

我们平时进行网站开发的时候都会重置各种默认的 margin 尺寸，这是件需要好好审视的
事情，对于绝大多数网站，确实需要做这样的处理，因为这些网站鲜有传统的图文信息展示区
域。但是，如果你的站点是博客、新闻门户或公众号文章，我们应该做的是统一标签的 margin
大小，而不是一股脑地重置成 0。

### margin合并的意义
下面说说 margin 合并的意义。
#### 兄弟
假如说没有 margin 合并这种说法，那么连续段落或列表之类首尾项间距会和其他兄弟标签成 1:2 关系；文章标题距离顶部会很近，而和下面的文章详情内容距离又会很开，就会造成内容上下间距不一致的情况。这些都是糟糕的排版体验。而合并机制可以保证元素上下间距一致。

#### 父子


**参考资料**
[]()

![](http://oankigr4l.bkt.clouddn.com/wexin.png)