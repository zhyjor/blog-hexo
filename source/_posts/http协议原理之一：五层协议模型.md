---
title: http协议原理之一：五层协议模型
tags:
  - dev
categories: dev
top: false
copyright: true
date: 2018-08-02 11:05:15
---
经典五层模型
<!--more-->
## 经典五层模型
![](http://oankigr4l.bkt.clouddn.com/201808021108_947.png)

### 低三层
* 物理层：物理设备如何传输数据
* 数据链路层，通信实体件建立数据链路连接
* 网络层，为数据再节点之间传输建立逻辑链路

### 传输层
tcp/ip
提供可靠的端到端的服务，分包分片，传输与组装。

向高层屏蔽了下层数据通信的细节。

### 应用层
http
为应用软件提供了很多服务，构建于tcp协议之上，屏蔽网络传输的相关细节。

## http发展历史
### http/0.9
只有一个get,没有header
服务器发送完毕，就关闭tcp连接，同一个tcp连接中现在可以发送多个请求，在http2中游更大的优化。

### http/1.0
添加了很多命令
增加了status code和header
多字符集支持，多部分发送请求，权限，缓存

### http/1.1
优化链接，支持持久链接，一个链接多个请求
增加了pipeline，服务端对于请求需要按照顺序，串行并行优化
添加了host，和其他命令。有了host可以一台物理服务器提供多个web服务，提高效率

### http2
数据都通过二进制帧传输
同一个连连接里发送请求可以不按照顺序，可以并行
头信息压缩以及推送等提高效率的功能（头信息占用带宽很大）

## http的三次握手
tcp连接一直都在，可以发送多次请求，多个请求一个连接就可以了。connection中。
第一次：SYN=1,Seq=x
第二次：SYN=1,ACK=x+1,Seq=Y
第三次：ACK=Y+1,Seq=Z

防止开启无用的连接，网络环境一般不稳定。
第三次握手，还是很必要的。

## url、uri、urn
uniform resource locator
统一资源定位器
http://user:pass@host.com:80/path/?query=string#hash

unifrom resource indentfier
表示互联网上的唯一资源，包括了url,urn

uniform resource  
永久统一资源定位符，在资源移动之后，还能找到位置，业界还没有很好的解决方案

## 报文形式
### 请求报文
首行 GET /test/hi-there.txt HTTP/1.0（换行）
首部 Accept:text/*
（空行）
主体

方法的实现取决与你自己。

### 响应报文
起始行 HTTP/2.0 200 OK
首部

主体

### 方法
用来定义对于资源的操作，语义是定义上的
code: 

## 跨域

### Access-Control-Allow-Origin
这里设置为"*",所有网站都可以，也可以直接设置为域名。 
跨域头，跨域针对的是浏览器，浏览器运行某些标签的跨域比如script,img,link等。

有些情况下不能使用设置这个头来设置。

### CORS预请求
有些头需要服务器进行验证
Access-Control-Allow-Headers
Access-Control-Allow-Methods
Access-Control-Max-Age:'1000'允许跨域的时间



**参考资料**
[]()

![](http://oankigr4l.bkt.clouddn.com/wexin.png)