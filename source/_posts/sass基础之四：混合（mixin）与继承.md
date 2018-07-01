---
title: sass基础之四：混合（mixin）与继承
tags:
  - sass
  - sass基础
  - css预处理器
categories: css
copyright: true
date: 2017-03-23 19:04:20
---
通过@mixin和 % 符合可以复用代码
<!--more-->
### mixin
sass中可以使用@mixin声明混合，可以传递参数，参数名以$开始，多个参数和函数一样以逗号分开，可以在参数后面加上冒号，冒号后面的值是这个参数的默认值。声明的@mixin通过@include来调用
#### 无参数mixin
```
//sass style
//-------------------------------
@mixin center-block {
    margin-left:auto;
    margin-right:auto;
}
.demo{
    @include center-block;
}

//css style
//-------------------------------
.demo{
    margin-left:auto;
    margin-right:auto;
}
```

#### 带参数mixin
调用时可以直接传入值，如果@include传入参数的个数小于@mixin定义的参数的个数，则按照顺序表示，后面不足的使用默认值，**假如未传入值且没有默认值直接报错**，此外还可以通过使用参数名和值同时传入来选择性的传入参数。

```
//sass style
//-------------------------------   
@mixin horizontal-line($border:1px dashed #ccc, $padding:10px){
    border-bottom:$border;
    padding-top:$padding;
    padding-bottom:$padding;  
}
.imgtext-h li{
    @include horizontal-line(1px solid #ccc);
}
.imgtext-h--product li{
    @include horizontal-line($padding:15px);
}

//css style
//-------------------------------
.imgtext-h li {
    border-bottom: 1px solid #cccccc;
    padding-top: 10px;
    padding-bottom: 10px;
}
.imgtext-h--product li {
    border-bottom: 1px dashed #cccccc;
    padding-top: 15px;
    padding-bottom: 15px;
}
```

#### 多组值参数的mixin
如果一个参数可以有多组值，比如box-shadow（给元素添加一个或者多个阴影）,transition等，那么参数则需要在变量后面加上三个点表示，如$variables...
```
//sass style
//-------------------------------   
//box-shadow可以有多组值，所以在变量参数后面添加...
@mixin box-shadow($shadow...) {
  -webkit-box-shadow:$shadow;
  box-shadow:$shadow;
}
.box{
  border:1px solid #ccc;
  @include box-shadow(0 2px 2px rgba(0,0,0,.3),0 3px 3px rgba(0,0,0,.3),0 4px 4px rgba(0,0,0,.3));
}

//css style
//-------------------------------
.box{
  border:1px solid #ccc;
  -webkit-box-shadow:0 2px 2px rgba(0,0,0,.3),0 3px 3px rgba(0,0,0,.3),0 4px 4px rgba(0,0,0,.3);
  box-shadow:0 2px 2px rgba(0,0,0,.3),0 3px 3px rgba(0,0,0,.3),0 4px 4px rgba(0,0,0,.3);
}
```

#### @content

@content在sass3.2.0中引入，可以用来解决css3的@media等带来的问题**（@media与css先后顺序产生的优先级问题???待确定）**。它可以使 @mixin接受一整块样式，接受的样式从@content开始。也就是说`@content`用在`mixin`里面的，当定义一个`mixin`后，并且设置了`@content`；`@include`的时候可以传入相应的内容到`mixin`里面

```
\\ scss
$color: white;
@mixin colors($color: blue) {
  background-color: $color;
  @content;
  border-color: $color;
}
.colors {
  @include colors { color: $color; }
}

\\ 编译后css
.colors {
  background-color: blue;
  color: white;
  border-color: blue;
}
```

**@mixin通过 @include调用后解析出来的样式是以拷贝形式存在的，而继承则是以联合声明的方式存在的，所以从3.2.0版本以后，建议传递参数的用@mixin，而非传递参数类的使用继承 %。**

### 继承（%）
sass中，选择器继承可以让选择器继承另一个选择器的所有样式，并联合声明。使用选择器的继承，要使用关键词 @extend，后面紧跟需要继承的选择器。

#### 简单继承
```
//sass style
//-------------------------------
h1{
  border: 4px solid #ff9aa9;
}
.speaker{
  @extend h1;
  border-width: 2px;
}

//css style
//-------------------------------
h1,.speaker{
  border: 4px solid #ff9aa9;
}
.speaker{
  border-width: 2px;
}
```

#### 占位选择器 %
从sass 3.2.0以后就可以定义占位选择器 %。这种选择器的优势在于：如果不调用则不会有任何多余的css文件，避免了以前在一些基础的文件中预定义了很多基础的样式，然后实际应用中不管是否使用了 @extend去继承相应的样式，都会解析出来所有的样式。占位选择器以 %标识定义，通过 @extend调用。
```
//sass style
//-------------------------------
%ir{
  color: transparent;
  text-shadow: none;
  background-color: transparent;
  border: 0;
}
%clearfix{
  @if $lte7 {
    *zoom: 1;
  }
  &:before,
  &:after {
    content: "";
    display: table;
    font: 0/0 a;
  }
  &:after {
    clear: both;
  }
}
#header{
  h1{
    @extend %ir;
    width:300px;
  }
}
.ir{
  @extend %ir;
}

//css style
//-------------------------------
#header h1,
.ir{
  color: transparent;
  text-shadow: none;
  background-color: transparent;
  border: 0;
}
#header h1{
  width:300px;
}
```
如上代码，定义了两个占位选择器 %ir和 %clearfix，其中 %clearfix这个没有调用，所以解析出来的css样式也就没有clearfix部分。占位选择器的出现，使css文件更加简练可控，没有多余。所以可以用其定义一些基础的样式文件，然后根据需要调用产生相应的css。

**在 @media中暂时不能 @extend @media外的代码片段，以后将会可以。**

### mixin中的循环（each）
在mixin中也可以定义循环，这里之前调用方式参考：
```css
@mixin border-retina ($poses: $border-poses, $border-retina-color: $gray-light) {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 200%;
  height: 200%;
  transform: scale(.5);
  transform-origin: 0 0;
  pointer-events: none;
  box-sizing: border-box;

  @each $pos in $poses {
    border-#{$pos}: 1px solid $border-retina-color;
  }
}
```

**参考资料**
[sass基础](https://www.w3cplus.com/sassguide/syntax.html)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)