---
title: WebView性能及优化
date: 2017-09-22 10:20:13
tags:
  - webview
  - android
categories: android
copyright: true
---

一个网页的加载过程，native、网络、后端处理、cpu都会参与，各种都有必要的工作和依赖关系；让各个工作可以并行进行，就可以让网页的加载更快

* WebView初始化慢，可以在初始化同时先请求数据，让后端和网络不要闲着。
* 后端处理慢，可以让服务器分trunk输出，在后端计算的同时前端也加载网络静态资源。
* 脚本执行慢，就让脚本在最后运行，不阻塞页面解析。
* 同时，合理的预加载、预缓存可以让加载速度的瓶颈更小。
* WebView初始化慢，就随时初始化好一个WebView待用。
* DNS和链接慢，想办法复用客户端使用的域名和链接。
* 脚本执行慢，可以把框架代码拆分出来，在请求页面之前就执行好。

