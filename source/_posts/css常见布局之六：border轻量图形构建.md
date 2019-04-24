---
title: css常见布局之六：border轻量图形构建
tags:
  - css常见布局
  - css
categories: css
top: false
copyright: true
date: 2018-06-27 11:31:09
---
css开发中很多常见的小组件，比如图片上传的加号，比如如何优雅的增加可点击的区域。
<!--more-->

## 图片上传
我们在上传图片的时候，往往后面会跟着一个[带有加号的框框按钮](http://demo.cssworld.cn/4/4-1.php)：
```html
<a href class="add" title="继续上传">
  添加图片
</a>
```
```css
.add {
    display: inline-block;
    width: 76px; height: 76px;
    color: #ccc;
    border: 2px dashed;
    text-indent: -12em;
    transition: color .25s;
    position: relative;
    overflow: hidden;
}
.add:hover {
    color: #34538b;
}
.add::before, .add::after {
    content: '';
    position: absolute;
    top: 50%;
    left: 50%;
}
.add::before {
    width: 20px;
    border-top: 4px solid;
    margin: -2px 0 0 -10px;
}
.add::after {
    height: 20px;
    border-left: 4px solid;
    margin: -10px 0 0 -2px;
}
```

## 优雅地增加点击区域大小
在移动端搜索输入框输入内容后，右侧会有一个清除按钮,稳妥的方法是外部再嵌套一层标签，专门控制点击区域大小。如果对代码要求较高，[则可以使用 padding 或者透明 border 增加元素的点击区域大小。](http://demo.cssworld.cn/4/4-2.php)

```html
<input id="search" type="search" value="我是初始值" required>
<label for="search" class="icon-clear"></label>
```

```css
input[type="search"] {
    width: 200px; height: 40px;
    padding: 10px 40px 10px 10px;
    border: 1px solid #ccc;
    box-sizing: border-box;
}
.icon-clear {
    width: 16px; height: 16px;
    margin: 1px 0 0 -38px;
    border: 11px solid transparent;
    border-radius: 50%;
    background: #999;
    color: white;
    position: absolute;
    visibility: hidden;
}
.icon-clear:before {
    content: "×";
}
input:valid + .icon-clear { 
    visibility: visible;
}
```

```js
var eleLabel = document.querySelector('label[for="search"]'),
eleSearch = document.getElementById('search');

if (eleLabel && eleSearch) {
    eleLabel.onclick = function() {
        eleSearch.value = '';
    };
}
```

## 画对话气泡
border 属性可以轻松实现兼容性非常好的三角图形效果，为什么可以呢？ 其底层原因受inset/outset 等看上去没有实用价值的 border-style 属性影响，边框 3D 效果在互联网早期其实还是挺潮的，那个时候人们喜欢有质感的东西，为了呈现逼真的 3D 效果，自然在边框转角的地方一定要等分平滑处理，然后不同的方向赋予不同的颜色。 然后， 这一转角规则也被 solid类型的边框给沿用了。

![](http://static.zhyjor.com/201806271410_992.png)

### 画一个三角形
因为border-style对转角的处理如下，我们当设置其他的三条边界为透明的时候，就会得到一个梯形.
![](http://static.zhyjor.com/201806271415_265.png)
再进一步我们内容区的宽度设置为0的时候，三角形就出现了：
```css
div {
	width: 0;
	border: 10px solid;
	border-color: #f30 transparent transparent;
}
```
![](http://static.zhyjor.com/201806271413_385.png)

当我们修改某些边框的宽度的时候可让三角形的形状发生改变，比如当设置垂直宽度更大，三角形更狭长，当我们设置两侧的某一侧面的边框宽度为零的时候，就会出现一个垂直三角形。
```css
div {
	width: 0;
	border-width: 10px 20px;
	border-style: solid;
	border-color: #f30 #f30 transparent transparent;
}
```
![](http://static.zhyjor.com/201806271417_980.png)

### 气泡画法
如果把两个不同倾斜角度的三角效果叠加，则可以实现更加刁钻的尖角效果
![](http://static.zhyjor.com/201806271424_475.png)

## IE8浏览器添加圆角
利用了border比实际的宽度略少一点
```html
<a href class="button">我是按钮</a>
```
```css
.button {
    display: inline-block;
    line-height: 36px;
    padding: 0 40px;
    color: #fff;
    background-color: #cd0000;
    position: relative;
}
.button:before,
.button:after {
    content: "";
    position: absolute;
    left: 0; right: 0;
    border-style: solid;
}
.button:before {
    top: -2px;
    border-width: 0 2px 2px;
    border-color: transparent transparent #cd0000;
}
.button:after {
    bottom: -2px;
    border-width: 2px 2px 0;
    border-color: #cc0000 transparent transparent;
}
```

**参考资料**
[]()

![](http://static.zhyjor.com/wexin.png)
