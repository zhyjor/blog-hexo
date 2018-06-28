---
title: css常见布局之七：小图标的最佳实践
tags:
  - css常见布局
  - css
categories: css
top: false
copyright: true
date: 2018-06-28 10:48:13
---
css中使用小图标的最佳实践当然是使用字体图标了，有些还使用精灵图来做的，但是随着http2.0的出现，精灵图可以丢掉了。
<!--more-->

## 字体图标的文字对齐
* 图标高度和当前行高都是 20px。很多小图标背景合并工具都是图标宽高多大生成的CSS 宽高就是多大，这其实并不利于形成可以整站通用的 CSS 策略，我的建议是图标原图先扩展成统一规格，比方说这里的 20px×20px，然后再进行合并，可以节约大量 CSS 以及对每个图标对齐进行不同处理的开发成本。
* 图标标签里面永远有字符。这个可以借助:before 或:after 伪元素生成一个空格字符轻松搞定。这个其实就是触发内部有元素，变成了对齐内部元素的基线。
*  图标 CSS 不使用 overflow:hidden 保证基线为里面字符的基线，但是要让里面潜在的字符不可见。需要保证内部元素不可见，不然看见字就很尴尬

这里使用一个巧妙的点就是在<i>里添加了一个不可见的元素，搞定基线，然后就可以了。于是，最终形成的最佳图标实践 CSS 如下：

```css
.icon {
	display: inline-block;
	width: 20px; height: 20px;
	background: url(sprite.png) no-repeat;
	white-space: nowrap;
	letter-spacing: -1em;
	text-indent: -999em;
}
.icon:before {
	content: '\3000';
}
/* 具体图标 */
.icon-xxx {
	background-position: 0 -20px;
}
```

**参考资料**
[]()

![](http://oankigr4l.bkt.clouddn.com/wexin.png)