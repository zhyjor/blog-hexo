---
title: 学点linux之一：常用命令
tags:
  - 学点linux
categories: linux
top: false
copyright: true
date: 2018-01-27 16:28:35
---
linux学习中有很多命令记不下来，需要随时进行查询，特整理如下。
<!--more-->
## 文件操作
### 删除
#### 查找名字中包含特殊字符串的文件并删除
[How to search and delete files who contain specific string in name](https://askubuntu.com/questions/625219/how-to-search-and-delete-files-who-contain-specific-string-in-name)
## 进程操作
### 查看相关进程
* 查询什么进程占用了80端口`sudo fuser -n tcp 80`
* 杀死某个进程 `sudo kill pid`

## 查进程
```
ps命令查找与进程相关的PID号：
ps a 显示现行终端机下的所有程序，包括其他用户的程序。
ps -A 显示所有程序。
ps c 列出程序时，显示每个程序真正的指令名称，而不包含路径，参数或常驻服务的标示。
ps -e 此参数的效果和指定"A"参数相同。
ps e 列出程序时，显示每个程序所使用的环境变量。
ps f 用ASCII字符显示树状结构，表达程序间的相互关系。
ps -H 显示树状结构，表示程序间的相互关系。
ps -N 显示所有的程序，除了执行ps指令终端机下的程序之外。
ps s 采用程序信号的格式显示程序状况。
ps S 列出程序时，包括已中断的子程序资料。
ps -t<终端机编号> 指定终端机编号，并列出属于该终端机的程序的状况。
ps u 以用户为主的格式来显示程序状况。
ps x 显示所有程序，不以终端机来区分。
```
最常用的方法是ps aux,然后再通过管道使用grep命令过滤查找特定的进程,然后再对特定的进程进行操作。
```
ps aux | grep program_filter_word,ps -ef |grep tomcat
ps -ef|grep java|grep -v grep 显示出所有的java进程，去处掉当前的grep进程。
```

### 杀进程
使用kill命令结束进程：kill xxx
常用：kill －9 324
Linux下还提供了一个killall命令，可以直接使用进程的名字而不是进程标识号，例如：# killall -9 NAME

## 权限
```bash
chmod +x xx.file
```

**参考资料**
[Linux如何查看进程、杀死进程、启动进程等常用命令](https://blog.csdn.net/wojiaopanpan/article/details/7286430)
[解决运行nodejs代码Error: listen EADDRINUSE](http://blog.sina.com.cn/s/blog_96f94f710101cqas.html)
[Ubuntu 16.04出现：Problem executing scripts APT::Update::Post-Invoke-Success 'if /usr/bin/test -w /var/](https://blog.csdn.net/zzq123686/article/details/77454066)

![](http://static.zhyjor.com/wexin.png)
