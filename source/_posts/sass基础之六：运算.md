---
title: sass基础之六：运算
tags:
  - sass基础
  - sass
  - css预处理器
categories: css
copyright: true
date: 2017-03-26 10:22:23
---
sass具有运算的特性，可以对数值型的Value(如：数字、颜色、变量等)进行加减乘除四则运算
<!--more-->

### 普通运算
**运算符的格式要求，前后请留一个空格，不然会出错。**
```
$baseFontSize:          14px !default;
$baseLineHeight:        1.5 !default;
$baseGap:               $baseFontSize * $baseLineHeight !default;
$halfBaseGap:           $baseGap / 2  !default;
$samllFontSize:         $baseFontSize - 2px  !default;

//grid 
$_columns:                     12 !default;      // Total number of columns
$_column-width:                60px !default;   // Width of a single column
$_gutter:                      20px !default;     // Width of the gutter
$_gridsystem-width:            $_columns * ($_column-width + $_gutter); //grid system width
```

**sass在带单位计算时，有些写法解析出来会多个空格**
```
//sass
@for $num from 1 through 12 {
      &:nth-child(#{$num}) {
        animation-delay: (($num - 1)/12) s;
        transform: rotate(30deg * ($num - 6)) translateY(-150%);
      }
    }

//css
xxx:nth-child(2) {
    animation-delay: 0.08333 s;// 这里多了一个空格
    transform: rotate(-120deg) translateY(-150%);
}

// 修改后的写法
animation-delay: (($num - 1)/12) + s;
// 或者
animation-delay: (($num - 1)/12) * 1s;
```



### 条件判断
#### @if判断
@if可一个条件单独使用，也可以和 @else结合多条件使用
```
//sass style
//-------------------------------
$lte7: true;
$type: monster;
.ib{
    display:inline-block;
    @if $lte7 {
        *display:inline;
        *zoom:1;
    }
}
p {
  @if $type == ocean {
    color: blue;
  } @else if $type == matador {
    color: red;
  } @else if $type == monster {
    color: green;
  } @else {
    color: black;
  }
}

//css style
//-------------------------------
.ib{
    display:inline-block;
    *display:inline;
    *zoom:1;
}
p {
  color: green; 
}
```

#### 三目判断
语法为： if($condition, $if_true, $if_false) 。三个参数分别表示：条件，条件为真的值，条件为假的值。
```
if(true, 1px, 2px) => 1px
if(false, 1px, 2px) => 2px
```
### 循环
#### for循环
for循环有两种形式，分别为： @for $var from <start> through <end>和 @for $var from <start> to <end>。$i表示变量，start表示起始值，end表示结束值，**这两个的区别是关键字through表示包括end这个数，而to则不包括end这个数。**

```
//sass style
//-------------------------------
@for $i from 1 through 3 {
  .item-#{$i} { width: 2em * $i; }
}

//css style
//-------------------------------
.item-1 {
  width: 2em; 
}
.item-2 {
  width: 4em; 
}
.item-3 {
  width: 6em; 
}
```
#### @each循环
语法为： @each $var in <list or map>。其中 $var表示变量，而list和map表示list类型数据和map类型数据。sass 3.3.0新加入了多字段循环和map数据循环。
**单个字段list数据循环**
```
//sass style
//-------------------------------
$animal-list: puma, sea-slug, egret, salamander;
@each $animal in $animal-list {
  .#{$animal}-icon {
    background-image: url('/images/#{$animal}.png');
  }
}

//css style
//-------------------------------
.puma-icon {
  background-image: url('/images/puma.png'); 
}
.sea-slug-icon {
  background-image: url('/images/sea-slug.png'); 
}
.egret-icon {
  background-image: url('/images/egret.png'); 
}
.salamander-icon {
  background-image: url('/images/salamander.png'); 
}
```
**多个字段list数据循环**
```
//sass style
//-------------------------------
$animal-data: (puma, black, default),(sea-slug, blue, pointer),(egret, white, move);
@each $animal, $color, $cursor in $animal-data {
  .#{$animal}-icon {
    background-image: url('/images/#{$animal}.png');
    border: 2px solid $color;
    cursor: $cursor;
  }
}

//css style
//-------------------------------
.puma-icon {
  background-image: url('/images/puma.png');
  border: 2px solid black;
  cursor: default; 
}
.sea-slug-icon {
  background-image: url('/images/sea-slug.png');
  border: 2px solid blue;
  cursor: pointer; 
}
.egret-icon {
  background-image: url('/images/egret.png');
  border: 2px solid white;
  cursor: move; 
}
```
**多个字段map数据循环**
```
//sass style
//-------------------------------
$headings: (h1: 2em, h2: 1.5em, h3: 1.2em);
@each $header, $size in $headings {
  #{$header} {
    font-size: $size;
  }
}

//css style
//-------------------------------
h1 {
  font-size: 2em; 
}
h2 {
  font-size: 1.5em; 
}
h3 {
  font-size: 1.2em; 
}
```

**参考资料**
[]()

![](http://static.zhyjor.com/wexin.png)
