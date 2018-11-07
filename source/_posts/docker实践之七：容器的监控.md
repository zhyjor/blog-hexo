---
title: docker实践之七：容器的监控
tags:
  - docker
  - docker实践
categories: docker
top: false
copyright: true
date: 2018-11-07 08:49:16
---
监控一般是针对运维人员的，但是开发者也需要这些相关知识
<!--more-->

## docker top

## weavescope

```
scope lanch ip
```

## 如何监控一个集群
### 资源监控
计算资源，包含cpu，内存，已经在集群中的容器的计算资源的使用情况
#### heapster
计算资源使用情况的分析和监控

#### grafana
图形化

#### influxDB

## 监控有什么用
how does the horizontal pod autoscaler work(根据资源进行水平扩展)

## k8s集群log的采集与展示
### 回顾
Syslog

### ELK+Fluentd
ElasticSearch+Logstash+Kibana
* Fluentd(log收集，转发，插入到es中)
* ElasticSearch(log index)
* Kibana(log可视化)
* LogTrail(log UI查看)

## Prometheus(普罗米修斯软件)
Prometheus是一款开源的业务监控和时序数据库，可以看作是Google内部监控系统Borgmon的一个（非官方）实现。

**参考资料**
[ Prometheus实战 ](https://songjiayang.gitbooks.io/prometheus/content/introduction/)
[使用Prometheus+grafana打造高逼格监控平台](http://blog.51cto.com/youerning/2050543)
[基于Prometheus的分布式在线服务监控实践](https://zhuanlan.zhihu.com/p/24811652)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)