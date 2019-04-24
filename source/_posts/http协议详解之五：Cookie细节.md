---
title: http协议详解之五：Cookie细节
tags:
  - http协议详解
  - http
  - cookie
categories: http
top: false
copyright: true
date: 2018-07-13 14:24:49
---
本身 HTTP 就是一个无状态的协议，但是有时候我们又有需要增加状态的需求，这个时候延伸出来了 Cookie，利用 Cookie 可以让传输的时候保持一些状态信息。
<!--more-->
## Cookie的使用

### 什么是 Cookie？
先明确一点，Cookie 就是为了解决 HTTP 协议无状态的问题。

在 Cookie 的实现上，服务端在收到客户端请求的时候，将一些用户标识信息加入到 Cookie中，随着响应返回给客户端，客户端将 Cookie 中的信息存储在本地，下次再请求此服务器的时候，再将 Cookie 中携带的数据原样传输给服务端，此时服务端就能通过 Cookie 中的用户标识，识别出这是之前请求过的某个用户。
Netscape 官方文档中的定义为：
> Cookie 是指在 HTTP 协议下，服务器或脚本可以维护客户端计算机上信息的一种方式 。通俗地说，Cookie 是一种能够让网站 Web 服务器把少量数据储存到客户端的硬盘或内存里，或是从客户端的硬盘里读取数据的一种技术。 Cookie 文件则是指在浏览某个网站时，由 Web 服务器的 CGI 脚本创建的存储在浏览器客户端计算机上的一个小文本文件。


### 一个完整的 Cookie 传输流程
HTTP 协议中的规则，都是通过在请求头和响应头中写入输入来实现，Cookie 也是这样的。

服务端通过 `Set-Cookie` 这个响应头来向客户端中写入 Cookie 信息，而客户端读取 `Set-Cookie` 这个响应头中的信息存储起来，在下次请求的时候取出来，再通过 `Cookie` 这个请求头，将 Cookie 的数据传输给服务端。
![](http://static.zhyjor.com/201807131400_568.png)
再看一个浏览器中，Cookie 使用的实例。

![](http://static.zhyjor.com/201807131401_437.png)

在响应头（Response Header）中，使用 `Set-Cookie` 传递不同的 Cookie 数据，多个数据可以分开成多个 `Set-Cookie` 头。

在请求头中（Request Header）中，使用 `Cookie` 这个请求头传递 `Cookie` 数据，不同的数据通过 `;`分割。

## Cookie 的细节
到这里，我想你应该弄清楚了 cookie 的整个执行流程，接下来我们再来探究一些 cookie 的细节。

### Cookie 的类型
cookie 其实都是存储在客户端，通常我们说 cookie 对应的客户端，就是在说浏览器。

对于 cookie，我们可以简单的将 cookie 分为两类：会话 cookie、持久 cookie

#### 会话cookie
会话 cookie 是一种临时的 cookie，用于存储一些临时的信息，存储在内存中，会话 cookie 在用户退出浏览器的时候，会被清空删除。而持久 cookie 的生存周期会更长久一些，被存储在磁盘上，浏览器重启后它们依然存在，但是他们会有一个过期的时间，只在此时间之后会被置为失效。

#### 持久cookie

会话 cookie 和持久 cookie 之间唯一的区别就是它们的过期时间，只要是设置了过期时间的 cookie 就是持久 cookie，反之则是会话 cookie。

仔细看前面的流程图中，有一个 domain 的字段是用于标识当前 Cookie 支持的域名的，而想要设置过期时间，可以使用 Expires 或者 Max-Age 参数进行设置，有点类似我们前面讲 HTTP 缓存的参数。

### Cookie 的配置参数
到现在我们已经介绍了两个 Cookie 配置的信息，Domain 和 Expires/Max-Age，分别用来配置域名和过期策略。

这些都很好理解，毕竟浏览器是开放的，它会访问很多不同的网址，如果每个请求都将所有的 Cookie 信息都传递过去，基本上是不现实的。而这些配置参数，就是对 Cookie 增加一些附加的设置，进行一些简单的限制和过滤，在减少传输量的同时也保证了安全。

Domain 这个参数可以限制只在此域名下的请求，才传递该 Cookie，其他的不传递。

Cookie 其实还支持其他的一些参数配置，打开 Chrome 的调试模式，在 Application 中就可以看到当前页面的 Cookie 信息。

下面以一篇微信文章页面所存储的 Cookie 为例。

![](http://static.zhyjor.com/201807131416_368.png)

这个表中，就是当前存储的所有 Cookie 信息，而表头，则是 Chrome 支持的 Cookie 信息。

下面我们分别来介绍它们。
* Name:Value ：Cookie 存储的数据就是一个 Key-Value 的键值对，所以这两个参数没什么争议，就是数据的 Key 和 Value。
* Domain：Cookie 的域，限制请求头传输的域。
* Path：域中与 Cookie 相关的路径前缀。
* Expires/Max-Age：过期时间或者超时间隔。
* http：此属性为 True，表示只会在 HTTP 请求头中携带此 Cookie 信息，而无法通过 document.cookie 来访问此 Cookie。
* Secure：安全，是否只有在使用 SSL 连接时才发送这个 Cookie。

### Set-Cookie2 和 Cookie2
有些资料里会提到 Set-Cookie2 和 Cookie2 ，这些都是历史遗留问题，当初想对 Cookie 再进行一些功能上的扩展，但并未得到广泛的实施，现在已经弃用了。

大家了解一下即可，有兴趣可以参考 [RFC 6265](https://tools.ietf.org/html/rfc6265)。

### 浏览器对 Cookie 的限制
大部分时候我们聊到 Cookie 都在说的是服务器和浏览器进行通信时候，而不同的浏览器对 Cookie 存储的限制是不一样的。例如：单个域名可存储的 Cookie 数量、Cookie 大小等。
![](http://static.zhyjor.com/201807131420_851.png)
在进行页面 Cookie 操作的时候，应该尽量保证 Cookie 的个数小于 20 个，总大小小于 4KB，这是一个安全且保险的范围。

## Cookie的查缺补漏

### Cookie 安全
前面配置 Cookie 参数的时候，有两个参数：http 和 secure 属性，它们就在一定程度上保证了安全。
#### http 属性
设置了 http 属性，标识它是一个 “HttpOnly” 的，那么通过一些脚本程序（例如 JS的 document.cookie）将无法读取到这个 Cookie 信息，它只会出现在请求的报文头内。

#### secure 属性
secure 属性强制该 Cookie 只有在 SSL 的环境下才会想服务器传输，相对也保证了传输的安全。

### Cookie 不支持跨域
Cookie 本身是不支持跨域的，一定程度也保证了 Cookie 的安全，如果非要跨域其实作为前端基本上能做的很少，大部分都需要服务端的二次配合。

例如：nginx 反向代理、Jsonp、nodejs 的 superagent、iframe 等方法。

## 总结
HTTP 中的 Cookie 知识点，基本上都已经讲解清楚了，我们再次总结一下关键知识点。
* Cookie 主要是为了解决 HTTP 协议无状态的问题。
* 服务端通过 Set-Cookie 响应头来向客户端设置 Cookie。
* 客户端通过 Cookie 请求头向服务端发送之前存储的 Cookie 数据。
*  Cookie 依据过期时间进行区分，将类型分为：临时 Cookie 和 持久 Cookie。
*  Cookie 可以通过配置不同的参数，进行限制，例如过期时间、支持的域名、是否安全（secure）等。
*  Cookie 不支持跨域，跨域还需要其他的方式绕开来实现。
*  Cookie 只能做到相对的安全，任何事情没有绝对的安全。


**参考资料**
[cookie-小结](http://www.cnblogs.com/xianyulaodi/p/6476991.html)
[再好好聊一聊 HTTP 中的 Cookie 细节 | 实用 HTTP](https://mp.weixin.qq.com/s/xc8A2dKlZmPHUhFcAevPxw)

![](http://static.zhyjor.com/wexin.png)
