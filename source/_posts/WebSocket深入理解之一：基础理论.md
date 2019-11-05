---
title: WebSocket深入理解之一：基础理论
tags:
  - WebSocket
categories: 网络协议
top: false
copyright: true
date: 2018-05-17 15:26:09
---
数据交互频繁且时效性较高的实现，对于没有长连接的前端一直是痛点。使用轮询是一个方案，但是实现的很不优雅，而且对服务端的压力也比较大。WebSocket协议可以说就是为了解决这个问题而生的，安全的http称为https，安全的ws称为wss。
<!--more-->
WebSocket 协议在2008年诞生，2011年成为国际标准。WebSocket 的最大特点就是，服务器可以主动向客户端推送信息，客户端也可以主动向服务器发送信息，是真正的双向平等对话。

## websocket与http
 WebSocket 协议在2008年诞生，2011年成为国际标准。现在所有浏览器都已经支持了。WebSocket 的最大特点就是，服务器可以主动向客户端推送信息，客户端也可以主动向服务器发送信息，是真正的双向平等对话。

HTTP 有 1.1 和 1.0 之说，也就是所谓的 keep-alive ，把多个 HTTP 请求合并为一个，但是 Websocket 其实是一个新协议，跟 HTTP 协议基本没有关系，只是为了兼容现有浏览器，所以在握手阶段使用了 HTTP 。

下面一张图说明了 HTTP 与 WebSocket 的主要区别：
![](http://static.zhyjor.com/blog/2019-10-30-161031.jpg)
 
 
### 说一下keep-alive
HTTP 有 1.1 和 1.0 之说，所谓的 keep-alive ，把多个 HTTP 请求合并为一个。




发现[公信宝的主页](https://block.gxb.io/#/)使用了wss，可以当成一个案例。


**参考资料**
[看完让你彻底理解 WebSocket 原理，附完整的实战代码（包含前端和后端）](http://www.cnblogs.com/nnngu/p/9347635.html?utm_medium=hao.caibaojian.com&utm_source=hao.caibaojian.com)
[【WebSocket No.3】使用WebSocket协议来做服务器](http://www.cnblogs.com/yanbigfeg/p/9330613.html?utm_medium=hao.caibaojian.com&utm_source=hao.caibaojian.com)
[WebSocket协议 8 问](https://mp.weixin.qq.com/s/rfGw-3vI8KiedcebVaAXNw)
[RFC 6455 - The WebSocket Protocol](https://tools.ietf.org/html/rfc6455#section-5.5.2)
[全双工通信的 WebSocket](https://mp.weixin.qq.com/s/-h9UM800bODnEMbfHvKtDw)
[开源gev （支持 websocket 啦）: Go 实现基于 Reactor 模式的非阻塞网络库](https://hacpai.com/article/1571884776910?r=88250)
[如何在 Knative 中部署 WebSocket 和 gRPC 服务？](https://yq.aliyun.com/articles/721268?utm_content=g_1000082463)
[JS 服务器推送技术 WebSocket 入门指北](https://mp.weixin.qq.com/s/IRH0Y8wJjGKsydRWJ6KH7g)
[使用websocket实现B站弹幕查看器](https://zhuanlan.zhihu.com/p/61090556)
[B站直播弹幕协议详解](http://www.lyyyuna.com/2016/03/14/bilibili-danmu01/)
[WebSocket 简介及应用实例](https://juejin.im/post/5ae3eb9b51882567382f5767)
![](http://static.zhyjor.com/wexin.png)
