---
title: 深入nginx之二：多场景配置
tags:
  - 深入nginx
  - nginx
categories: nginx
top: false
copyright: true
date: 2019-08-24 17:05:17
---
多个场景配置
<!--more-->
## 静态资源web服务
* 普通网站的图片等资源
* CDN场景

### 静态配置
```nginx
Syntax: sendfile on | off;
Default: sendfile off;
Context: http, server,location, if in location

# --with-file-aio 异步文件读取
用的不多

# sendfile 开启等情况下，提高网络包的传输效率,大文件一般打开
Syntax: tcp_nopush on | off;
Default: tcp_nopush off;
Context: http, server, location

# keepalive链接下，提高网络的传输实时性
Syntax: tcp_nodelay on | off;
Defalult: on
Context: http, server,location

# 压缩，服务端压缩，浏览器解压，减少网络消耗
Syntax: gzip on | off;
Defautl: off;
Context: http,server,location, if in location

# 压缩比,需要消耗服务的端端资源，自己确定好比例
Synrtax: gzip_comp_level level;
Default: gzip_comp_level 1;
Context: http,server,location

# 压缩版本，主流的1.1
Syntax: gizp_http_version: 1.0 | 1.1
Default: gzip_http_version 1.1;
Context: http,server,location;

# 压缩模块，预读gzip功能，需要预先压缩好
http_gizp_static_module,预读gzip,对硬盘有要求，保留了两份
http_gunzip_module,浏览器无法支持gzip的场景
```

### 浏览器缓存
浏览器的缓存机制，如Expires,Cache-control
* 校验是否过期，Expires,Cache-control(max-age)
* 协议中的Etag头信息交易，Etag
* Last-Modified头信息校验，秒级的，一秒内的修改就不知道了

```nginx
Syntax: expires [modified] time; expires epoch | max | off;
Default: expires off;
Context: http,server,location,if in location
```

### 跨站访问
```nginx
# Access-Control-Allow-Origin,Access-Control-Allow-Methods
Syntax: add_header name value [always];
Defult: --;
Context: http,server,location,if in location
```

### 防盗链
区别哪些请求时非正常的用户请求，基于http_refer的防盗链配置
还需要更高阶的手段来配置。
```nginx
Syntax: valid_referers none | blocked | server_names | string ...;
Default: --
Context: server,location;
# valid_referers配置的就是变量$invalid_referer
if($invalid_referer){
    return 403;
}
```
## 代理服务
## 负载均衡调度器SLB
## 动态缓存

**参考资料**
[gzip](操作系统的命令)
[curl](可以修改refer信息)


![](http://static.zhyjor.com/wexin.png)