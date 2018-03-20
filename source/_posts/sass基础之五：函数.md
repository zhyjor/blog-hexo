---
title: sass基础之五：函数
tags:
  - sass基础
  - sass
  - css预处理器
categories: css
copyright: true
date: 2018-03-20 19:45:52
---
sass定义了很多函数可供使用，尤其是各种比较函数、颜色函数等都是特别方便，当然你也可以自己定义函数，自定义函数以@fuction开始。
<!--more-->
### 系统函数
#### 颜色函数
实际项目中我们使用最多的应该是颜色函数，从大的方面主要分为RGB、HSL和Opacity三大类函数。而颜色函数中又以lighten减淡和darken加深为最，其调用方法为 lighten($color,$amount)和 darken($color,$amount)，它们的第一个参数都是颜色值，第二个参数都是百分比。主要的颜色函数如下：

*  RGB颜色函数，RGBA()函数
*  `mix($color-1,$color-2,$weight)`函数，是将两种颜色根据一定的比例混合在一起，生成另一种颜色，默认比例是50%，可以设置,$weight指第一种颜色的比例
*  HSL颜色函数，HSL”所表示的是“H:色相”，“S：饱和度”，“L：亮度”。
*  lighten() & darken()函数，两个函数都是围绕颜色的亮度值做调整的
*  saturate() & desaturate()函数，通过改变颜色的饱和度来得到一个新的颜色
*  ...

#### 字符串函数
处理字符串的函数
* unquote($string),删除字符串中的引号
* quote($string),添加引号，中间不能有引号或者空格

#### 数字函数
* percentage($value)：将一个不带单位的数转换成百分比值；
* round($value)：将数值四舍五入，转换成一个最接近的整数，可以带单位，；
* ceil($value)：将大于自己的小数转换成下一位整数；
* floor($value)：将一个数去除他的小数部分；
* abs($value)：返回一个数的绝对值；
* min($numbers…)：找出几个数值之间的最小值；
* max($numbers…)：找出几个数值之间的最大值

#### List函数
列表函数主要包括一些对列表参数的函数使用，主要包括以下几种：

* length($list)：返回一个列表的长度值；参数中的列表参数使用空格隔开，不能使用逗号
* nth($list, $n)：返回一个列表中指定的某个标签值，
* join($list1, $list2, [$separator])：将两个列给连接在一起，变成一个列表；
* append($list1, $val, [$separator])：将某个值放在列表的最后；
* zip($lists…)：将几个列表结合成一个多维的列表；
* index($list, $value)：返回一个值在列表中的位置值。

#### Introspection函数

Introspection函数包括了几个判断型函数：

type-of($value)：返回一个值的类型
unit($number)：返回一个值的单位；
unitless($number)：判断一个值是否带有带位
comparable($number-1, $number-2)：判断两个值是否可以做加、减和合并

#### Miscellaneous函数
在这里把Miscellaneous函数称为三元条件函数，主要因为他和JavaScript中的三元判断非常的相似。他有两个值，当条件成立返回一种值，当条件不成立时返回另一种值：
```
if($condition,$if-true,$if-false)
```
上面表达式的意思是当$condition条件成立时，返回的值为$if-true，否则返回的是$if-false值。


### 自定义函数
自定义函数是用户根据自己一些特殊的需求编写的Sass函数。在很多时候，Sass自带的函数并不能满足功能上的需求，所以很多时候需要自定义一些函数。

例如，我们需要去掉一个值的单位，在这种情形之下,Sass自带的函数是无法帮助我们完成，这个时候我们就需要定义函数：

```
//去掉一个值的单位，如12px => 12 
// eg. strip-units(12px) => 12 
@function strip-units($number){ 
	@return $number / ($number * 0 + 1); 
} 
```
上在演示是一个经典的去除单位的自定义函数，除了这个函数之外，大家还可以根据自己需求定义其他的函数，正如前面介绍的pxToem和pxTorem两个自定义的函数。

### 函数与mixin的不同
* 第一点不同在于sass本身就有一些内置的函数，方便我们调用，如强大的color函数；
* 其次就是它返回的是一个值，而不是一段css样式代码什么的。因此函数只能放在变量位置或者作为属性值

**参考资料**
[sass揭秘之@mixin，%，@function](https://www.w3cplus.com/preprocessor/sass-mixins-function-placeholder.html)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)