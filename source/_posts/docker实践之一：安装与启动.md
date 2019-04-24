---
title: docker实践之一：安装与启动
tags:
  - docker
  - docker实践
categories: docker
top: false
copyright: true
date: 2018-10-19 08:57:13
---
Docker 分为 CE 和 EE 两大版本。CE 即社区版（免费，支持周期 7 个月），EE 即企业版，强调安全，付费使用，支持周期 24 个月。

Docker CE 分为 stable, test, 和 nightly 三个更新频道。每六个月发布一个 stable 版本 (18.09, 19.03, 19.09...)。
<!--more-->

## Ubuntu 安装 Docker CE
为了确认所下载软件包的合法性，需要添加软件源的 GPG 密钥。
```
$ curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg | sudo apt-key add -


# 官方源
# $ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```
然后，我们需要向 source.list 中添加 Docker 软件源
```
$ sudo add-apt-repository \
    "deb [arch=amd64] https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu \
    $(lsb_release -cs) \
    stable"


# 官方源
# $ sudo add-apt-repository \
#    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
#    $(lsb_release -cs) \
#    stable"
```
更新 apt 软件包缓存，并安装 docker-ce：
```
$ sudo apt-get update

$ sudo apt-get install docker-ce
```
## 启动 Docker CE
```
$ sudo systemctl enable docker
$ sudo systemctl start docker
```
### 建立 docker 用户组
默认情况下，docker 命令会使用 Unix socket 与 Docker 引擎通讯。而只有 root 用户和 docker 组的用户才可以访问 Docker 引擎的 Unix socket。出于安全考虑，一般 Linux 系统上不会直接使用 root 用户。因此，更好地做法是将需要使用 docker 的用户加入 docker 用户组。

建立 docker 组,将当前用户加入 docker 组：
```
$ sudo groupadd docker
$ sudo usermod -aG docker $USER
```
退出当前终端并重新登录，进行如下测试。

### 测试 Docker 是否安装正确
```
$ docker run hello-world

Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
d1725b59e92d: Pull complete
Digest: sha256:0add3ace90ecb4adbf7777e9aacf18357296e799f81cabc9fde470971e499788
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```
若能正常输出以上信息，则说明安装成功。

**参考资料**
[搭建自己的图片处理服务 — 智能裁剪、旋转、占位一站搞定](https://www.jianshu.com/p/b4db00f73ab5)

![](http://static.zhyjor.com/wexin.png)
