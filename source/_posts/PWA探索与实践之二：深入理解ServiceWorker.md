---
title: PWA探索与实践之二：深入理解ServiceWorker
tags:
  - PWA探索与实践
  - PWA
categories: 前端
top: false
copyright: true
date: 2017-05-10 16:13:41
---
PWA最重要的一个部分，service worker。它和传统的Worker相似但又不同。操作Service Worker的方法很简单，只需要简单的register一下。
<!--more-->
Service Worker 讲道理是由两部分构成，一部分是 cache，还有一部分则是 [Worker](https://segmentfault.com/a/1190000006678016)。所以，SW（Service Worker） 本身的执行，就完全不会阻碍当前 js 进程的执行，确保性能第一。那 SW 到底是怎么工作的呢？

* 后台进程: SW 就是一个 worker 独立于当前网页进程。
* 网络代理: SW 可以用来代理请求，缓存文件
* 灵活触发: 需要的时候调起，不需要的时候睡眠（这个是个坑）
* 异步控制: SW 内部使用 promise 来进行控制。

## SW 的生命周期
首先，SW 并不是你网页加载就与生俱来的。如果，你需要使用 SW，你首先需要注册一个 SW，让浏览器为你的网页分配一块内存空间来。并且，你能否注册成功，还需要看你缓存的资源量决定。如果，你需要缓存的静态资源全部保存成功，那么恭喜您，SW 安装成功。如果，其中有一个资源下载失败并且无法缓存，那么这次调起就是失败的。不过，SW 是由重试机制的，这点也不算特别坑。

检查完之后，SW 就进入待机状态。此时，SW 有两种状态，一种是 active，一种是 terminated。就是激活/睡眠。激活是为了工作，睡眠则为了节省内存。这是一开始设计的初衷。如果，SW 已经 OK，那么，你网页的资源都会被 SW 控制，当然，SW 第一次加载除外。

简单的流程图如下：

![](http://oankigr4l.bkt.clouddn.com/201807171724_580.png)

我们可以看到生命周期分为这么几个状态 安装中, 安装后, 激活中, 激活后, 废弃。



**参考资料**
[Service Worker 全面进阶](https://www.villainhr.com/page/2017/01/08/Service%20Worker%20%E5%85%A8%E9%9D%A2%E8%BF%9B%E9%98%B6)
[怎么使用 Service Worker](https://lavas.baidu.com/pwa/offline-and-cache-loading/service-worker/how-to-use-service-worker)
[PWA超简单入门](https://juejin.im/post/5abba6a7f265da239706ec60)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)