---
title: XMLHttpRequest完全解读
tags:
  - 前端
  - XMLHttpRequest
  - ajax
categories: 前端
top: false
copyright: true
date: 2020-06-01 23:54:58
---
在使用中，一直对XMLHttpRequest是一种一知半解的状态，会用但是很多问题都是模棱两可，是时候看看w3c关于XMLHttpRequest的详细资料了。
## 前言
最近做前端上传的时候遇到一个问题，由于minioss（oss的私有版本）无法支持sts授权，使用sdk的方式就只能前端直接拿到sk，但这样是不安全的；后来了解到oss支持对签名URL进行put操作，签名可以放在接口去实现，这样就解决了这个问题；但是现在直接put一个url，怎么拿到进度呢？这时我居然还不知道有xhr.upload.onprgress，本篇文章的来源就是这个！
<!--more-->

**参考资料**
[你真的会使用XMLHttpRequest吗？](https://segmentfault.com/a/1190000004322487)
[【翻译】这个API很“迷人”——(新的Fetch API)](https://www.w3ctech.com/topic/854)

![](http://static.zhyjor.com/wexin.png)