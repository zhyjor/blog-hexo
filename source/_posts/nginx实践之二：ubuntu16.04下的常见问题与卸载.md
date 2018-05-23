---
title: nginx实践之二：ubuntu16.04下的常见问题与卸载
tags:
  - nginx实践
  - linux
categories: nginx
top: false
copyright: true
date: 2018-05-20 11:50:03
---
常见的使用问题，卸载也是大坑
<!--more-->
## 常见问题
### Nginx [emerg]: bind() to 0.0.0.0:80 failed (98: Address already in use)

使用命令关闭占用80端口的程序
 
```
sudo fuser -k 80/tcp
```



## 卸载（大坑）
[Ubuntu安装Nginx和正确卸载Nginx Nginx相关](https://www.cnblogs.com/zhaoyingjie/p/6840616.html)


**参考资料**
[]()

![](http://oankigr4l.bkt.clouddn.com/wexin.png)