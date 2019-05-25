---
title: http使用探索之二：幂等性探究
tags:
  - http使用探索
categories: http
top: false
copyright: true
date: 2018-07-13 09:39:35
---
本文所要探讨的正是HTTP协议涉及到的一种重要性质：幂等性(Idempotence)。幂等性原本是数学上的一个概念，相当于公式`f(x)=f(f(x))`，在编程领域是指对于同一个系统，使用同样的条件，一次请求和重复的多次请求对系统资源的影响是一致。幂等性是分布式系统中的一个概念，具有这一性质的接口在设计要有这样一种考虑：调用接口发生异常并且重复尝试时，总是会造成系统
<!--more-->

**参考资料**
[Programming.log - a place to keep my thoughts on programming](https://www.cnblogs.com/weidagang2046/archive/2011/06/04/2063696.html)
[分布式系统互斥性与幂等性问题的分析与解决](https://tech.meituan.com/distributed_system_mutually_exclusive_idempotence_cerberus_gtis.html)

![](http://static.zhyjor.com/wexin.png)
