---
title: vue进阶之一：样式覆盖与scoped作用域
tags:
  - vue
  - vue进阶
categories: vue
top: false
copyright: true
date: 2018-04-17 22:14:23
---
当我们使用框架或者一切其他的官方组件时，为了实现特定的效果需要对框架中的样式进行覆盖。但是webpack在打包编译的时候，在开发环境与生产环境时的覆盖效果可能不同，这需要我们熟悉webpack的打包以及在正确的位置引入文件，一不小心部署后那将是何等的卧槽。另外vue在2.0对style标签引入了scoped，在我们不想各个单文件的样式相互影响的时候就可以使用该属性。但是这个属性在使用`@import`的时候，也是会有问题的。当然这些情况都会在文中详细说明。
<!--more-->
## 为何生产环境与开发环境的覆盖规则不同

## 样式覆盖的正确姿势

## scoped作用域

## scoped与样式覆盖的水火不容性

**参考资料**
[vue ssr,webpack 页面初次渲染时CSS加载顺序问题](https://segmentfault.com/q/1010000010655549)

![](http://static.zhyjor.com/wexin.png)
