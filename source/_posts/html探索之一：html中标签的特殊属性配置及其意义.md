---
title: html探索之一：html中标签的特殊属性配置及其意义
tags:
  - html
  - html探索
categories: html
copyright: true
date: 2018-02-05 14:39:30
---

html中标签有很多种，最新的[《html5参考手册》](http://www.w3school.com.cn/tags/index.asp)中，标签数已经达到了120个之多，换句话说html就是由不同的标签组成的。各种标签都会有一些配置属性，比如常见的显示性标签（`<a>、<div>`等）的`class`,`id`等，再比如`<script>`标签的`crossorigin`，这些标签的存在什么意义呢？

<!--more-->
### 什么是标签
> 超文本标记语言（外国语简称：HTML）标记标签通常被称为HTML标签，标签是html语言中最基本的单位。

标签可以成对出现，也可以单独出现；一般单独出现的标签在标签的属性中赋值，特定的标签需要嵌套在不同的标签内。

参考手册有标签的详细名称和分类信息，本文的目的是对常见标签的部分属性进行深入理解，不常见的可以参考[《html5参考手册》](http://www.w3school.com.cn/tags/index.asp)。

### 什么是标签属性
> HTML 标签可以拥有属性。属性提供了有关 HTML 元素的更多的信息。属性总是以名称/值对的形式出现，比如：name="value"。属性总是在 HTML 元素的开始标签中规定。

### 常见的标签属性

#### `<script>`标签的属性
当然该标签最常见的就是其`src`属性，但是我们要说的不是它。

**type属性**


**crossorigin属性**
从名称上看，只是一个解决跨域问题的属性，但是什么时候通过script标签直接加载加载外站的js资源也需要考虑跨域问题了呢。在我的另一篇博客[《打造自己的前端监控》](https://zhyjor.github.io/2018/01/17/%E6%89%93%E9%80%A0%E8%87%AA%E5%B7%B1%E5%89%8D%E7%AB%AF%E7%9B%91%E6%8E%A7%E7%B3%BB%E7%BB%9F%E4%B9%8B%E4%B8%80%EF%BC%9A%E7%90%86%E8%AE%BA%E7%AF%87/)中，我们在获取页面的错误信息是通过`window.onerror`进行的，但是如果引入了跨域的脚本，由于浏览器限制，出于网络安全考虑，跨域脚本只能返回`script error`。Html5规定只有跨域脚本所在的 服务器通过` Access-Controll-Allow-Origin`允许，script标签通过`crossorigin `指定后，才能获取到详细的错误信息。**且只要需要引入跨域资源的标签，都有一样的属性**

**integrity属性**
防止cdn篡改脚本用用的，是校验用的,防止在传输的时候内容丢失或者被恶意修改。如下：

```
<script 
	src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js" 
	integrity="sha256-KXn5puMvxCw+dAYznun+drMdG1IFl3agK0p/pqT9KAo= sha512-2e8qq0ETcfWRI4HJBzQiA3UoyFk6tbNyG+qSaIBZLyW9Xf3sWZHN/lxe9fTh1U45DpPf07yj94KsUHHWe4Yk1A==" 
	crossorigin="anonymous">
</script>
```

#### `<link>`标签
**rel属性**
`<link rel="dns-prefetch" href="//js.cdn.com">` 去预解析域名

**参考资料**
[HTML5 script 标签的 crossorigin 属性到底有什么用？](https://www.chrisyue.com/what-the-hell-is-crossorigin-attribute-in-html-script-tag.html)
[WEB程序员必须知道的关于`<script>`标记的一些小知识](http://www.webhek.com/post/about-script-tag.html)
[浅谈JavaScript异步加载的三种方式——async和defer、动态创建script](https://blog.csdn.net/zhouziyu2011/article/details/60149590)
[]()

![](http://static.zhyjor.com/my_wx_code)
