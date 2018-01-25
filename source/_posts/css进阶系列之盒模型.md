---
title: css进阶系列之盒模型
tags: 
  - css
  - web
 
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




**参考资料**
[深入理解BFC和Margin Collapse](https://www.w3cplus.com/css/understanding-bfc-and-margin-collapse.html)
[神奇的CSS盒子模型](http://blog.csdn.net/eavan_zhou/article/details/52289351)
[CSS盒模型详解](https://juejin.im/post/59ef72f5f265da4320026f76)