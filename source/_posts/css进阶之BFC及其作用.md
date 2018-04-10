---
title: css进阶之BFC及其作用
tags:
  - css
  - css进阶
categories: css
copyright: true
date: 2018-03-05 19:33:11
---
Block Formatting Context，中文直译为块级格式上下文。
<!--more-->
### 什么是BFC 
BFC 就是一种属性，这种属性会影响着元素的定位以及与其兄弟元素之间的相互作用。 
中文常译为块级格式化上下文。是 W3C CSS 2.1 规范中的一个概念，它决定了元素如何对其内容进行定位，以及与其他元素的关系和相互作用。 在进行盒子元素布局的时候，BFC提供了一个环境，在这个环境中按照一定规则进行布局不会影响到其它环境中的布局。比如浮动元素会形成BFC，浮动元素内部子元素的主要受该浮动元素影响，两个浮动元素之间是互不影响的。 也就是说，如果一个元素符合了成为BFC的条件，该元素内部元素的布局和定位就和外部元素互不影响(除非内部的盒子建立了新的 BFC)，是一个隔离了的独立容器。（在 CSS3 中，BFC 叫做 Flow Root）

### 形成 BFC 的条件 
* 浮动元素，float 除 none 以外的值；
* 绝对定位元素，position（absolute，fixed）；
* display 为以下其中之一的值 inline-blocks，table-cells，table-captions； 
* overflow 除了 visible 以外的值（hidden，auto，scroll）

### BFC常见作用 
**包含浮动元素**
元素内部的浮动元素会脱离普通流，造成其父元素“高度坍陷”，上下框重叠在一起，可以通过`overflow:hidden/auto`来触发父元素的BFC特性，从而可以包含浮动元素，闭合浮动。
> Auto' heights for block formatting context roots，也就是 BFC 会根据子元素的情况自动适应高度，即使其子元素中包括浮动元素。


**不被浮动元素覆盖 **
浮动元素的块级兄弟元素会无视浮动元素的位置，尽量占满一整行，这样就会被浮动元素覆盖，为该兄弟元素触发 BFC 后可以阻止这种情况的发生。
假设浮动元素宽度和它的非浮动兄弟元素宽度都没有超过父元素宽度，但两个元素的宽度加起来超出了父元素宽度的时候，非浮动元素会下降到下一行，即处于浮动元素下方。

** BFC 会阻止外边距折叠 **
两个相邻的块级元素并在同一个BFC中时，他们的垂直方向之间的外边距才会叠加。也就是说，即便两个块级元素相邻，但当它们不在同一个块级格式化上下文时它们的边距也不会折叠。因此，阻止外边距折叠只需产生新的 BFC 。

### BFC 与 hasLayout
IE6-7 并不支持 W3C 的 BFC ，而是使用私有属性 hasLayout 。从表现上来说，hasLayout 跟 BFC 很相似，只是 hasLayout 自身存在很多问题，导致了 IE6-7 中一系列的 bug 。触发 hasLayout 的条件与触发 BFC 有些相似。

### 清除浮动的更多方法
在了解了清除浮动的实际原理后，我们不难想象，清除浮动的方法并不只上面提到的三种，例如，利用 BFC 特性，还可以使用以下的方法触发 BFC 并清除浮动。

给浮动元素的父元素添加浮动，但是这样需要一直浮动到 body ，不建议采取该方法。

给浮动元素的父元素添加 display: table-cells ，但是这样无疑改变了盒子模型，也不建议使用。

可以看出，以上这些方法虽然也比较方便，但同时也有很明显的缺点，这也导致了上面三种方法会更加适合实际项目中使用。

结合语义化的要求，在实际的项目中，建议可以使用 overflow 方法或 :after 伪元素方法。使用 overflow 方法，较为方便，在如内部元素全部为浮动元素，并且内容不会超出父元素框等情况可以直接采用 overflow 方法，但该方法毕竟会触发 BFC ，上面已经提到，BFC 的特性是有多个的，为了避免不必要的影响，如果实际需要清除浮动元素的布局比较复杂，可以直接采用 :after 伪元素方法。
**参考资料**
[浅析BFC及其作用](http://blog.csdn.net/riddle1981/article/details/52126522)
[详说 Block Formatting Contexts (块级格式化上下文)](https://www.cnblogs.com/leejersey/p/3991400.html)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)