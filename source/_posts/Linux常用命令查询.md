---
title: Linux常用命令查询
tags:
  - linux
categories: linux
copyright: true
date: 2018-01-27 16:28:35
---
在服务器的部署，或者平常的开发中，有些命令需要试试查询，特整理如下
<!--more-->
### 进程相关
#### 查看相关进程
* 查询什么进程占用了80端口`sudo fuser -n tcp 80`
* 杀死某个进程 `sudo kill pid`


**参考资料**
[解决运行nodejs代码Error: listen EADDRINUSE](http://blog.sina.com.cn/s/blog_96f94f710101cqas.html)

![](http://pic47.nipic.com/20140905/9885883_122705249000_2.jpg)