---
title: css常见布局之五：常见的页面结构
tags:
  - css常见布局
  - css
categories: css
top: false
copyright: true
date: 2018-06-26 10:03:00
---
常见的页面结构是指常见的页面基本布局，比如常见的多流体布局，比如一侧定宽，两栏自适应布局，圣杯布局、等等
<!--more-->
## 多流体布局
###  一侧定宽，两栏自适应
假设我们定宽的部分是 128 像素宽的图片，自适应的部分是文字。
#### 如果图片左侧定位

```css
.box { overflow: hidden; }
.box > img { float: left; }
.box > p { margin-left: 140px; }
```
```html
<div class="box">
	<img src="1.jpg">
	<p>文字内容...</p>
</div>
```
![](http://oankigr4l.bkt.clouddn.com/201806261046_917.png)
#### 图片右侧定位
如果图片右侧定位：只要图片的左浮动改成右浮动
```css
.box { overflow: hidden; }
.box > img { float: right; }
.box > p { margin-right: 140px; }
```

![](http://oankigr4l.bkt.clouddn.com/201806261047_829.png)
HTML 和上面的左侧定位效果一模一样，最终实现的也是一个效果良好的自适应布局。然而，这里的实现有一点瑕疵，那就是元素在 DOM 文档流中的前后顺序和视觉表现上的前后顺序不一致。

#### 图片右侧定位，同时顺序一致
如果想要实现顺序完美一致的自适应效果，可以借助 margin 负值定位实现.
```css
.box { overflow: hidden; }
.full { width: 100%; float: left; }
.box > img { float: left; margin-left: -128px; }
.full > p { margin-right: 140px; }
```

```html
<div class="box">
	<div class="full">
		<p>文字内容...</p>
	</div>
	<img src="1.jpg">
</div>
```

![](http://oankigr4l.bkt.clouddn.com/201806261047_990.png)

### 两端对齐布局
列表是我们 Web 开发中是非常常见的，一般都是通过循环遍历呈现出来的，也就是实际上每个列表的 HTML 样式都是一致的。现在有这样一个需求：列表块两端对齐，一行显示 3 个，中间有 2 个 20 像素的间隙。假如我们使用浮动来实现，CSS 代码可能是下面这样：

```css
li {
	float: left;
	width: 100px;
	margin-right: 20px;
}
```
**此时就遇到了一个问题，即最右侧永远有个 20 像素的间隙，无法完美实现两端对齐.**
如果不考虑 IE8，我们可以使用 CSS3 的 nth-of-type 选择器：
```css
li:nth-of-type(3n) {
	margin-right: 0;
}
```
除了使用js打个补丁之外，还有其他方式吗？我们可以通过给父容器添加 margin 属性，增加容器的可用宽度来实现。
```css
ul {
	margin-right: -20px;
}
ul > li {
	float: left;
	width: 100px;
	margin-right: 20px;
}
```

### 等高布局
此布局多出现在分栏有背景色或者中间有分隔线的布局中，有可能左侧栏内容多，也有可能右侧栏内容多，但无论内容多少，两栏背景色都和容器一样高。
![](http://oankigr4l.bkt.clouddn.com/201806261049_333.png)

由于 height:100%需要在父级设定具体高度值时才有效，因此我们需要使用其他技巧来实现。方法其实很多，例如使用 display:table-cell 布局，左右两栏作为单元格处理，或者使用border 边框来模拟，再或者使用我们这里的 margin 负值实现，核心 CSS 代码如下：

####  margin 负值实现
[点击按钮增减左右两栏的内容改变高度就会发现]( http://demo.cssworld.cn/4/3-2.php ),无论是左侧内容多还是右侧内容多，两栏的背景高度都是一样的
```css
.column-box {
	overflow: hidden;
}
.column-left,
.column-right {
	margin-bottom: -9999px;
	padding-bottom: 9999px;
}
```

下面问题来了：为什么可以实现等高呢？
垂直方向 margin 无法改变元素的内部尺寸，但却能改变外部尺寸，这里我们设置了margin-bottom:-9999px 意味着元素的外部尺寸在垂直方向上小了 9999px。默认情况下，垂直方向块级元素上下距离是 0， 一旦 margin-bottom:-9999px 就意味着后面所有元素和上面元素的空间距离变成了-9999px，也就是后面元素都往上移动了 9999px。此时，通过神来一笔padding-bottom:9999px 增加元素高度，这正负一抵消，对布局层并无影响，但却带来了我们需要的东西—视觉层多了 9999px 高度的可使用的背景色。**但是， 9999px 太大了，所以需要配合父级 overflow:hidden 把多出来的色块背景隐藏掉，于是实现了视觉上的等高布局效果。**

使用 margin 负值实现等高布局的优势在于兼容性足够， IE6 浏览器也支持，且支持任意个分栏等高布局。本例中， padding-bottom:9999px 也可以用 border-bottom: 9999px solid transparent 代替，不过 IE7 以上浏览器才支持。大家可以根据实际场景选择使用。

不过， margin 负值实现等高布局也有不足之处：首先，如果需要有子元素定位到容器之外，父级的 `overflow:hidden` 是一个棘手的限制；其次，当触发锚点定位或者使用`DOM.scrollIntoview()`方法的时候，可能就会出现奇怪的定位问题【需要补充】.

上述 margin 对尺寸的影响是针对具有块状特性的元素而言的，对于纯内联元素则不适用。和 padding 不同，内联元素垂直方向的 margin 是没有任何影响的，既不会影响外部尺寸，也不会影响内部尺寸，有种石沉大海的感觉。对于水平方向，由于内联元素宽度表现为“包裹性”，也不会影响内部尺寸。

#### border 和 table-cell 的优缺点
顺便说说使用 border 和 table-cell 的优缺点：前者优势在于兼容性好，没有锚点定位的隐患，不足之处在于最多 3 栏，且由于 border 不支持百分比宽度，因此只能实现至少一侧定宽的布局； table-cell 的优点是天然等高，不足在于 IE8 及以上版本浏览器才支持，所以，如果项目无须兼容 IE6、 IE7，则推荐使用 table-cell 实现等高布局。

#### border 等高布局技术
这种利用border实现的功能，基本都保持着一个特点，就是这些模块都是一起的，其实是同一块，通过占位实现。理论上，通过border-style：double实现更多的列，但是这些太复杂，没必要。
![](http://oankigr4l.bkt.clouddn.com/201806271433_604.png)

也就是说，左侧深色背景区域是由 border-left 属性生成的。元素边框高度总是和元素自身高度保持一致，因此可以巧妙地实现等高布局效果

```html
<div class="box">
  <nav>
    <h3 class="nav">导航1</h3>
  </nav>
  <section>
    <div class="module">模块1</div>
  </section>
</div>
```
此方法要想生效，有一点需要注意，父级容器不能使用 overflow:hidden 清除浮动影响，因为溢出隐藏是基于 padding box 的，如果设置了 overflow:hidden，则左浮动的导航列表元素就会被隐藏掉，这显然不是我们想要的效果。
```css
/* 导航背景区border创建 */
.box { 
  border-left: 150px solid #333;
  background-color: #f0f3f9;
}
/* 清除浮动影响，不能使用overflow:hidden */
.box:after {
  content: "";
  display: block;
  clear: both;
}
/* 布局主结构 */
.box > nav {
  width: 150px;
  margin-left: -150px;
  float: left;
}
.box > section {
    overflow: hidden;
}
/* 导航列表和模块列表 */
.nav {
    line-height: 40px;
    color: #fff;
}
.module {
    line-height: 40px;
}
```
此方法与用 margin+padding 实现的等高布局相比更加稳健，不会出现锚点定位带来的问题，但同样它也是有局限性的。
首先，由于 border 不支持百分比宽度，因此，适合至少一栏是定宽的布局。当然，如果不考虑 IE8 浏览器，可以试试使用 vw 单位，其可实现近似的百分比宽度效果。
其次，等高布局的栏目有限制,因为一个元素的边框数目是有限的.

**参考资料**
[]()

![](http://oankigr4l.bkt.clouddn.com/wexin.png)