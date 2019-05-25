---
title: 学点linux之五：IO与网络模型
tags:
  - 学点linux
  - linux
categories: linux
top: false
copyright: true
date: 2018-09-20 09:43:23
---
虚拟化技术，io和cpu可以并行，充分利用系统资源
<!--more-->


## 第三天·I/O与网络模型
吞吐vs响应
阻塞，非阻塞
select/epoll多路复用
SIGIO
虚拟化技术，io和cpu可以并行，充分利用系统资源
aio:数据公司屏蔽pagecache,用aio+dio,直接和硬盘操作
事件驱动，反应堆模型，callback
C10K问题
Inode标志文件，文件名不重要
inode bitmap，inodes,data区
目录是一个特殊的文件
所有的硬链接全部被删除，inode才会被删除，inode体系
符号链接，只在意路径
debug fs看文件的详细的信息

### 掉电与文件系统一致性
加入修改未完成的时候掉电了，怎么办？只能保证一致，不解决数据不丢，借助ups电源
镜像文件可以当成磁盘使用
fsck，unclean shutdown,原理依旧是一致性原理，不一致的话文件系统不能正常工作（旧技术），扫描修复很慢的
现在使用日志方式，更快，包括win和linux都是

日志区，先写日志，然后改硬盘对应的位置，分begin,commit（日志写完了，就变成commit,日志回放一遍，假如未commit就将日志丢弃）,checkpinited,之后删除日志

为什么不做数据日志

matadata日志的五个阶段，完整的日志data=journal,writeback,ordered

### 块I/O流程与I/O调度器
一个io的一生，最终数据怎么到硬盘的
radix tree,文件偏移位置在内存中的位置
request的三个队列：plug（本地泄洪，先蓄势，排序合并，连续的块读起来更快）队列，投入到io调度电梯（再次进行合并，进行QoS配置，设置优先级），块设备驱动（dispatch队列），进入request_fn()



**参考资料**
[]()

![](http://static.zhyjor.com/wexin.png)
