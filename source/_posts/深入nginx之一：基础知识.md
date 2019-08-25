---
title: 深入nginx之一：基础知识
tags:
  - 深入nginx
  - nginx
categories: nginx
top: false
copyright: true
date: 2019-08-24 10:29:09
---
nginx时一款开源的中间件服务软件，阿里自建的也是根据nginx1.6版本来改造的P-Nginx的,已经开源了。Apache的HttpD功能更多。
<!--more-->
## nginx的优点
选用nginx的原因
### IO多路复用epoll
一个socket服用给多个io流，IO流需要获取文件描述符，然后发出系统通知，多个描述符在一个进程内交替完成操作，就是IO复用。
在2.6内核之后，出现了替代select模型的epoll模型，无最大连接数的限制。

### 轻量级
* 功能模块少，只包括http相关模块
* 代码模块少

### CPU亲和（affinity）
为什么需要CPU亲和呢，nginx有多个worker进程，把core和worker进程固定在一个CPU上，减少切换CPU的cache miss，获得更好的性能。

### sendfile
零拷贝，对CDN有好处

## 安装
mainLine、stableVersion、 LegacyVersion
### 安装目录
```
/etc/logrotate.d/nginx 配置文件 日志轮转，用于logrotate日志分割

/etc/nginx 主配置
/etc/nginx/nginx.conf  启动时
/etc/nginx/conf.d 
/etc/nginx/conf.d/default.conf 无变更时

/ect/nginx/fastcgi_params
/etc/nginx/uwsgi_params
/etc/nginx/scgi_params cgi配置

*/koi-utf
*/koi-win
*/koi-win-utf 编码映射转换文件

*/mime.types http中的content-type与扩展名的对应关系

// 守护进程启动器进程管理的
/usr/lib/systemd/system/nginx-debug.service
*/nginx.service
/etc/sysconfig/nginx
*/nginx-debug

// 模块目录
/usr/lib64/nginx/modules
/etc/nginx/modules

// 终端命令
/usr/sbin/nginx
*/nginx-debug

// 帮助手册
/usr/share/doc/*
/usr/share/man/man8/*

// 缓存目录
/var/cache/nginx

// 日志
/var/log/nginx
```

## 编译
### 安装编译参数
```
nginx -v

// 安装目的目录
--perfix=/etc/nginx
--sbin-path=/usr/sbin/nginx
--modules
--conf-path
--error-log
--http-log
--pid-path
--lock-path

// 执行模块临时文件
--http-client-body-temp-path
--https-proxy-temp-path
--http-fastcgi-temp-path
--http-uwsgi-temp-path
--http-scgi-temp-path

// 设置进程启动用户和用户组
--user
--group

// 额外的CFLAGS
--with-cc-opt=parameters

// 设置福建的参数，链接系统库
--with-ld-opt=parameters
```

## nginx.conf 配置语法
```
// defualt.conf
user // 用户
worker_processes  工作进程数目,IO复用相关，并发处理，和core数相同即可
error_log 错误日志
pid  启动pid

// event 
worker_connections 每个进程的最大连接数 6535端口数量，10000个左右
use 工作进程数，定义使用的内核模型

// http
http{
    ... ...
    include // mime.types
    defult_type 
    log_format 
    ... ...
    include // 子文件配置
    server{
        listen 80;
        server_name localhost;
        location / {
            root /usr/share/;
            index index.html index.html;
        }
        error_page 500 /50x.html;
        location /50x.html{
            /user/share/nginx/html;
        }
        server {
            ... ...
        }
    }
}
```
## 日志
主要有
* error.log，错误
* access_log

### 通过log_format配置日志
```
Syntax:log_format name [escape=default[json]] string ...;
Default:
Context:
```
## Nginx变量

http请求变量：arg_PAARAMETER
* http_HEADER
* sent_http_HEADER

内置变量：nginx内置的

自定义变量：自己定义，nginx+Lua

## 模块
nginx -V 里面的--with
### 官方模块
下载到的模块

#### sub_module
```nginx
# 客户端状态,nginx连接的信息,放在server或者location下，访问可以获取
--with-http_stub_status_module
    # 语法
    Syntax: stub_status;
    Default: --
    Context: server, location
    
# 目录中选择一个随机主页
--with-http_random_index_module
    # 语法
    Syntax: random_index on | off
    Default: random_index off
    Context: location
    
# HTTP内容替换
--with-http_sub_module
    # 语法，注意是否只替换一次
    Syntax：sub_filter string repacement;
    Defalult: -
    Context: http, server, location
    # 校验服务端内容是否发生过变更，判断是否有更新，缓存场景
    Syntax: sub_filter_last_modified on|off
    Default: sub_filter_last_modified off;
    Context: http,server,location
    
    # 是否只匹配一次
    Syntax：sub_filter_once on|off
    Default: on;
    Context: http, server,location
```

#### 请求限制
链接频率限制：limit_conn_module
请求频率限制：limit_req_module
多次请求可以建立在一个连接上。
```nginx
# 链接限制
Syntax: limit_conn_zone key zone=name:size;
Default: --;
Context: http

Syntax:limit_conn zone number;
Default: --;
Context: http,server,location

# 请求限制
# $binary_remote_addr 客户端地址 zone-req:1m空间 rate速度
Syntax:limit_req_zone key zone=name;size rate=rate;
Default: --;
Context:http

# burst=3,三个在后一秒执行，限速访问，延时访问；nodelay，直接503
Syntax: limit_req zone=name [burst=number][nodelay]
Defalt: --;
Context: http, server, location
```

#### 访问控制
基于IP的访问控制http_access_module
基于用户的信任登录http_auth_basic_module

```nginx
# 支持ip段
Syntax: allow/deny address | CIDR | unix: | a; 
Default: --
Context: http,server,location,limit,limit_except
```
**这种方式的局限性：**
http_access_module的局限性：中间可能经历了多层的LSB，CDN，Nginx

http_x_forwarded_for：
http_x_forwarded_for=Client IP, Proxy(1) IP, ... ...

解决方案：
* 采用别的Http头信息控制，比如HTTP_X_FORWARD_FOR
* 采用GEO
* 使用HTTP自定义变量

**认证模块http_auth_basic_module**
基本认证模块的访问控制
```nginx
Syntax:atun_basic string | off;
Default: auth_basic off;
Context: http, server, location, limit_except

# 密码文件
Syntax: auth_basic_user_file file;
Default: --;
Context: http, server, location, limit_except
```

**局限性**
* 用户信息依赖文件方式
* 操作机械，效率低下

**解决方案**
* 可以通过nginx+Lua解决
* nginx和LDAP方式打通，利用nginx-auth-ldap模块










**参考资料**
[ab](阿帕奇的一个工具，可以压测)
[htpasswd](一个工具，http-tools,生成密码文件)

![](http://static.zhyjor.com/wexin.png)