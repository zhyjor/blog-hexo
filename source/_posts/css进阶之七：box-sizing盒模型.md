---
title: css进阶之七：box-sizing盒模型
tags: 
  - css
  - css进阶
 
copyright: true
date: 2017-10-25 08:44:43
categories: css
---
css盒模型是css的根本，最近经常看到分享的面经所到这个，其实这是重点，并不是难点。两种盒模型并不难理解，特整理如下。
<!--more-->
每个html的标签都可以认为是一个盒子，大盒子里装小盒子，跟俄罗斯套娃很接近，这些盒子就构成了盒模型。

**盒模型分为两类**

* IE盒模型
* W3C标准盒模型


### box-sizing存在的初衷
在 CSS 世界中，唯一离不开 box-sizing:border-box 的就是原生普通文本框`<input>`和文本域`<textarea>`的 100%自适应父容器宽度。

拿文本域`<textarea>`举例， `<textarea>`为替换元素，替换元素的特性之一就是尺寸由内部元素决定，且无论其 display 属性值是 inline 还是 block。这个特性很有意思，对于非替换元素，如果其 display 属性值为 block，则会具有流动性，宽度由外部尺寸决定，但是替换元素的宽度却不受 display 水平影响，因此，我们通过 CSS 修改`<textarea>`的display 水平是无法让尺寸 100%自适应父容器的.

```css
textarea {
  display: block; /* 还是原来的尺寸 */
}
```
所以，我们只能通过 width 设定让`<textarea>`尺寸 100%自适应父容器。那么，问题就来了，`<textarea>`是有 border 的，而且需要有一定的 padding 大小，否则输入的时候光标会顶着边框，体验很不好。于是， width/border 和 padding 注定要共存，同时还要整体宽度 100%自适应容器。如果不借助其他标签，肯定是无解的。

[在浏览器还没支持 box-sizing 的年代，我们的做法有点儿类似于“宽度分离”](http://demo.cssworld.cn/3/2-9.php)，外面嵌套`<div>`标签，模拟 border 和 padding，`<textarea>`作为子元素， border 和 padding全部为 0，然后宽度 100%自适应父级`<div>`。

然而，这种模拟也有局限性，比如无法使用:focus 高亮父级的边框，因为 CSS 世界中并无父选择器，只能使用更复杂的嵌套加其他 CSS 技巧来模拟。

因此，说来说去，也就 box-sizing:border-box 才是根本解决之道！

```css
textarea {
	width: 100%;
	-ms-box-sizing: border-box; /* for IE8 */
	box-sizing: border-box;
}
```
box-sizing 被发明出来最大的初衷应该是解决替换元素宽度自适应问题。如果真的如我所言，那`*{box-sizing:border-box}`是不是没用在点儿上呢？是不是应该像下面这样 CSS 重置才更合理呢？
```css
input, textarea, img, video, object {
  box-sizing: border-box;
}
```
** 对于替换元素，其宽度不受display影响，只能通过直接设置100%
才能充满父元素。即通过父元素来设置该效果。这样处理的坏处就是padding,border都不能使用了，所以加入`box-sizing`就显得有必要了. **

### IE盒模型和W3C标准盒模型的区别是什么？

**1、W3C 标准盒模型（content-box）：**

属性width,height只包含内容content，不包含border和padding。

**2、IE 盒模型（border-box）：**

属性width,height包含border和padding，指的是content+padding+border。

在ie8+浏览器中使用哪个盒模型可以由box-sizing(CSS新增的属性)控制，默认值为content-box，即标准盒模型；如果将box-sizing设为border-box则用的是IE盒模型。如果在ie6,7,8中DOCTYPE缺失会触发IE模式。在当前W3C标准中盒模型是可以通过box-sizing自由的进行切换的。

content-box（标准盒模型）

width = 内容的宽度

height = 内容的高度

border-box（IE盒模型）

width = border + padding + 内容的宽度

height = border + padding + 内容的高度

### 举个栗子

```
.box{
        width:200px;
        height:200px;
        background-color:pink;
        padding:20px;
        border:10px solid black;
        margin-bottom:10px;
}
.box1{
        width: 100px;
        height: 100px;
        background: green;
}
```

![](http://oankigr4l.bkt.clouddn.com/%E7%9B%92%E6%A8%A1%E5%9E%8B.png)

可以看到，盒子的底部产生了10px的空白。

所以说，盒子的大小为content+padding+border即内容的(width)+内边距的再加上边框，而不加上margin。错误地把margin算入，盒子的大小应该是260x270，但实际情况并不是这样的。

css的盒模型由content(内容)、padding(内边距)、border(边框)、margin(外边距)组成。但盒子的大小由content+padding+border这几部分决定，**把margin算进去的那是盒子占据的位置，而不是盒子的大小！**

### 该用哪种？
我们可以试着给上面的方块设置box-sizing属性为border-box发现，会发现：无论我们怎么改border和padding盒子大小始终是定义的width和height。

我们在编写页面代码时应尽量使用标准的W3C模型(需在页面中声明DOCTYPE类型)，这样可以避免多个浏览器对同一页面的不兼容。

因为若不声明DOCTYPE类型，IE浏览器会将盒子模型解释为IE盒子模型，FireFox等会将其解释为W3C盒子模型；若在页面中声明了DOCTYPE类型，所有的浏览器都会把盒模型解释为W3C盒模型。

### 如何评价*{box-sizing:border-box}
在开发过程中，我们最好的就是充分利用元素本身的特性来实现我们想要的效果。足够简单，足够纯粹，全局重置的做法会产生没必要的消耗以及违背了box-sizing存在的初衷。
* `*`通配符是个需要慎用的选择器，它会选择所有的标签。同于普通内联元素，box-sizing没有任何使用价值。
* 这种做法不能解决所有的问题，box-sizing不支持margin-box，只有当元素没有水平margin的时候，才能做到真正的无计算。


**参考资料**
[深入理解BFC和Margin Collapse](https://www.w3cplus.com/css/understanding-bfc-and-margin-collapse.html)
[神奇的CSS盒子模型](http://blog.csdn.net/eavan_zhou/article/details/52289351)
[CSS盒模型详解](https://juejin.im/post/59ef72f5f265da4320026f76)