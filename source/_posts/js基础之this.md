---
title: js基础之this
tags:
  - js
  - this
copyright: true
date: 2017-12-06 09:46:27
categories: js
---
js中的this是一个很关键的概念，使用频繁
<!--more-->
### this的四种定义

* 使用.或者[]调用一个作为对象的属性的方法的时候，this总是指向其函数体的父对象
* 默认，this指向全局对象比如windows；
* 当一个函数使用new操作符调用的时候，在函数内部的this指向了新建的对象
* 当一个函数使用call或apply的时候，this就指向这两个函数传递的第一个参数。如果第一个参数为null或者不是对象，那么this又被指向了全局对象