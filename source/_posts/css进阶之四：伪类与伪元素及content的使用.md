---
title: css进阶之四：伪类与伪元素及content的使用
tags:
  - css
  - css进阶
categories: css
top: false
copyright: true
date: 2018-04-10 14:15:22
---
content内容生成就是通过content属性生成内容，content属性早在CSS2.1的时候就被引入了，可以使用:before以及:after伪元素生成内容。此特性目前已被大部分的浏览器支持： (Firefox 1.5+, Safari 3.5+, IE 8+, Opera 9.2+, Chrome 0.2+)。另外，目前Opera 9.5+ 和 Safari 4已经支持所有元素的content属性，而不仅仅是:before和:after伪元素。
<!--more-->

## content

替换元素和非替换元素之间只隔了一个 CSS content 属性！
## `<img>`加载提醒
当我们给图片元素添加一个src属性的时候，图片从普通变成一个替换元素，原本支持的::before、::after都无效了。此时再 hover 图片，是不会有任何信息出现的，于是就非常巧妙地增强了图片还没加载时的信息展示体验。
```css
img {
    display: inline-block;
    width: 256px; height: 192px;
    /* 隐藏Firefox alt文字 */
    color: transparent;
    position: relative;
    overflow: hidden;
}
img:not([src]) {
    /* 隐藏Chrome alt文字以及银色边框 */
    visibility: hidden;
}
img::before {
    /* 淡蓝色占位背景 */
    content: "";
    position: absolute; left: 0;
    width: 100%; height: 100%;
    background-color: #f0f3f9;
    visibility: visible;
}
img::after {
    /* 黑色alt信息条 */
    content: attr(alt);
    position: absolute;
    left: 0; bottom: 0;
    width: 100%;
    line-height: 30px;
    background-color: rgba(0,0,0,.5);
    color: white;
    font-size: 14px;
    transform: translateY(100%);
    /* 来点过渡动画效果 */
    transition: transform .2s;
    visibility: visible;
}
img:hover::after {
    transform: translateY(0);
}
```

### content 与替换元素关系剖析
CSS 世界中，我们把 content 属性生成的对象称为“匿名替换元素”（anonymous replaced element）。看到没，直接就“替换元素”叫起来了，可见，它们之间的联系并不是微妙，而是赤裸裸。

**content 属性生成的内容都是替换元素？没错，就是替换元素！**

* 我们使用 content 生成的文本是无法选中、无法复制的,好像设置了 userselect:none 声明一般。同时， content 生成的文本无法被屏幕阅读设备读取，也无法被搜索引擎抓取，因此，千万不要自以为是地把重要的文本信息使用 content 属性生成，因为这对可访问性和 SEO 都很不友好
* 不能左右:empty 伪类。 :empty 是一个 CSS 选择器，当元素里面无内容的时候进行匹配。
* content 动态生成值无法获取。 content 是一个非常强大的 CSS 属性，其中一个强大之处就是计数器效果

## content 内容生成技术
在实际项目中， content 属性几乎都是用在::before/::after 这两个伪元素中，因此， “ content 内容生成技术”有时候也称为“ ::before/::after 伪元素技术”。

### content 辅助元素生成
此应用的核心点不在于 content 生成的内容，而是伪元素本身。通常，我们会把 content的属性值设置为空字符串。只要是空字符串就可以，有人设置为 content:'.'，这是完全没有必要的。
```css
.element:before {
	content: '';
}
```
然后，利用其他 CSS 代码来生成辅助元素，或实现图形效果，或实现特定布局。与使用显式的 HTML 标签元素相比，这样做的好处是 HTML 代码会显得更加干净和精简
#### 清除浮动
最常见的应用之一就是清除浮动带来的影响:
```css
.clear:after {
	content: '';
	display: table; /* 也可以是'block' */
	clear: both;
}
```

**参考资料**
[CSS content内容生成技术以及应用](http://www.zhangxinxu.com/wordpress/2010/04/css-content%E5%86%85%E5%AE%B9%E7%94%9F%E6%88%90%E6%8A%80%E6%9C%AF%E4%BB%A5%E5%8F%8A%E5%BA%94%E7%94%A8/)
[:after伪类+content内容生成经典应用举例](http://www.zhangxinxu.com/wordpress/2010/09/after%E4%BC%AA%E7%B1%BBcontent%E5%86%85%E5%AE%B9%E7%94%9F%E6%88%90%E5%B8%B8%E8%A7%81%E5%BA%94%E7%94%A8%E4%B8%BE%E4%BE%8B/)


![](http://oankigr4l.bkt.clouddn.com/wexin.png)