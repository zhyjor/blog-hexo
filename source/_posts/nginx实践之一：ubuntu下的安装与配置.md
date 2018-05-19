---
title: nginx实践之一：ubuntu下的安装与配置
tags:
  - nginx实践
categories: nginx
top: false
copyright: true
date: 2018-05-18 09:01:51
---
这篇文章主要讲述如何在ubuntu环境下搭建和配置使用nginx服务器。
系统版本是ubuntu16.04
<!--more-->
## 安装
### 用管理员权限安装
```
sudo apt-get install nginx
// 结果
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following packages were automatically installed and are no longer required:
  linux-headers-4.4.0-112 linux-headers-4.4.0-112-generic
  linux-headers-4.4.0-21 linux-headers-4.4.0-21-generic
  linux-image-4.4.0-112-generic linux-image-4.4.0-21-generic
  linux-image-extra-4.4.0-112-generic linux-image-extra-4.4.0-21-generic
Use 'apt autoremove' to remove them.
The following additional packages will be installed:
  nginx-common nginx-core
Suggested packages:
  fcgiwrap nginx-doc
The following NEW packages will be installed:
  nginx nginx-common nginx-core
0 upgraded, 3 newly installed, 0 to remove and 358 not upgraded.
Need to get 458 kB of archives.
After this operation, 1,482 kB of additional disk space will be used.
Do you want to continue? [Y/n] y
Get:1 http://mirrors.aliyun.com/ubuntu xenial-updates/main amd64 nginx-common all 1.10.3-0ubuntu0.16.04.2 [26.6 kB]
Get:2 http://mirrors.aliyun.com/ubuntu xenial-updates/main amd64 nginx-core amd64 1.10.3-0ubuntu0.16.04.2 [428 kB]
Get:3 http://mirrors.aliyun.com/ubuntu xenial-updates/main amd64 nginx all 
..........

```

### 查看 Nginx 进程是否已经启动
```
ps aux|grep nginx


root      21513  0.0  0.0 124972  1420 ?        Ss   17:57   0:00 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
www-data  21514  0.0  0.0 125336  3136 ?        S    17:57   0:00 nginx: worker process
root      21724  0.0  0.0  14228  1092 pts/1    S+   17:58   0:00 grep --color=auto nginx

```
### 检查访问Nginx

查看 ip 地址 ，访问一下 Nginx,可以使用虚拟机开启nginx，在宿主机上进行调试查看。

![](http://oankigr4l.bkt.clouddn.com/201805180912_307.png)

## 配置
nginx有一个主线程和几个工作线程，主进程的作用是读取配置文件，管理工作进程，工作进程做真正的处理请求。nginx采用event-based模型和OS-based机制，更有效地吧请求分发给各个工作进程。工作进程的数量在配置文件中定义，可以固定数目也可以根据CPU的数量动态地调整。

nginx和各个模块的工作方式已在配置文件中定义。默认情况下文件的名称是nginx.conf，放在/usr/local/nginx/conf, /etc/nginx, 或者/usr/local/etc/nginx等目录下。

###  开启／暂停／重新加载配置
开启服务可以直接使用：`nginx`

一旦nginx服务起起来，就可以通过如下命令进行控制
```
nginx -s signal  
```
其中signal的信号

* stop－－表示快速关闭
* quit－－优雅地关闭
* reload－－重新加载配置文件
* reopen－－重新打开log文件

命令执行之后才能生效，一旦主线程收到这个命令，它就会检查新的配置文件的语法是否正确，然后让配置生效。如果成功之后，主线程会新开一个工作进程，然后发送消息通知旧的工作进程，要求旧的进程停止。
同时也可以发送一些unix命令给nginx服务器，比如kill。这个例子中，信号直接通过给定的进程ID发送给进程。默认情况下nginx服务器的nginx.id在/usr/local/npidginx/logs或者/var/run目录下。如果主线程的ID是62363，那么可以直接发送QUIT命令让主线程停止。

```
kill -s QUIT 62363  
```

### 配置文件的结构
nginx各个模块都是通过指定的配置文件进行控制的。

指令可以是单独的指令，也可以是块指令，单独的指令相当于一条语句，包含指令的名称，和参数之间通过空格断开，指令的最后用分号结束。块指令和单独的指令有相同的语法结构，除了块指令是用一系列的｛｝来表示结尾。块指令里面的指令称之为内容，比如(events, http, server location).

在配置文件中，如果指令在所有的指令之外称这个指令为主指令，events 和http就是主指令，server在http之内，locaton在server之内。

其余的以＃开头的指令都是注释的内容。

### 静态内容服务
这里遇到了两个问题如下
> Q:这里配置静态网页遇到问题，配置二级目录的时候出现404
> A:二级目录的名字需要是实际路径中的名字才可以，如下dist，必须在路径中实际存在

> Q:遇到的第二个问题是部署一个vue项目的时候，图片、css等引用文件获取不到。
> A:这个问题是打包路径的问题，因为在vue打包出的引用js与css是默认是相对路径，域名中的二级路径会找不到。解决方法时再`./config/index.js`中的`assetsPublicPath: '/dist/'`修改成这样。

**先看修改没问题的部署文件**
```
server {
	    listen 7003;
	    server_name _;
	    location / {
			root /home/data/;
	    }
	    location /dist/ {
			root /home/data/vue/;
			index index.html;
        }
	}
```
服务器的一个重要功能就是静态网络服务比如图片和静态的html网页。下面是一个实例，取决于需求，文件可以放置在不同的目录中，比如/data/www/（包含着html文件）以及/data/images/(包含图片)。这需要编辑配置文件，在http指令中包含server指令然后包含两个location位置。

第一步是创建一个sample.html的网页文件放到/dada/www目录中，然后在/data/images/目录中放置一些图片

下面是一个最简单的html示例
```html
<html>  
	<head></head>  
	<body>hello</body>  
</html>  
```
接下来是打开配置文件，默认的配置文件已经有些服务器指令实例，绝大部分都需要注释掉它们。
先注释掉所有的指令，写上如下指令块

按照刚刚解释的内容
```
location / {  
    root /data/www;  
}  
```
它需要请求路径中包含/images/,前面说道的 / 也是满足要求的,在这个路径不满足的情况下，会使用 / 路径。
下面是一个完整的html配置文件

```
http {  
    server / {  
        root /data/www;  
    }  
    server /images/ {  
        root /data;  
    }  
}  
```
这个配置文件会监听标准的80端口，可以通过`http://localhost/`进行访问。如果一个URI请求以/images/开头，那么这个server指令就会发送/data/images目录下的文件，比如回应`http://localhost/images/example.png`，nginx服务器会发送/data/images/example.png文件。如果这个文件不存在，nginx会提醒404错误。不是以/images开头的URI请求会被映射到/data/www目录中。比如URI地址是`http://localhost/some/examples.html`,服务器会发送`/data/www/some/examples.html`文件。

**需要配置重新生效，需要执行下面的指令**
```
nginx -s reload  
```
在一些条件下服务器可能没有像上述描述的工作，你可以检查access.log或者error.log文件，通常是在/usr/local/nginx/logs/或者/var/log/nginx目录下。

## 建立简单的代理服务器（proxy server）
nginx服务起还有一个经常被使用的用途是当做代理服务器,代理服务器的意思是指一个服务起接收到请求，然后把这个请求传递给受理服务器(proxied servers)处理，然后从受理服务器中得到相应的回应发送给请求对象。如果不清楚的可以查阅简单的书籍很快就能明白这句话什么意思。

下面会配置一个基本的代理服务器，这个服务器的作用是对于图片请求会直接在本地进行处理，其它的请求都会发送个给受理服务器进行处理。在这个例子中，两个server都定义在一个nginx实例中。

首先，定义一个受理服务器，在nginx配置文件中加入一个server块指令

```
server {  
    listen 8080;  
    root /data/up1;  
  
    location / {  
    }  
}  
```

这个简单的服务器指令配置监听8080端口(之前的服务器端口没有指定是因为已经默认配置了标准的80端口)，对于所有的请求都会用本地的/data/up1目录。
创建这个文件，然后放置一个index.html文件到其中。注意root指令放置在server指令中，在location中没有包含自己的root指令的时候这个server的root指令就会被location指令使用。

下一步使用之前已经学习的服务器配置，修改它让它成为一个代理服务器。在location块指令中，放置一个proxy_pass指令，名字　受理服务器指定的端口号，这里使用（http://localhost:8080）:
```
server {  
    location / {  
        proxy_pass http://localhost:8080;  
    }  
    locaiton /images/ {  
        root /data;  
    }  
}  
```

接着我们修改上面第二个的location块指令，它会把所有/images/前缀的请求映射到服务器的/data/images/目录下，为了是它能够只响应指定文件的请求，需要更改location块指令：

```
location ~ \.(gif|jpg|png)$ {  
    root /data/images;  
}  
```
这个参数是一个正则表达式，对应所有的以.gif .jpg .png结尾的URI请求。一个正则表达式应该以~开头。对应的请求会被映射到/data/images目录下。
nginx服务器在处理用户请求的时候，首先会检查有特殊前缀的location指令，记住最长的location指令的前缀，然后再检查正则表达式。如果这里有一个合乎要求的的正则表达式，nginx会选择这个location指令，如果没有则会选择之前的。

下面是一个代理服务器的配置

```
server {  
    location / {  
        proxy_pass http://localhost:8080/;  
    }  
    location ~ \.(gif|jpg|png)$ {  
        root /data/images;  
    }  
}  
```
这个服务器会过滤出所有以.gif .jpg .png结尾的请求，然后把它们映射到/data/images目录下(URI地址加上root指令的参数)，会把其它的所有的请求发送到上述配置的受理服务器中。
为了使新的配置生效，需要发送reload信号给nginx服务器。

### 设置快速FastCGI代理
nginx可以把请求路由到FastCGI服务器中，FastCGI服务器里可以有各种架构以及使用各种编程语言比如php。

最简单的FastCGI配置是讲proxy_pass指令改成fastcgi_pass指令，fastcgi_param指令将请求传递给FastCGI服务器。假设一个FastCGI服务起可以通过localhost:9000端口访问，以之前配置代理服务器为基础，可以将配置文件写成下面这个样子。
```
server {  
    location / {  
        fastcgi_pass  localhost:9000;  
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;  
        fastcgi_param QUERY_STRING    $query_string;  
    }  
  
    location ~ \.(gif|jpg|png)$ {  
        root /data/images;  
    }  
}  
```
这个会将所有的的除了静态图片的请求路由到FastCGI服务器中。


**参考资料**
[]()

![](http://oankigr4l.bkt.clouddn.com/wexin.png)