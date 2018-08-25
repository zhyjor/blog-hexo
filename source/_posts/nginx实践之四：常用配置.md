---
title: nginx实践之四：常用配置
tags:
  - nginx实践
  - linux
categories: nginx
top: false
copyright: true
date: 2018-07-25 11:23:27
---
Nginx常用配置，包括多站点配置，反向代理，负载均衡，动静分离等等。
<!--more-->

## ubuntu的目录结构和说明
其他系统目录结构可能不一样,但是配置文件都是一样通用的,这里简单说一下ubuntu的目录结构。如果是使用apt-get安装的nginx,配置文件目录在:
```
/etc/nginx/
```
打开这个目录，可以看到这个目录下的文件：
```
nginx.conf  
这个是nginx的主配置文件,里面包含了当前目录的所有配置文件,
只不过有的是注释状态,需要的时候自行开启(后面几个常用的)

conf.d
这是一个目录,里面可以写我们自己自定义的配置文件,文件结尾一
定是.conf才可以生效(当然也可以通过修改nginx.conf来取消这个限制)

sites-enabled
这里面的配置文件其实就是sites-available里面的配置文件的软
连接,但是由于nginx.conf默认包含的是这个文件夹,所以我们在
sites-available里面建立了新的站点之后,还要建立个软连接到sites-enabled里面才行

sites-available
这里是我们的虚拟主机的目录，我们在在这里面可以创建多个虚拟主机

```

## 多站点配置
为什么要配置多站点:

当我们有了一个服务器之后,为了不浪费服务器的资源,我们可以在一个服务器上放置多个网站项目,它们共同使用80端口,通过不同的servername来区分不同的网站项目,在实际上线的项目中,这个servername就是我们的域名。
```
默认已经有一个站点了,就是defalt,在sites-available里面有
一个default文件,就是默认站点的配置,servername是localhost
不建议直接修改这个默认站点,我们可以复制一个:

cd /etc/nginx/sites-available/
cp default web1.com

别忘了建立个软连接,不然新站点不会生效滴:
ln -s /etc/ngix/sites-available/web1.com /etc/nginx/sites-enabled/web1.com

现在就开始修改我们的新站点配置:
vim web1.com

找到21行的这句配置(:set nu可以显示行号):
listen 80 default_server;

改成:
listen 80; //注意:default_server是设置默认站点的,我们新建立的站点不需要

找到24行:
root /usr/share/nginx/html

改成:
root /your server path  (写你自己的网站目录)

重启nginx服务:
/etc/init.d/nginx restart
```


**参考资料**
[]()

![](http://oankigr4l.bkt.clouddn.com/wexin.png)