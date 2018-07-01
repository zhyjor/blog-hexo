---
title: sass基础之二：变量
tags:
  - sass基础
  - sass
  - css预处理器
categories: css
copyright: true
date: 2017-03-22 10:20:32
---
sass的变量必须是$开头，后面紧跟变量名，而变量值和变量名之间就需要使用冒号(:)分隔开（就像CSS属性设置一样），如果值后面加上!default则表示默认值。
<!--more-->
### 普通变量
定义后可以全局使用

### 默认变量
sass的默认变量仅需要在值后面加上 !default即可。可以根据需求覆盖，直接重新声明该属性就可完成覆写（**测试发现与写的位置无关，后续跟进是否有错误**）

### 特殊变量
一般我们定义的变量都为属性值，可直接使用，但是如果变量作为属性或在某些特殊情况下不能直接使用。变量是属性名的一部分的时候就是一种特殊情况，需要按照`#{$variables}`的方式使用。

### 多值变量
多值变量分为list类型和map类型，简单来说list类型有点像js中的数组，而map类型有点像js中的对象。

#### list
list数据可通过空格，逗号或小括号分隔多个值，可用 nth($var,$index)取值。关于list数据操作还有很多其他函数如`length($list)， join($list1,$list2,[$separator])， append($list,$value,[$separator])`

```
//一维数据
$px: 5px 10px 20px 30px;

//二维数据，相当于js中的二维数组
$px: 5px 10px, 20px 30px;
$px: (5px 10px) (20px 30px);

//sass style
//-------------------------------
$linkColor:         #08c #333 !default;//第一个值为默认值，第二个鼠标滑过值
a{
  color:nth($linkColor,1);

  &:hover{
    color:nth($linkColor,2);
  }
}

//css style
//-------------------------------
a{
  color:#08c;
}
a:hover{
  color:#333;
}
```

#### map
map数据以key和value成对出现，其中value又可以是list。格式为：`$map: (key1: value1, key2: value2, key3: value3);`。可通过 `map-get($map,$key)`取值,关于map数据还有很多其他函数如`map-merge($map1,$map2)， map-keys($map)， map-values($map)`

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
### 全局变量
在变量值后面加上 !global即为全局变量。**这个目前还用不上，不过将会在sass 3.4后的版本中正式应用**。目前的sass变量范围饱受诟病，所以才有了这个全局变量。当前的变量机制是在选择器声明的变量会覆盖外面的全局变量的声明，**这就是常说的sass没有局部变量**,而在启用global之后，会是这个样子。


```
//sass style
//-------------------------------
$fontSize:      12px;
$color:         #333;
body{
    $fontSize: 14px;        
    $color：   #fff !global;
    font-size:$fontSize;
    color:$color;
}
p{
    font-size:$fontSize;
    color:$color;
}

//css style
//-------------------------------
body{
    font-size:14px;
    color:#fff;
}
p{
    font-size:12px;
    color:#fff;
}
```

**参考资料**
[sass语法](https://www.w3cplus.com/sassguide/syntax.html)
[sass揭秘之变量](https://www.w3cplus.com/preprocessor/sass-basic-variable.html)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)