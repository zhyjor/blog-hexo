---
title: 浏览器端ali-oss开车指南
tags:
  - oss
  - 文件上传
categories: oss
top: false
copyright: true
date: 2019-02-28 16:06:33
---
这段时间玩了一下阿里云的对象存储，接入了网页断点续传，真的是开车不规范，亲人两行泪。有很多点还是需要注意的，有时候会有一些奇奇怪怪的问题。
<!--more-->

## 报错信息

### NoSuchUploadError

### EntityTooSmall（实体过小）
```
"EntityTooSmallError: Your proposed upload smaller than the minimum allowed size."
```
触发规则，断点太靠后，造成上传的文件太小。但是有可能已经成功了。

### RequestTimeTooSkewedError
RequestTimeTooSkewedError: The difference between the request time and the current time is too large



**参考资料**
[]()

![](http://oankigr4l.bkt.clouddn.com/wexin.png)