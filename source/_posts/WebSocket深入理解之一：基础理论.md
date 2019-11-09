---
title: WebSocket深入理解之一：基础理论
tags:
  - WebSocket
categories: 网络协议
top: false
copyright: true
date: 2018-05-17 15:26:09
---

<!--more-->

![](http://static.zhyjor.com/blog/2019-10-30-161031.jpg)


**参考资料**
[公信宝的主页](https://block.gxb.io/#/)
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
[python模拟websocket握手过程中计算sec-websocket-accept](https://www.cnblogs.com/UnGeek/p/5335462.html)
[HTML5 WebSocket: A Quantum Leap in Scalability for the Web](http://www.websocket.org/quantum.html)
[聊聊从Websocket到协议设计的思考](https://www.jianshu.com/p/10676f210599)
[什么是“258EAFA5-E914-47DA-95CA-C5AB0DC85B11”是指在WebSocket协议](http://www.voidcn.com/article/p-dpnnrfdp-bsu.html)
[看完让你彻底搞懂Websocket原理 转载](https://zhuanlan.zhihu.com/p/26942880)
[MDN upgrade](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Protocol_upgrade_mechanism)
[长连接/websocket/SSE等主流服务器推送技术比较](https://zhuanlan.zhihu.com/p/31297574)
[全双工通信的 WebSocket](https://halfrost.com/websocket/)
[Websocket为什么在客户端向服务端发送报文的时候需要掩码加密，而服务端向客户端不需要呢？](https://www.zhihu.com/question/40019896)
[WebSocket协议中Masking Key有什么用？](http://www.bslxx.com/a/mianshiti/bijingmianjing/2017/1031/1201.html)

![](http://static.zhyjor.com/wexin.png)
