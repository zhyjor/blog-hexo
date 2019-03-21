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

### InternalErrorError
```
{
	"category": "error",
	"action": "uploadError",
	"content": "{\"message\":\"Failed to upload some parts with error: InternalErrorError: Please contact the server administrator, oss@service.aliyun.com part_num: 5\",\"code\":\"InternalError\",\"stack\":\"InternalErrorError: Please contact the server administrator, oss@service.aliyun.com\\n    at D.<anonymous> (https://s.newscdn.cn/magic-web/vendor-354a12cd77cd42c10f59.js:17:1498154)\\n    at _ (https://s.newscdn.cn/magic-web/vendor-354a12cd77cd42c10f59.js:58:55290)\\n    at Generator._invoke (https://s.newscdn.cn/magic-web/vendor-354a12cd77cd42c10f59.js:58:55078)\\n    at Generator.e.(anonymous function) [as next] (https://s.newscdn.cn/magic-web/vendor-354a12cd77cd42c10f59.js:58:55469)\\n    at _ (https://s.newscdn.cn/magic-web/vendor-354a12cd77cd42c10f59.js:58:55290)\\n    at t (https://s.newscdn.cn/magic-web/vendor-354a12cd77cd42c10f59.js:58:55605)\\n    at https://s.newscdn.cn/magic-web/vendor-354a12cd77cd42c10f59.js:58:55754\"}"
}
```



**参考资料**
[]()

![](http://oankigr4l.bkt.clouddn.com/wexin.png)