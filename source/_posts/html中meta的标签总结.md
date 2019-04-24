---
title: html中meta的标签总结
date: 2017-10-12 18:26:24
tags:   
  - html
  - meta
  - 适配
categories: html
copyright: true
---

我们没打开一个页面查看源码时都会在header标签内看到看到`<meta>`，meta标签到底有什么用呢？
<!--more-->

### 简介
在w3school中
> the `<mete>`tag provides metadata anout the HTML docments.Metadata will not be displayed on the page,but will be machine parsable.

也就是说**提供用于描述数据的元数据**，不会显示在页面上，但是可以被机器识别。

### 组成
meta标签共有两个属性，分别是http-equiv和name属性

#### name属性
用于描述网页，比如网页的关键词、叙述等。对应的是content，content中的内容是对name属性的具体描述：
`<meta name="参数" content="具体的描述">`

*  keywords(关键字)
*  description(网站内容的描述)
*  viewport(移动端的窗口),**这个属性很重要，移动端的页面会用到**
*  robots(定义搜索引擎爬虫的索引方式)
*  author(作者)
*  generator(网页制作软件)
*  copyright(版权)
*  revisit-after(搜索引擎爬虫重访时间)，用来减轻爬虫带来的服务器压力
*  renderer(双核浏览器渲染方式),renderer是为双核浏览器准备的，用于指定双核浏览器默认以何种方式渲染页面。`<meta name="renderer" content="webkit"> //默认webkit内核`


#### http-equiv属性
用来定义些HTTP参数：
`<meta http-equiv="参数" content="具体的描述">`

* content-Type(设定网页字符集)(推荐使用HTML5的方式)
`<meta http-equiv="content-Type" content="text/html;charset=utf-8">  //旧的HTML，不推荐`,
`<meta charset="utf-8"> //HTML5设定网页字符集的方式，推荐使用UTF-8`
* X-UA-Compatible(浏览器采取何种版本渲染当前页面)
`<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/> //指定IE和Chrome使用最新版本渲染当前页面`
* **cache-control(指定请求和响应遵循的缓存机制)** 
用法1.
说明：指导浏览器如何缓存某个响应以及缓存多长时间
![](https://segmentfault.com/image?src=http://7xoxxe.com1.z0.glb.clouddn.com/cache.png&objectId=1190000004279791&token=60cc5b81792e199feb8a6b032aff4b83)

* 用法2.(禁止百度自动转码)
`<meta http-equiv="Cache-Control" content="no-siteapp" />`
* expires(网页到期时间)`<meta http-equiv="expires" content="Sunday 26 October 2016 01:00 GMT" />`
* refresh(自动刷新并指向某页面)`<meta http-equiv="refresh" content="2；URL=http://www.lxxyx.win/"> //意思是2秒后跳转向我的博客`
* Set-Cookie(cookie设定)
`<meta http-equiv="Set-Cookie" content="name, date"> //格式`
`<meta http-equiv="Set-Cookie" content="User=Lxxyx; path=/; expires=Sunday, 10-Jan-16 10:00:00 GMT"> //具体范例`

### 总结
还有其他自定义的标签待慢慢整理。

[参考](http://www.cnblogs.com/wangyang108/p/5995379.html)
[参考](http://blog.csdn.net/kongjiea/article/details/17092413)

![](http://static.zhyjor.com/8192dd88gy1fkekqx6gnoj20q10ftq4b.jpg)

