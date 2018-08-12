---
title: css常见布局之九：三栏布局的常见实现
tags:
  - css常见布局
  - css
categories: css
top: false
copyright: true
date: 2018-07-16 15:45:26
---
三栏布局在前端开发中特别常见，即两边定宽，中间宽度自适应。最优的实现目前是双飞翼布局，兼容性和语义、以及加载性能都很好。
<!--more-->
对于三栏布局，如下图：
![](http://oankigr4l.bkt.clouddn.com/201808061547_589.png)

## Float方法

* 元素浮动后，脱离了文档流，左右两栏分别浮动到窗口的两边
* 中间块紧跟在浮动元素之后，通过调整margin调整三者之间的间距
* dom结构必须是先浮动，再中间块。

### 实现

```css
.left {
    float: left;
    height: 200px;
    width: 200px;
    background-color: red;
}
.right {
    width: 200px;
    height: 200px;
    background-color: blue;
    float: right;
}
.main {
    margin-left: 220px;
    margin-right: 220px;
    height: 200px;
    background-color: green;
}
```
注意dom元素的顺序
```html
<div class="container">
    <div class="left"></div>
    <div class="right"></div>
    <div class="main"></div>
</div>
```


### 缺点
* 由于dom顺序，无法先加载content
* 显示的顺序和dom的顺序不一致，不好理解

## 绝对定位方式

绝对定位的元素也会脱离文档流，会相对于最近的定位的祖先元素进行定位。

### 实现
注意定位元素的设置
```css
.main {
    height: 200px;
    margin: 0 220px;
    background-color: green;
}
.left {
    position: absolute;
    width: 200px;
    height: 200px;
    top: 0;
    left: 0;
    background-color: red;
}
.right {
    position: absolute;
    width: 200px;
    height: 200px;
    background-color: blue;
    top: 0;
    right: 0;
}
```
dom节点可以随意排列
```html
<div class="container">
    <div class="left"></div>
    <div class="right"></div>
    <div class="main"></div>
</div>
```

### 优缺点
**优点：**
* 可以按照dom的顺序排列，也可以将content排在前面。

**缺点：**
* 容器脱离了文档流，后代元素也脱离了文档流
* 高度未知的时候，会有问题

## Table实现
table的使用越来越少了。

### 实现
```css
.container {
    display: table;
    width: 100%;
}
.left, .main, .right {
    display: table-cell;
}
.left {
    width: 200px;
    height: 200px;
    background-color: red;
}
.main {
    background-color: green;
}
.right {
    width: 200px;
    height: 200px;
    background-color: blue;
}
```
```html
<div class="container">
    <div class="left"></div>
    <div class="right"></div>
    <div class="main"></div>
</div>
```
### 优缺点
**优点：**
* 兼容性良好

**缺点：**
* 无法设置栏边距
* 对seo不友好
* 高度会同时增加

## grid布局
CSS Grid Layout的兼容性的确还是不容乐观，不过看起来也是已经一片绿了，api有可能还会变动，但是使用起来简单方便。
![](http://oankigr4l.bkt.clouddn.com/201808061632_61.png)
### 实现
```
.container {
    display: grid;
    width: 100%;
    grid-template-rows: 200px;
    grid-template-columns: 200px auto 200px;
}
.left {
    background-color: red;
}
.main {
    margin: 0 20px;
    background-color: green;
}
.right {
    background-color: blue;
}
```

```html
<div class="container">
    <div class="left"></div>
    <div class="right"></div>
    <div class="main"></div>
</div>
```

## Flex布局
flex给我们布局提供很大的便利，很多在css2.1时代实现的很麻烦的布局，都可以通过flex很容易的实现，而且语义也很好。对三栏布局的实现，主要用到了flew-grow(发大比例，默认为0),flex-shrink（缩小比例，默认为1）,flex-basis(计算是否有多余空间，默认为auto)。可以使用这三个属性的缩写形式，**建议优先使用这个属性，而不是单独写三个分离的属性，因为浏览器会推算相关值。**

```css
// 默认值为0 1 auto
.item {
  flex: none | [ <'flex-grow'> <'flex-shrink'>? || <'flex-basis'> ]
}

// 有两个快捷值：auto (1 1 auto) 和 none (0 0 auto)
```
### 实现
```css
.container {
    display: flex;
}
.main {
    flex: 1;
    margin: 0 20px;
    height: 200px;
    background-color: green;
}
.left {
    width: 200px;
    height: 200px;
    background-color: red;
}
.right {
    width: 200px;
    height: 200px;
    background-color: blue;
}
```

```html
<div class="container">
    <div class="left"></div>
    <div class="right"></div>
    <div class="main"></div>
</div>
```

## 圣杯布局
实现这些的目的就是在实现布局的基础上，content在dom的最前面，同时又有很好的兼容性。

### 实现
```css
.container {
    margin-left: 220px;       /* 为左右栏腾出空间 */
    margin-right: 220px;
}
.main {
    float: left;
    width: 100%;
    height: 200px;
    background-color: green;
}
.left {
    float: left;
    width: 200px;
    height: 200px;
    margin-left: -100%;
    position: relative;
    left: -220px;
    background-color: red;
}
.right {
    float: left;
    width: 200px;
    height: 200px;
    margin-left: -200px;
    position: relative;
    right: -220px;
    background-color: blue;
}
```
DOM结构为中-左-右。.container设置margin-left和margin-right为左右栏腾出空间。
```html
<div class="container">
    <div class="main"></div>
    <div class="left"></div>
    <div class="right"></div>
</div>
```

### 分析
* 给外围的container加上padding：0 220px 0 220px
* 将main部分放在最初的位置，加载最早，为了实现这样，只有将三者都采用float：left,为了调整两边栏的位置，给边栏再加上一个position:relative (因为相对定位后面会用到）
* main部分因为需要自适应，width:100%占满宽度，因此这个时候边栏都在下面一行。
![](http://oankigr4l.bkt.clouddn.com/201808061740_548.png)

* 这时因为main已经占满了，为了将left拉倒最左边，需要使用margin-left:-100%
![](http://oankigr4l.bkt.clouddn.com/201808061742_14.png)

* 这时right还停留在原来的位置，让right向左移动一个身位，marign-left:-200px，right就可以来到上方的最右边。
![](http://oankigr4l.bkt.clouddn.com/201808061742_351.png)

* 这时left会覆盖main的左端，对left使用使用相对定位left:-220px，同理right也要相对定位还原right:-220px
![](http://oankigr4l.bkt.clouddn.com/201808061744_190.png)

## 双飞翼布局
圣杯布局实际看起来是复杂的后期维护性也不是很高，在淘宝UED的探讨下，出来了一种新的布局方式就是双飞翼布局，增加多一个div就可以不用相对布局了，只用到了浮动和负边距。

该布局的出现是出于让圣杯布局更好理解，语义化更好的目的。

### 实现
```css
.main {
    float: left;
    width: 100%;
    height: 200px;

}

.left {
    float: left;
    width: 200px;
    height: 200px;
    margin-left: -100%;
    /*  position: relative;
    left: -220px;         */
    background-color: red;
}

.right {
    float: left;
    width: 200px;
    height: 200px;
    margin-left: -200px;
    /*  position: relative;
        right: -220px;         */
    background-color: blue;
}

.inner {
    margin: 0 220px;
    height: 200px;
    background-color: green;
}
```

给main添加一个包裹，类似张鑫旭大神提出的**“宽度分离准则”**，利用这个准则就可以很好的利用**块元素的流体特性，铺满可用空间。**

### 分析
先将main部分放好，然后再将“翅膀”移动到相应的位置。
* main放在dom的最前面，紧接着是left、right
* 三部分都是float:left
* 将main铺满width:100%
* 这时将left拉上去margin-left：-100%，同理right使用margin-right:-200px。一直到这里都和圣杯布局很类似
* main被占满了，除了使用container的padding（圣杯），还可以给main增加一个内层div包裹，添加margin: 0 220px 0 220px
* 这时就可以了


## 总结
对于中间自适应的实现，我们需要利用其流体特性，而因为我们又必须考虑兼容性，又要让main最先加载到dom中，对整体的布局影响又较小。

简单的Float方式dom的顺序不可修改，main需要最后添加；绝对布局的方式脱离了文档流，对布局影响较大；Table布局会越来越少，而且其高度、间隔的也有限制；flex,grid的方式兼容性还是个问题；圣杯布局虽好，但是position:realtive和相对定位的添加，使得代码不好理解，可维护性较差。

综合分析，双飞翼布局相对于圣杯布局，增加了一个div，完美使用了宽度分离准则，使得代码更好理解，可维护性最高。


**参考资料**
[CSS布局 -- 圣杯布局 & 双飞翼布局](https://www.cnblogs.com/imwtr/p/4441741.html#top)
[]()

![](http://oankigr4l.bkt.clouddn.com/wexin.png)