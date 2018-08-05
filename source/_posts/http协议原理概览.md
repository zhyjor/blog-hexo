---
title: http协议原理概览
tags:
  - http
categories: http
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


## 缓存

### 代理缓存
vary头，告诉代理服务器根据不同的http客户端返回不同的信息

### cache-control
public:代理服务器，电脑浏览器，等http经过的地方都可以直接缓存
private:发起请求的客户端才可以缓存
no-cache：任何节点都不缓存，可以缓存，但是每次都要去服务器去验证

### max-age
到期，xx seconds，多少秒
### s-maxage
带代理服务器生效，专门为代理服务器设置

### max-stale
浏览器，发起请求的一方带的，假如缓存已经过期，但是还在这个设置内，就使用过期的，服务端无用

### must-revalidate
重新验证
### proxy-revalidate
缓存服务器过期，重新去验证，很少用到

### no-store
严格的无本地，代理服务器的缓存

### no-transform
用在proxy服务器上，不改变传回的内容

## 资源验证（last-modifty和E-tag）

### Last-Modified
上次的修改时间，配合If-modified-since或者If-Unmodified-Since(很少用到)

对比上次修改时间确定是否需要更新

### Etag
数据签名，类似hash计算。标记这个资源，配合If-Match或者If-Non-Match使用

根据资源的签名判断是否需要缓存。

## Cookie
通过set-cookie设置，浏览器下次可以自动带上。使用max-age，expires设置过期时间，secure只有https使用，httponly无法通过document.cookie使用访问

set-cookie可以使用多个，未设置过期时间的话cookie就在浏览器关闭的时候过期。

过期后就不会在请求的时候带上。

无法跨域访问，但是二级域名可以通过一些方式实现。这里可以通过服务器自己实现。可以通过domain设置。并且是在访问一级域名的时候设置domain，在访问二级域名的时候无法写入。cookie是session是不同的东西，但是我们通过用cookie来保存session,就是将sessionid保存到cookie中，可以通过cookie拿到这个key。

session只要能定位到用户，就是一种方案。不一定用cookie实现。

## http长连接（Connection:keep-alive/close）
连接立即就关闭，可以减少并发，但是假如并发很大的话，可能会开销更大。

就是devtools上的connection id,同一个tcp上不能并发http请求。chrome一次性并发6个tcp连接，到了6个之后，剩余的就只能等着了。之后就是在这上面复用了。

但是服务器可以用返回值来确定是否保持。

使用close的话，每个connectionId都是不一样的，每次请求完成后就关闭了，没有进行复用。

在http2中有**信道复用**的概念，可以并发的在一个tcp中进行http请求，这样，一个连接就可以完成一个网页加载的所有http请求，但是注意这个需要在同域的情况下进行。

## 数据协商
### 请求

Accept:我想要的数据类型
Accept-Encoding：压缩方式等
Accept-Language:语言
User-Agent：浏览器信息。

### 响应
Content-type:
Content-Encoding:gzip
Content-Language:

### MIME types
注意规则

### x-content-type-options:nosniff
不要预测返回的内容

### contend-encoding
需要手动进行压缩。而且需要注意头部信息和body信息的大小。


## Redirect
服务器需要告诉浏览器你要请求的资源在哪个地方，不能直接返回404.

添加一个**code:302**,只有302才会跳转，临时跳转。假如你能确认以后都是新的地方了，就返回**code:301，永久转移**。

两者的区别是301就是永久的转移，以后就直接去新的url就可以，302每次都要去服务器访问一下，而且从301那里都是从浏览器缓存中读取的。301需要慎重。

Location:'./new/index.html'

## Content-Security-Policy（CSP）
内容安全策略
限制资源获取，报告资源获取越权

### 限制方式
default-src限制全局，可以资源类型来限制。img-src,media-src...等等，只要外链加载的都可以在这里限制。

内联的js代码禁用，可以通过default-src: http: https:等等类似的限制。

还可以限制外链的域名限制，可以只允许同域的连接。

还可一限制form表单的限制。不能提交到别的域名。

mdn:csp

### 越权报告
report-uri /report

### meta的方式来写

不仅仅可以通过header来写，还可以通过meta来写，但是这个时候不好用report，而且**推荐使用header的方式。**

## https

### 加密
私钥：只放在服务器上，通过公钥加密的只能通过私钥解密

公钥私钥只出现在握手的时候，传送加密字符串。两边通过这个字符串进行加密解密。

1：随机数1+加密套件
2：随机数2+加密套件选择+公钥（证书）
3：随机数3（公钥加密过的），中间人已经拿不到了
4：三个随机数和加密套件生成两边的加密方式

## http2
开启了https才能使用http2,演化与spdy（这个必须有https）,本身的http2并没有限制。
### 信道复用
对于http/1.1并发连接数限制，chrome限制6个，就需要6次完整的握手，对服务器的tcp连接数也是制约。单个tcp是串行的
单个tcp链接就可以

### 分帧传输
数据接收完后，可以根据帧顺序重新组合。

#### server push
link标签 rel=preload


**参考资料**
[]()

![](http://oankigr4l.bkt.clouddn.com/wexin.png)