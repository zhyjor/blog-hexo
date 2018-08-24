---
title: nginx实践之四：代理
tags:
  - nginx实践
  - linux
categories: nginx
top: false
copyright: true
date: 2018-08-24 15:58:38
---
常用的代理技术分为正向代理、反向代理和透明代理。
<!--more-->

## 正向代理(Forward Proxy)

![](http://oankigr4l.bkt.clouddn.com/201808241608_835.png)

我们常说的代理也就是只正向代理，正向代理的过程，它隐藏了真实的请求客户端，服务端不知道真实的客户端是谁，客户端请求的服务都被代理服务器代替来请求，某些科学上网工具扮演的就是典型的正向代理角色。用浏览器访问www.google.com时，被残忍的block，于是你可以在国外搭建一台代理服务器，让代理帮我去请求google.com，代理把请求返回的相应结构再返回给我。&oq=我们常说的代理也就是只正向代理，正向代理的过程，它隐藏了真实的请求客户端，服务端不知道真实的客户端是谁，客户端请求的服务都被代理服务器代替来请求，某些科学上网工具扮演的就是典型的正向代理角色。用浏览器访问www.google.com时，被残忍的block，于是你可以在国外搭建一台代理服务器，让代理帮我去请求google.com，代理把请求返回的相应结构再返回给我。
## 反向代理（reverse proxy）
在计算机世界里，由于单个服务器的处理客户端（用户）请求能力有一个极限，当用户的接入请求蜂拥而入时，会造成服务器忙不过来的局面，可以使用多个服务器来共同分担成千上万的用户请求，这些服务器提供相同的服务，对于用户来说，根本感觉不到任何差别。
![](http://oankigr4l.bkt.clouddn.com/201808241607_502.png)
反向代理隐藏了真实的服务端，当我们请求 www.baidu.com 的时候，就像拨打10086一样，背后可能有成千上万台服务器为我们服务，但具体是哪一台，你不知道，也不需要知道，你只需要知道反向代理服务器是谁就好了，www.baidu.com 就是我们的反向代理服务器，反向代理服务器会帮我们把请求转发到真实的服务器那里去。Nginx就是性能非常好的反向代理服务器，用来做负载均衡。

## 区别

看一下知乎上的一张图，画的很形象：

![](http://oankigr4l.bkt.clouddn.com/201808241620_392.png)

正向代理中，proxy和client同属一个LAN，对server透明； 反向代理中，proxy和server同属一个LAN，对client透明。 实际上proxy在两种代理中做的事都是代为收发请求和响应，不过从结构上来看正好左右互换了下，所以把前者那种代理方式叫做正向代理，后者叫做反向代理。

### 用途
正向代理用途是为了在防火墙内的局域网提供访问internet的途径。另外还可以使用缓冲特性减少网络使用率。反向代理的用途是将防火墙后面的服务器提供给internet用户访问。同时还可以完成诸如负载均衡等功能。

### 安全性
正向代理允许客户端通过它访问任意网站并且隐蔽客户端自身，因此你必须采取安全措施来确保仅为经过授权的客户端提供服务。反向代理对外是透明的，访问者并不知道自己访问的是代理。对访问者而言，他以为访问的就是原始服务器

### 使用场景
正向代理的典型用途是为在防火墙内的局域网客户端提供访问Internet的途径（如科学上网）。正向代理还可以使用缓冲特性减少网络使用率。反向代理的典型用途是将防火墙后面的服务器提供给Internet用户访问，保护和隐藏原始资源服务器。反向代理还可以为后端的多台服务器提供负载平衡，或为后端较慢的服务器提供缓冲服务。当反向代理服务器不止一个的时候，我们甚至可以把它们做成集群，当更多的用户访问资源服务器B的时候，让不同的代理服务器Z（x）去应答不同的用户，然后发送不同用户需要的资源。



## 透明代理
如果把正向代理、反向代理和透明代理按照人类血缘关系来划分的话。那么正向代理和透明代理是很明显堂亲关系，而正向代理和反向代理就是表亲关系了 。透明代理比较类似正向代理的功能，差别在于客户端根本不知道代理的存在，它改编你的request，并会传送真实IP（使用场景就是公司限制网络的访问）。

比如为了工作效率或者安全，A公司屏蔽了QQ软件的使用。A公司的员工接上了网络，但发现无法使用qq。这就是透明代理捣的鬼。公司在内网和外网的中间插入一个透明代理，这个代理会根据规则抓取请求内容，遇到qq的请求我就把这个请求给屏蔽掉，这样就完成了透明屏蔽。当然了，如果你明白原理，就可以自己搞个正向代理来绕过公司的屏蔽。




## 用nginx的反向代理机制解决前端跨域问题
禁止跨域问题其实是浏览器的一种安全行为，而现在的大多数解决方案都是用标签可以跨域访问的这个漏洞或者是技巧去完成，但都少不了目标服务器做相应的改变。假如目标服务器不能返回这个header呢？

### 跨域常见解决方案
跨域解决方案有多种，大多是利用JS Hack。
* document.domain+iframe的设置
* 动态创建script
* 利用iframe和location.hash
* window.name实现的跨域数据传输
* 使用HTML5 postMessage
* 利用flash
* Jquery JSONP
* 跨域资源共享(CORS)
* Nginx反向代理

### Nginx反向代理实现跨域
本文介绍的是通过Nginx反向代理解决跨域，这也是最简单实现跨域的方法。只需要修改Nginx的配置即可解决跨域问题，支持所有浏览器，支持Session，不需要修改任何代码，并且不会影响服务器性能。

我们只需要配置Nginx，在一个服务器上配置多个前缀来转发http/https请求到多个真实的服务器即可。这样这个服务器上所有URL都是相同的域名、协议和端口。因此，对于浏览器来说这些URL都是同源的，没有跨域限制。而实际上这些URL实际上由物理服务器提供服务。这些服务器内的JavaScript可以跨域调用所有这些服务器上的URL。

简单说，Nginx服务器欺骗了浏览器，让它认为这是同源调用，从而解决了浏览器的跨域问题。

下面给出一个Nginx支持跨域的例子，进行具体说明。

> 服务器A(域名:www.hi-linux.com)中有一个页面，想请求服务器B(域名:www.imike.me)中的api地址(http://www.imike.me/api)获取数据。

修改配置文件:
```
server {

    listen 80;
    server_name www.hi-linux.com;
    root /var/www/html;
    autoindex off;
    index index.html index.htm index.php;

    # 将www.hi-linux.com/api的所有请求反向代理到www.imike.me
	
    location ~ ^/api/ {
        proxy_pass http://www.imike.me;
        proxy_redirect          off; 
        proxy_set_header        X-Real-IP       $remote_addr; 
        proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for; 
    }

    location ~ /\.ht {
       deny  all;
    }
}
```
重启Nginx
```
/etc/init.d/nginx restart
```
修改JS代码中的地址:
```js
function getID(){ 
	$.get("http://www.hi-linux.com/api/GetData?id=1”, 
	  function (data, textStatus){ 
        options; // 在这里this指向的是Ajax请求的选项配置信息 
        if(textStatus=="success"){ 
        } 
      });  
}
```

访问`http://www.hi-linux.com/api/`下的URL都会被代理到`http://www.imike.me/api/`下。

proxy_pass转发的路径后是否带 “/”也是有区别的。

## 总结
阅读完本文，在前端开发中遇到了跨域时就可以自己通过nginx优雅的解决了，基本不用修改任何代码。

**参考资料**
[Nginx 反向代理为什么可以提高网站性能？](https://www.zhihu.com/question/19761434)
[nginx常用代理配置](https://www.cnblogs.com/fanzhidongyzby/p/5194895.html)
[正向代理与反向代理的区别](https://www.jianshu.com/p/208c02c9dd1d)
[用Nginx反向代理机制解决前端跨域问题](https://www.hi-linux.com/posts/41743.html)
**[图解正向代理、反向代理、透明代理](http://blog.51cto.com/z00w00/1031287)**

![](http://oankigr4l.bkt.clouddn.com/wexin.png)