---
title: http使用探索之一：记一次不成功的RESTful接口开发的反思
tags:
  - http使用探索
  - RESTful
categories: http
top: false
copyright: true
date: 2018-02-26 18:02:15
---
这是一篇关于rest的反思。
<!--more-->
### 前言
在之前的项目设计中，本着无知无畏的态度，设计出一套api接口；接口已经在用了，但是不合理的细节难以灵活应对产品层出不穷的新需求，冗余呆板的数据结构也给后端小伙伴带来了一波又一波的惊喜。痛定思痛，反思必不可少。接下来就认真思考一下三个问题：何为restful风格，我们在设计接口的时候是否需要严格遵守，有什么好处。

为了从根本上了解REST，我们就从其提出者Roy Fielding博士的博士论文说起。本文主要分为三个部分：
* 其一，通过Fielding博士论文了解REST；
* 其二，剖析之前那套api的不合理的点，如何优化；
* 其三，关键点总结。

我一直认为协议在某种程度上就是互相妥协的产物，通过互相妥协来寻找最优的方案。让我们先了解一下何为restful风格。
### REST的出现

**参考资料**
[Rest架构成熟度](https://blog.csdn.net/tpriwwq/article/details/46617993)
[我所认为的RESTful API最佳实践](https://www.scienjus.com/my-restful-api-best-practices/)
[HTTP后台端：RESTful API接口设计](https://crifan.github.io/http_restful_api/website/)
[如何设计api分页](https://zhuanlan.zhihu.com/p/25301375)
[精读《REST, GraphQL, Webhooks, & gRPC 如何选型》](https://juejin.im/post/5b95bc3df265da0af0336911)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)