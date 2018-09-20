---
title: 学点linux之三：待定
tags:
  - 学点linux
  - linux
categories: linux
top: false
copyright: true
date: 2018-09-18 10:48:46
---
培训内容
<!--more-->

## 第一天·进程

### pcb
### pid

android2的一个漏洞
adb
管道
fork炸弹
树形（init进程是父进程，可知道子进程是否alive,然后可以重启）
一只一个进程的pid，导出这个进程？？？
kill -9 ???
僵尸态，子进程留下的那个结构体什么时候完全消失
什么是内存泄漏
连续多点采样法，对内容泄漏进行判定


### 作业控制
fork
进程：资源封装单位
线程：进程调度的基本单位
TGID pid
子进程托孤

进程0与进程1，是什么特殊进程
等硬盘与等键盘的不同
负载到底怎么计算idle与wa有什么区别

### 调度算法
解决就绪和执行的两个部分
保存现场与恢复现场
上下文切换的时间2微秒左右，上下文切换对吞吐率会有影响，上下文切换回带来cache的切换，内存的速度更慢

吞吐vs响应
io消耗型与cpu消耗型，为什么io型的优先级更高呢？
优先级（小数值，优先级高）和调度策略（sched-fifo/sched-rr）
奖励io消耗型，惩罚cpu消耗性（优先级越睡越高）
nice值

后来增加了rt熔断机制
完全公平调度cfs，喜欢睡的在树的左边，优先级会高，注意虚拟时间问题

### 多核负载均衡
cgroup：分群调度,进程分群，分级调度器，群和群之间先按照权重，群内部也是按照权重，在cgroup中创建文件夹，就是创建群，按照群分配内存占用，群与群是1:1，但是可以修改群的权重，进而提到群内进程的权重

新版android会有分群，旧版的前台后台一视同仁apps:cpu.shares=1024,bg_interactive.cpu.shares=52
系统会将pid修改到对应的群里，主要是区分一下前后台的应用

docker和cgroup，linux会自动为容器设置一个cgroup,可以为进程控制cpu最大消耗

在现代云计算中用处很大

调度器只认识task_struct pcb，进程控制
make -j16

### 可预期性
hard realtime
linux是软实时操作系统,为什么不是硬实时操作系统呢
中断（中断内不能中断），软中断（中断和进程的一个中间状态，软中断可以中断），***lock...不能抢占，抢占不等时钟节拍

cyclictest

如何用来做硬实时呢，可以打一个rt补丁，100us
https://git.kernel.org/

假如需要更高的实时性的话


## 第二天·内存

### 分页机制
缓冲区溢出攻击，注意rw权限保护
用户态不能访问内存态，inter，amd的漏洞，meltdown，从用户空间偷取了内核空间数据，**熔断漏洞**

### 内存分zone
DMA:可以直接在内存和外设间进行数据搬移，和cpu访问内存的顺序由总线仲裁器

dma为了弥补某些硬件的缺陷，但是现在各种缺陷已经少了，dma已经少了

内存的带宽会限制性能

buddy（唯一知道物理地址的，不知道就没法改了，使用物理地址就是填页表）
硬件中的虚实转换
直面物理地址内存条？？？在buddy眼中，内存就是物理地址，但是cpu访问的是还是按照虚拟地址，面对一页一页的物理地址

### buddy分配算法

linux buddy分配算法：把一页空闲的，两页空闲...分别放到不同的链表中

/proc/buddyinfo文件

buddy最小4k,这个会有两个问题：不停的拆分，碎片多；另外4k太大，有些可能不需要那么多
**内存碎片化：**dma引擎要求物理连续内存。cpu中有mmu不用连续，但是dma不行，高端的电脑，dma也会带有mmu
**带了mmu就可以做虚实转换**
碎片化通过预留法解决，可以提前给设置好，预留给各种需要的点
cma法解决，连续内存分配器，三星的大佬，平时给应用（app,movable页面用）使用，但是使用的时候腾出非连续的地址，然后搬出去，留出预留的给原来的目的使用，但是性能不太好
**粒度太大**：Libc(用户层malloc,free),Slab（内核调用，kmalloc,kfree，让slab去找buddy,使用的时候切出object,slab中是等分的，不同尺寸的需要专门拿出一个新的slab）,buddy
/proc/slabinfo

c库是二级管理器

应用程序级的free和buddy的free()不同

linux申请内存成功之后，需要对申请过的重新写一遍，写那一页拿那一页

oom打分因子，杀进程，清内存，分数主要由内存耗费的大小决定
android前后台的打分不同，桌面控制程序会控制这些

### page fault

vma虚拟地址空间
heap中page fault 申请一次内存，就行了mini pagefault
代码区内page falut major pagefault，需要读取磁盘

\time -v

### 内存如何被进程瓜分
vss:虚拟内存消耗
rss:真实内存消耗（这里可能会有重复的内容）
pss:比例化内存消耗（看实际的内存条的使用率）
uss:独占且驻留的（内存泄漏问题，因为只有堆内存才可能出现内存泄漏，代码区不可能，连续多点采样，采集多个点的uss，valgind和gcc addresssanitizer新版gcc才支持）
vss >= rss >= pss


### page cache
读取硬盘的两个方法
内核空间申请部分内存用着page cache，用到的一部分内存会用为page cache
**man方式读取帮助**
mmap，代码段的读取，其本质就是pagecache
**LRU，cache替换算法**
page cache能装多少装多少，这样提高硬盘的访问速率，有多少内存耗多少内存
裸数据，元数据
free命令
匿名页必须常驻内存，虚拟内存可以放这些
虚拟地址，虚拟内存
zRAM,虚拟内存有增大内存的效果
内存大硬盘命中率高

dma cache一致性问题

内存的分群cgroup
cgexec -g memory ... // 修改内存分组，可以做内存的QoS控制，不同的进程可以给不同的内存资源，给不同的群设置不同的内存

内存不够的时候就交换，匿名页
局部性原理

### 脏页写回与内存回收
脏页，dirty，脏页写回与内存回收（回收的内存）的不同，空间维度与时间维度
时间维度：突然关机可能会丢失30的数据
空间维度：dirty
系统需要保证脏页的大小保证在dirty_ratio之下

回收的时候按照是否有硬盘副本进行不同的页处理，回到内存的安全线

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

**《微机原理》，《操作系统》**
[CPU是如何访问到内存的？--MMU最基本原理](https://mp.weixin.qq.com/s/SdsT6Is0VG84WlzcAkNCJA)
[我是一个cpu,这个世界慢死了]()


[实时操作系统与非实时操作系统的区别](https://blog.csdn.net/bjbz_cxy/article/details/79163162)

[深入理解Linux内存管理-之-目录导航](https://blog.csdn.net/gatieme/article/details/52384965)
[《深入理解LINUX内存管理》学习笔记 ](http://www.uml.org.cn/embeded/201208071.asp)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)