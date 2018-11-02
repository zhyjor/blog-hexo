---
title: docker实践之三：操作容器
tags:
  - docker
  - docker实践
categories: docker
top: false
copyright: true
date: 2018-10-23 17:02:21
---
容器是 Docker 又一核心概念。简单的说，容器是独立运行的一个或一组应用，以及它们的运行态环境。对应的，虚拟机可以理解为模拟运行的一整套操作系统（提供了运行态环境和其他系统环境）和跑在上面的应用。本文介绍如何来管理一个容器，包括创建、启动和停止等。
<!--more-->
## 什么是container
通过image创建的
在image layer之上建立一个container layer
**其实container就是在image上多了一个可写的层**
类比面向对象的类和对象
image负责app的存储和分发，container负责运行app
```docker
docker images
docker image ls -a
docker image ls -aq
docker rmi $(docker image ls -aq)
docker rm $(docker container ls -f "status=exited" -q)
```

## 命令
```
docker container commit 
简写成：docker commit
```
```
docker image build
简写成：docker build
```
```docker
后台运行
docker run -d 
```

```
docker ps
docker exec // 对运行中的容器执行一个命令
docker exec -it ${id} /bin/bash
```

## stress测试容器的压力
容器资源的限制，设置相对权重


**参考资料**
[]()

![](http://oankigr4l.bkt.clouddn.com/wexin.png)