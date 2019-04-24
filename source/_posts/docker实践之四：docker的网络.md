---
title: docker实践之四：docker的网络
tags:
  - docker
  - docker实践
categories: docker
top: false
copyright: true
date: 2018-11-02 16:36:01
---
分单机网络和多机网络
<!--more-->
## 网络基础
基于数据包的网络协议，以及7层网络协议，ip和路由，公有ip和私有ip，网络地址转换NAT,ping（检查连接的可达性）和telnet(检查服务的可用性，一般是防火墙的问题，可达但是服务不一定可用)

### 网络命名空间
实现两个network namespace可以相互ping通
```
ip netns list
// 删除
ip netns delete $(name)
// 添加
ip netns add $(name)
```

## veth
Linux container 中用到一个叫做veth的东西，这是一种新的设备，专门为 container 所建。veth 从名字上来看是 Virtual ETHernet 的缩写，它的作用很简单，就是要把从一个 network namespace 发出的数据包转发到另一个 namespace。veth 设备是成对的，一个是 container 之中，另一个在 container 之外，即在真实机器上能看到的。 
```
sudo docker run -d --name test1 busybox /bin/sh -c "while true;do sleep 3600;done"
sudo docker run -d --name test1 --link test2 busybox /bin/sh -c "while true;do sleep 3600;done"
link具有方向性，用的并不多，有其他更好的方法
--network可以设置连接的网络

sudo docker network inspect bridge
```

```
brctl show
```

**两个容器之间如何通信，容器如何访问外网**
veth，nat处理
```
docker network create
```

## 端口映射
**若对外提供一个web服务**，将端口映射到本地
```
将docker端口，映射到本机的端口
docker run --name web -d -p 80:80 nginx
```

## none与host的network
none:除了本地无法访问
host:共享主机的网络地址空间

## 多容器复杂应用的部署

### 单台linux

分模块的放在不同的容器内，确定不同容器的访问关系
```
// -e设置环境变量，用env可以查看
docker run -d --link redis --name flask-redis -e REDIS_HOST=redis zhyjor/flask-redis

docker run -d -p 5000:5000 --link redis --name flask-redis -e REDIS_HOST=redis zhyjor/flask-redis

```
## 多机网络
### 两台linux的话怎么用呢（跨机器overlay网络）
vxlan
etcd，分布式存储


**参考资料**
[Etcd 使用入门](https://www.hi-linux.com/posts/40915.html)
[Docker Tutorials and Labs](https://github.com/docker/labs)

![](http://static.zhyjor.com/wexin.png)
