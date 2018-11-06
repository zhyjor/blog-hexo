---
title: docker实践之六：容器编排
tags:
  - docker
  - docker实践
categories: docker
top: false
copyright: true
date: 2018-11-03 16:49:34
---
容器那么多怎么管理，怎么自动恢复容器呢，怎么监控容器的健康状态，如何去调度，如何保护隐私数据；这些可以使用容器编排工具swarm。当然还有其他工具，swarm内置于docker中了。
<!--more-->
## DNS服务发现
```
// 查询dns
nslookup
```

```
// 扩展服务
docker service scale whoami=3
// 查看服务
docker service ps
```



### Routing Mesh的两种实现
* Internal，容器之间通过overlay网络，通过vip虚拟ip
* Ingress,如果服务有绑定接口，则此服务可以通过任意swarm节点的相应接口访问。

### Internal Load Balancing
负载均衡
```
DNS+VIP+iptables+LVS
```

### Ingress Network
外部访问负载均衡
服务器端口被暴露到各个swarm节点
内部通过ipvs进行负载均衡

ipvsadm lvs的管理工具

注意ingress network的数据包走向

## etcd
就是一个key-value的store，存储各种配置

## lvs
负载均衡都是通过lvs来做的

## docker stack
```
deploy
ls
ps
rm
services
```

## docker secret
密码管理
**用户名密码**
**ssh key**
**TLS认证**
**任何不想让别人看到的数据**

* 存在swarm manager节点的raft database里
* secret 可以assign给一个service，这个service就能看到这个secret
* 在container内部secret看起来像文件，但是实际是在内存中

```
docker secret create/ls/inspect/rm
```

## service更新
在不宕机的情况下更新服务
```
docker service update --image image/name
```

## docker cloud
提供容器的管理，编排，部署的托管服务

## docker ee
docker企业版的UCP和DTR(docker trusted registry)的使用
资源编排 ROS

## kubernetes/k8s
在docker的助攻之下，2018年是kubernetes的元年。

docker kubelet kube-proxy Fluented(日志)

### Minikube
[Minikube](https://github.com/kubernetes/Minikube)
minikube & kubectl

#### pod
是k8s的最小调度单位，共享一个namespace，如何对pod新建管理，如何对pod进行横向扩展

#### **ReplicaSet**

#### Deployments
如何创建管理deployments，描述pod，保证pod的执行


### kubeadm
[kubeadm](https://github.com/kubernetes/kubeadm)

### kops
[kops](https://github.com/kubernetes/kops)
生产级别的一个工具，可以在一个云上

### tectonic
[tectonic](https://coreos.com/tectonic/)

### play with kubernetes

### k8s的网络（service）
多机通信，依旧通过overlay,[网络模型是通过插件实现的Cluster Networking](https://kubernetes.io/docs/concepts/cluster-administration/networking/)，各个厂商都可以自己提交实现

* all containers can communicate with all other containers without NAT
* all nodes can communicate with all containers (and vice-versa) without NAT
* the IP that a container sees itself as is the same IP that others see it as

### Service

* kubectl expoese命令，会给pod创建一个service供外部访问
* service主要有三种类型，clusterIp、nodePort、外部的LoadBalancer
* 另外可以使用dns，但是需要添加DNS的add-on

如何在外部直接访问pod呢

**不要直接使用或者管理pods**
* 当我们使用replicaSet或者ReplicationController做水平扩展scale的时候，Pods可能会被terminated
* 当我们使用Deployment的时候，我们去更新Docker Image Version，旧的Pods会被terminated,然后新的Pods创建

**Perform rolling update using a Replication Controller**

**参考资料**
[Linux服务器集群系统（一）章文嵩（LVS系统）](http://www.linuxvirtualserver.org/zh/lvs1.html)
[【大型网站技术实践】初级篇：借助LVS+Keepalived实现负载均衡](http://www.cnblogs.com/edisonchou/p/4281978.html)
[神奇的 routing mesh - 每天5分钟玩转 Docker 容器技术（100）](https://www.ibm.com/developerworks/community/blogs/132cfa78-44b0-4376-85d0-d3096cd30d3f/entry/%E7%A5%9E%E5%A5%87%E7%9A%84_routing_mesh_%E6%AF%8F%E5%A4%A95%E5%88%86%E9%92%9F%E7%8E%A9%E8%BD%AC_Docker_%E5%AE%B9%E5%99%A8%E6%8A%80%E6%9C%AF_100?lang=en)

[Docker Compose](https://docs.docker.com/compose/compose-file/#placement)
[Docker Swarm 集群图形化显示工具 Visualizer](https://blog.csdn.net/CSDN_duomaomao/article/details/52998444)

**[在Docker的助攻下，2018年将是Kubernetes之年](https://www.imooc.com/article/23476)**

[安装配置Rancher管理docker](https://blog.csdn.net/tianyaleixiaowu/article/details/75116394)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)