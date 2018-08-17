---
title: css常见布局之一：元素居中
tags:
  - css
  - css常见布局
categories: css
top: false
copyright: true
date: 2018-03-06 16:07:35
---
css中居中是个永恒的话题，尤其是垂直居中问题，甚至有人说“人类都已经可以登上月球，但还实现不了垂直居中”。当然不是实现不了，是各种实现的方法都需要太多条件。本文将块级，内联级元素以及可替换元素的各种居中方法一一解读，希望给大家带来思路。
<!--more-->

### 绝对布局的margin:auto法
由于绝对定位元素的格式化高度即使父元素 height:auto 也是支持的，因此，其应用场
景可以相当广泛，可能唯一的不足就是此居中计算 IE8 及以上版本浏览器才支持。至少对我来
讲，如果项目无须兼容 IE7 浏览器，绝对定位下的 margin:auto 居中是我用得最频繁的块级
元素垂直居中对齐方式。

首推的方法就是利用绝对定位元素的流体特性和 margin:auto 的自动分配特性实现居中。
```css
.dad {
    position: relative;
}

.son {
    position: absolute;
    margin: auto;
    top: 0;
    right: 0;
    bottom: 0;
    left: 0;
}

```

### marign 元素一半法
没那么好，但是可以兼容ie7，ie7需要兼容吗
```css
.dad {
    position: relative;
}

.son {
    width: 100px;
    height: 100px;
    position: absolute;
    top: 50%;
    left: 50%;
    margin-top: -50px;
    margin-left: -50px;
}
```

### 百分比transform法
百分比 transform 会让 iOS 微信闪退，还是尽量避免的好。
```css
.element {
	width: 300px; height: 200px;
	position: absolute; left: 50%; top: 50%;
	transform: translate(-50%, -50%); /* 50%为自身尺寸的一半 */
}
```

### 内联元素（小图标）的1ex法

### 为什么 line-height 可以让内联元素“垂直居中”

### 基于vertical-align属性的水平垂直
```html
<div class="container">
	<div class="dialog"></dialog>
</div>
```
```css
.container {
	position: fixed;
	top: 0; right: 0; bottom: 0; left: 0;
	background-color: rgba(0,0,0,.5);
	text-align: center;
	font-size: 0;
	white-space: nowrap;
	overflow: auto;
}
.container:after {
	content: '';
	display: inline-block;
	height: 100%;
	vertical-align: middle;
}
.dialog {
	display: inline-block;
	vertical-align: middle;
	text-align: left;
	font-size: 14px;
	white-space: normal;
}
```

此时，无论浏览器尺寸是多大，也无论弹框尺寸是多少，我们的弹框永远都是居中的。

目前主流实现，尤其传统 PC 端页面，几乎都是根据浏览器的尺寸和弹框大小使用 JavaScript 精确计算弹框的位置。相比传统的 JavaScript 定位，这里的方法优点非常明显。

* 性能更改、渲染速度更快，毕竟浏览器内置 CSS 的即时渲染显然比 JavaScript 的处理要更好
* 节省了很多无谓的定位的 JavaScript 代码，也不需要浏览器 resize
事件之类的处理，当弹框内容动态变化的时候，也无须重新定位。**这里的确会有这个问题，当使用js控制位置时，resize的确是个问题**
* 可以非常灵活控制垂直居中的比例，比方说设置：

	```css
	.container:after {
		height: 90%;
	}
	```
* 容器设置 overflow:auto 可以实现弹框高度超过一屏时依然能看见屏幕外的内容，传统实现方法则比较尴尬。

## 小图片的对齐方案
### 1em方法

### 相对布局法
```css
p > img {
	width: 16px; height: 16px;
	vertical-align: 25%;
	position: relative;
	top: 8px;
}
```
其居中原理本质上和绝对定位元素 50%定位加偏移自身 1/2 尺寸实现居中是一样的，只不过这里的偏移使用的是 vertical-align 百分比值。

使用 vertical-align:.6ex 实现的垂直居中效果不会受 line-height 变化影响，而使用 vertical-align:25%， line-height 一旦变化，就必须改变原来的vertical-align 大小、重新调整垂直位置，这容错性明显就降了一个层次。

**参考资料**
[大小不固定的图片、多行文字的水平垂直居中](http://www.zhangxinxu.com/wordpress/2009/08/%E5%A4%A7%E5%B0%8F%E4%B8%8D%E5%9B%BA%E5%AE%9A%E7%9A%84%E5%9B%BE%E7%89%87%E3%80%81%E5%A4%9A%E8%A1%8C%E6%96%87%E5%AD%97%E7%9A%84%E6%B0%B4%E5%B9%B3%E5%9E%82%E7%9B%B4%E5%B1%85%E4%B8%AD/)
[不定期更新的CSS奇淫技巧](https://juejin.im/post/5b12ae3de51d4506d73f0bb4)
[水平垂直居中，这是一道面试必考题·可以参考，比较全面](https://github.com/yanhaijing/vertical-center)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)