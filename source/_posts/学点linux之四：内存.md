---
title: 学点linux之四：内存
tags:
  - 学点linux
  - linux
categories: linux
top: false
copyright: true
date: 2018-09-19 09:42:19
---
内存也是一大块
<!--more-->

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


**参考资料**
[]()

![](http://oankigr4l.bkt.clouddn.com/wexin.png)