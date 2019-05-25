---
title: JavaScript常见问题之六：类型转换与隐式转换
tags:
  - JavaScript常见问题
  - js
categories: js
top: false
copyright: true
date: 2018-05-10 13:54:23
---
ECMAScript规范对一元运算符的规范
<!--more-->
```js
console.log(1 +  "2" + "2");
console.log(1 +  +"2" + "2");
console.log(1 +  -"1" + "2");
console.log(+"1" +  "1" + "2");
console.log( "A" - "B" + "2");
console.log( "A" - "B" + 2);

```

**参考资料**
[隐式转换的玄学](https://github.com/mqyqingfeng/Blog/issues/26)

![](http://static.zhyjor.com/wexin.png)
