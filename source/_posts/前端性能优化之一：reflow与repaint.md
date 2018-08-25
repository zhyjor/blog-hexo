---
title: 前端性能优化之一：reflow与repaint
tags:
  - 前端性能优化
categories: 前端性能
top: false
copyright: true
date: 2018-01-19 15:11:41
---
前端性能的优化包含很多方面，包括但是不限于用户打开的速度，它应该包括诸如**工作效率、速度性能、稳定性、响应式、兼容性、搜索SEO、信息无障碍**等等。

前端优化是一个让人兴奋的一个点，你的页面每一次有成效的优化，都是对自己莫大的奖励，且优化是没有尽头的。
<!--more-->

对于前端来说，对性能最大的挑战就是dom的操作引起的浏览器的reflow与repaint，回流与重绘，引起reflow的原因除了dom的结构的改变还有一些属性的获取，引起repaint的原因主要是一些颜色等的改变。为了减少dom的操作也出现了很多visual dom的框架，以期提高性能，如vue，react。

本文简单介绍浏览器的渲染，重点指出一些会引起dom性能变差的问题，其实一切慢的原因是引起浏览器回流的dom操作，让我们从documentfragment来开始。

## DocumentFragment的方式很好吗

```js
/* 常规方式 */
document.addEventListener('DOMContentLoaded', function() {
var date = new Date();
for (var i = 0; i < 50000; i++) {
  var tmpNode = document.createElement("div");
  tmpNode.innerHTML = "test" + i;
  document.body.appendChild(tmpNode);
}
console.log(new Date() - date);
});

/* DocumentFragment方式 */
document.addEventListener('DOMContentLoaded', function() {
var date = new Date(), fragment = document.createDocumentFragment();
for (var i = 0; i < 50000; i++) {
  var tmpNode = document.createElement("div");
  tmpNode.innerHTML = "test" + i;
  fragment.appendChild(tmpNode);
}
document.body.appendChild(fragment);
console.log(new Date() - date);
});
```

测试结果发现时间基本无差别。。难道是现在的浏览器高端到 JS 不会阻塞 UI 渲染了吗？

### 现代浏览器对append的优化

document fragment从机制上比较接近innerHTML，只是前者确保了dom结构。其他大量的事情其实要等到被插入document之后才发生。

比如当你append到document时，被append进去的元素的样式表的计算是同步发生的，此时getComputedStyle可以得到样式的计算值。而append到document fragment，没样式表什么事，可以省下这个计算。再如，**script节点只有append到document时，才会真的parse和执行。**

注意阻塞UI不是阻塞reflow。如果你在append到document之后去访问下clientHeight这样的属性，其实会block住直到reflow完成。但是如果你不访问这类属性，浏览器没有必要在这个点进行强制reflow，而可以等待到脚本执行完。

直接往元素里append的操作会引发reflow，在循环中多次触发reflow是非常不讨好的事情，我们聪明的浏览器会将短时间内的多次reflow收集起来组成队列，在一定时间后flush队列，将多个reflow的变为一次reflow。

现代浏览器的优化做得更好，所以类似的，**如果你在append到document之后没有访问getComputedStyle之类的，浏览器也可以把样式表计算推迟到脚本执行之后**。

尽管通常情况下，性能现在没有很大差异，但是作为靠谱程序员，你在追加dom时，用document fragement，是在代码层面明确：这里插入时，不需要（不应该）发生插入document的效果。所以该写的地方还是要写。

### 会引起dom reflow的属性操作
下面情况会导致reflow发生

* 改变窗口大小
* 改变文字大小
* 内容的改变，如用户在输入框中敲字
* 激活伪类，如:hover
* 操作class属性
* 脚本操作DOM
* 计算offsetWidth和offsetHeight
* 设置style属性


什么 DOM 操作会导致浏览器重排？这些 DOM 访问、操作是需要我们时刻留意的：

```js
elem.offsetLeft, 
elem.offsetTop, elem.offsetWidth, elem.offsetHeight, elem.offsetParent
elem.clientLeft, elem.clientTop, elem.clientWidth, elem.clientHeight
elem.getClientRects(), elem.getBoundingClientRect()
elem.scrollBy(), elem.scrollTo()
elem.scrollIntoView(), elem.scrollIntoViewIfNeeded()
elem.scrollWidth, elem.scrollHeight
elem.scrollLeft, elem.scrollTop
elem.focus()
elem.computedRole, elem.computedName
elem.innerText
window.getComputedStyle()
window.scrollX, window.scrollY
window.innerHeight, window.innerWidth
window.getMatchedCSSRules()
mouseEvt.layerX, mouseEvt.layerY, mouseEvt.offsetX, mouseEvt.offsetY
doc.scrollingElement
range.getClientRects(),range.getBoundingClientRect()

```

### 能避免回流吗？

reflow是不可避免的，只能将reflow对性能的影响减到最小。

**尽可能限制reflow的影响范围。需要改变元素的样式，不要通过父级元素影响子元素。最好直接加在子元素上。**

**通过设置style属性改变结点样式的话，每设置一次都会导致一次reflow。所以最好通过设置class的方式。**

* 实现元素的动画，它的position属性应当设为fixed或absolute，这样不会影响其它元素的布局。
* 权衡速度的平滑。比如实现一个动画，以1个像素为单位移动这样最平滑，但reflow就会过于频繁，CPU很快就会被完全占用。如果以3个像素为单位移动就会好很多。
* 不要用tables布局的另一个原因就是tables中某个元素一旦触发reflow就会导致table里所有的其它元素reflow。在适合用table的场合，可以设置table-layout为auto或fixed，这样可以让table一行一行的渲染，这种做法也是为了限制reflow的影响范围。
* 很多情况下都会触发reflow，如果css里有expression，每次都会重新计算一遍。
* 减少不必要的 DOM 层级（DOM depth）。改变 DOM 树中的一级会导致所有层级的改变，上至根部，下至被改变节点的子节点。这导致大量时间耗费在执行 reflow 上面。
* 避免不必要的复杂的 CSS 选择器，尤其是后代选择器（descendant selectors），因为为了匹配选择器将耗费更多的 CPU。

## 何为回流
**reflow：**例如某个子元素样式发生改变，直接影响到了其父元素以及往上追溯很多祖先元素（包括兄弟元素），这个时候浏览器要重新去渲染这个子元素相关联的所有元素的过程称为回流。

reflow几乎是无法避免的。现在界面上流行的一些效果，比如树状目录的折叠、展开（实质上是元素的显 示与隐藏）等，都将引起浏览器的 reflow。鼠标滑过、点击……只要这些行为引起了页面上某些元素的占位面积、定位方式、边距等属性的变化，都会引起它内部、周围甚至整个页面的重新渲 染。通常我们都无法预估浏览器到底会 reflow 哪一部分的代码，它们都彼此相互影响着。

**repaint：**如果只是改变某个元素的背景色、文 字颜色、边框颜色等等不影响它周围或内部布局的属性，将只会引起浏览器 repaint（重绘）。repaint 的速度明显快于 reflow


**参考资料**
[前端优化的一些小技巧](https://juejin.im/post/5afa6ad4518825426c68fbcb?utm_medium=hao.caibaojian.com&utm_source=hao.caibaojian.com)
[移动端页面的 JavaScript 开销](http://www.css88.com/archives/8396)
[前端优化不完全指南 | Aotu.io「凹凸实验室」](https://juejin.im/entry/575ac312207703006ff2dc32)
**[网站性能优化实战——从12.67s到1.06s的故事](https://juejin.im/post/5b0b7d74518825158e173a0c)**
[「前端那些事儿」② 极限性能优化](https://juejin.im/post/59ff2dbe5188254dd935c8ab)
[前端性能优化--从 10 多秒到 1.05 秒](https://juejin.im/post/5b0bff30f265da08f76cc6f0)
[漫谈前端性能优化](https://juejin.im/post/5a4f09eef265da3e3b7a5399)
[将 Web 应用性能提高十倍的 10 条建议](https://juejin.im/entry/5726013a71cfe40057801c3d)
[前端性能优化常用总结](https://juejin.im/post/59e1bbc9f265da430f311fb1)

[h5渲染性能一瞥](https://juejin.im/post/5b7e1585f265da436631a61b)

**[16毫秒的优化·Web前端性能优化的微观分析](http://velocity.oreilly.com.cn/2013/ppts/16_ms_optimization--web_front-end_performance_optimization.pdf)**

**[2018 前端性能优化清单](https://juejin.im/post/5a966bd16fb9a0635172a50a#heading-7)**
[网站性能优化实战——从12.67s到1.06s的故事](https://juejin.im/post/5b6fa8c86fb9a0099910ac91)

[CSS3动画那么强，requestAnimationFrame还有毛线用？](https://www.zhangxinxu.com/wordpress/2013/09/css3-animation-requestanimationframe-tween-%E5%8A%A8%E7%94%BB%E7%AE%97%E6%B3%95/)

[《webkit技术内幕》这本书怎么样？里面的哪些内容有了变动？](https://www.zhihu.com/question/266787740/answer/313995802)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)