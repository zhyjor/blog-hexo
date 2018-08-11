---
title: 常见算法之二：汉诺塔（Hanoi）与递归
tags:
  - 常见算法
  - 数据结构与算法
categories: 数据结构与算法
top: false
copyright: true
date: 2018-02-02 10:28:05
---
汉诺塔是一个印度的古老传说。有三个圆柱，其中一个圆柱上放着若干圆盘，这些圆盘从上到下，直径递增，利用一个辅助圆柱，将原来柱子上的圆盘放到另一个柱子上，依旧是从上到下直径递增。
<!--more-->
## 问题简介

>  汉诺塔：汉诺塔（又称河内塔）问题是源于印度一个古老传说的益智玩具。大梵天创造世界的时候做了三根金刚石柱子，在一根柱子上从下往上按照大小顺序摞着64片黄金圆盘。大梵天命令婆罗门把圆盘从下面开始按大小顺序重新摆放在另一根柱子上。并且规定，在小圆盘上不能放大圆盘，在三根柱子之间一次只能移动一个圆盘。

![](http://oankigr4l.bkt.clouddn.com/201806021034_17.png)

## 递归
递归函数可以高效的操作树形结构，比如浏览器端的文档模型DOM，每次递归调用时处理给定树的一小段。汉诺塔问题就可以使用递归很好的解决

解决方案就是将问题分解为三个小问题，将一堆圆盘移动到另一个柱子上，必要是使用辅助的柱子。首先，将一对圆盘中较小的一个移动到辅助柱子上，露出较大的圆盘，然后移动地下的圆盘到目标柱子上，最后将较小的圆盘重辅助柱子上取下来，移动到目标柱子上。通过递归的调用，处理对圆盘的移动，解决子问题。

```js
function hanoi (disc, a, b, c) {
    if (disc > 0) {
        hanoi(disc - 1, a, c, b)
        console.log('move disc ' + disc + ' from ' + a + ' to ' + c)
        hanoi(disc - 1, b, a, c)
    }
}

hanoi(4, '源', '辅助', '目标')

// console
move disc 1 from 源 to 辅助
move disc 2 from 源 to 目标
move disc 1 from 辅助 to 目标
move disc 3 from 源 to 辅助
move disc 1 from 目标 to 源
move disc 2 from 目标 to 辅助
move disc 1 from 源 to 辅助
move disc 4 from 源 to 目标
move disc 1 from 辅助 to 目标
move disc 2 from 辅助 to 源
move disc 1 from 目标 to 源
move disc 3 from 辅助 to 目标
move disc 1 from 源 to 辅助
move disc 2 from 源 to 目标
move disc 1 from 辅助 to 目标
```
## 尾递归
一些语言提供了尾递归优化（tail recursion）是一种在函数的最后执行递归调用语句的特殊形式的递归。

BTW,如果一个函数返回自身的递归调用结果，那么调用的过程将会被替换为一个循环，可以显著的提高速度。
**参考资料**
[递归和尾递归的区别和原理](https://blog.csdn.net/zcyzsy/article/details/77151709)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)