---
title: js基础之Date类的使用及时间api
tags:
  - js
  - Date
  - 基础
copyright: true
date: 2017-11-14 14:02:42
categories: js
---
JavaScript Date（日期）对象,日期对象用于处理日期和时间。
<!--more-->

>getTime()
getTime() 返回从 1970 年 1 月 1 日至今的毫秒数。
setFullYear()
如何使用 setFullYear() 设置具体的日期。
toUTCString()
如何使用 toUTCString() 将当日的日期（根据 UTC）转换为字符串。
getDay()
如何使用 getDay() 和数组来显示星期，而不仅仅是数字。

### 定义日期
Date 对象用于处理日期和时间。
可以通过 new 关键词来定义 Date 对象。以下代码定义了名为 myDate 的 Date 对象：
```
var myDate=new Date() 
```
注释：Date 对象自动使用当前的日期和时间作为其初始值。

### 操作日期
通过使用针对日期对象的方法，我们可以很容易地对日期进行操作。
在下面的例子中，我们为日期对象设置了一个特定的日期 (2008 年 8 月 9 日)：
```
var myDate=new Date()
myDate.setFullYear(2008,7,9)
```
注意：表示月份的参数介于 0 到 11 之间。也就是说，如果希望把月设置为 8 月，则参数应该是 7。
在下面的例子中，我们将日期对象设置为 5 天后的日期：
```
var myDate=new Date()
myDate.setDate(myDate.getDate()+5)
```
注意：如果增加天数会改变月份或者年份，那么日期对象会自动完成这种转换。

### 比较日期
日期对象也可用于比较两个日期。
下面的代码将当前日期与 2008 年 8 月 9 日做了比较：
```
var myDate=new Date();
myDate.setFullYear(2008,8,9);

var today = new Date();

if (myDate>today)
{
alert("Today is before 9th August 2008");
}
else
{
alert("Today is after 9th August 2008");
}
```