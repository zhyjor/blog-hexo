---
title: 学点linux之三：进程
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







**参考资料**

**《微机原理》，《操作系统》**
[CPU是如何访问到内存的？--MMU最基本原理](https://mp.weixin.qq.com/s/SdsT6Is0VG84WlzcAkNCJA)
[我是一个cpu,这个世界慢死了]()


[实时操作系统与非实时操作系统的区别](https://blog.csdn.net/bjbz_cxy/article/details/79163162)

[深入理解Linux内存管理-之-目录导航](https://blog.csdn.net/gatieme/article/details/52384965)
[《深入理解LINUX内存管理》学习笔记 ](http://www.uml.org.cn/embeded/201208071.asp)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)