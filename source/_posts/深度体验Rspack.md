---
title: 深度体验Rspack
tags:
  - Rspack
  - Rust
categories: 前端
top: false
copyright: true
date: 2023-03-15 10:57:17
---
楼下的白玉兰花开了，树梢已经悄悄爬到了6楼高了，一树的玉兰花开的特别热烈。在家里的阳台上就能看到，仔细闻还能花香。春风不燥，阳光正好，春天也终于到了

前端构建圈这段时间异常热闹，基于Rust的构建工具极度内卷，本着「能被rust重写的都将被rust重写」的真理，Turbopack刚发布不久，3月10号，ByteDance发布了基于Rust的Rspack，字面理解Rust + Webpack。相比于Turbopack发布时大家都在关注它能比vite快多少的，[甚至惹的尤大都下场了](https://github.com/yyx990803/vite-vs-next-turbo-hmr/discussions/8)，Rspack的发布得到了更多社区上支持，比如 Monorepo 框架 Nx 已经对其提供官方支持([Rspack — Getting up to speed with Nx](https://blog.nrwl.io/rspack-getting-up-to-speed-with-nx-4c34540bccf2))；“Rspack 已经兼容webpack生态的主要配置，并且在内部业务落地的生成环境”

本文主要分享一下试用 Rspack 的体验，闲言少叙，进入正题
<!--more-->
## 介绍

先看一下[官方文档](https://www.rspack.dev/zh/guide/introduction.html)：
> Rspack（读音为 /'ɑrespæk/,）是一个基于 Rust 的高性能构建引擎， 具备与 Webpack 生态系统的互操作性，可以被 Webpack 项目低成本集成，并提供更好的构建性能。
> 到今天（2023 年 3 月）为止 Rspack 已经开发了 11 个月，虽然 Rspack 仍处于比较早期的状态，且缺失了一些 webpack 的功能，但根据二八原则，目前的功能已经能够满足大多数项目的需求。同时，我们已经在内部的多个业务上完成了落地，取得了 5~10 倍编译性能的提升。
> Rspack 已经完成了对 webpack 主要配置的兼容，并且适配了 webpack 的 loader 架构。目前，你已经可以在 Rspack 中无缝使用你熟悉的各种 loader，如 babel-loader、less-loader、sass-loader 等等。我们的长期目标是完整地支持 loader 特性，未来你可以在 Rspack 中使用那些更加复杂的 loader

我们关注几个重点信息：
1. 缺失一些 webpack 的功能，但是已经能够满足大多数项目的需求
2. 已经在内部的多个业务上完成了落地，取得了 5~10 倍编译性能的提升
3. 完成了对 webpack 主要配置的兼容，并且适配了 webpack 的 loader 架构

综上，假如没有较复杂的loader或其他配置的话，基于webpack的项目的项目是可以直接迁移的，接下来使用CRA新建一个应用，然后配置迁移为Rspack，通过这个过程来评估一下迁移复杂度，以及迁移后的性能是否真的能有5～10倍的提高

## webpack 2 rspack
首先放上本次测试的[代码仓库](https://github.com/zhyjor/rspack-measure)，可以直接通过下面的命令运行，查看结果
```bash
# rspack
npm run dev:rs
npm run build:re

# webpack
npm run dev
npm run build
```
先说结论，虽然CRA创建的项目相对比较简单，但也基本覆盖了基本的配置了，所以配置的修改也具有一定的参考意义。

1. 配置较简单，内置了对ts,js,css,file的默认支持，配置文件夹较简单
2. 热更新，项目较小速度差距不明显，文档不够完善，完全找不到devServer是怎么配置的，而且热更新的日志明显还是 `webpack-dev-server`的 ![](https://static.zhyjor.com/blog/25A01D17-A276-4390-92CC-99D9941D3542.png)
3. 构建速度如下图，分别是2100ms和115ms，可见速度提升还是很明显的![](https://static.zhyjor.com/blog/EEAF2230-5757-4086-A3DE-9FF918C55E6D.png), ![](https://static.zhyjor.com/blog/973DA473-6AC9-47F3-B7E9-27614D38D807.png)
4. 构建物文件大小，相差不大

官方也提供了[测试Benchmark](https://www.rspack.dev/zh/misc/benchmark.html)，有兴趣的可以自己试试

## 可以使用了吗
Rspack 已经完成了对 webpack 主要配置的兼容，并且适配了 webpack 的 loader 架构, 几乎可以无缝切换到 webpack 中经常使用的各种loader。而且按照官方的说法会长期完整支持webpack的loader特性，那可以遇见的一段时间内，是可以用起来的，速度比webpack快多了。

去年 Vercel 发布的 Turbopack 也是基于 Rust 并且主打高性能的，但是 Turbopack 并未对 webpack 的生态进行兼容，这样就很难利用上层现有的生态和框架，这也是 rspack 的优势。

另外官方还提到了缓存能力
> 目前 Rspack 对缓存支持还比较简单，仅支持了内存级别的缓存，未来我们会建设更强的缓存能力，包括可迁移的持久化缓存，这将带来更大的想象空间，如在 monorepo 里不同的机器上都可以复用 Rspack 的云端缓存，提升大型项目的缓存命中率
大型项目的缓存能力一直是一个痛点，尤其是在云构建的情况下，缓存带来的时间的节省是非常可观的，可以期待一下。当然假如做到了云端缓存，能做当然也就是不仅仅是云端缓存的事情了，这里也和 vercel turbo （[Remote Caching](https://vercel.com/docs/concepts/monorepos/remote-caching#)） 有了一些重叠的想法，可以看一下 rspack 究竟可以走多远。

## 总结
[Anthony Fu在评价Turbopack](https://www.zhihu.com/question/562349205/answer/2733040669)里说：“我一直认为好的设计对性能的影响远比语言带来的提升更大，语言性能的加成更像一个常量系数，单纯更换语言只能带来有限的提升，在讨论更换语言以获得更好性能的时候，我们是不是应该问一句 - 那代价是什么？”。深以为然，目前 rspack 确实在代价控制这个方面做的更好一些，兼容了 webpack 生态，同时保持和 webpack 团队的工作关系，这样让切换成本低了很多，期待 rspack 能走的更远。

最后，生命不息，折腾不止，假如有想法，就用起来吧


**参考资料**
[]()

![](https://static.zhyjor.com/wexin.png)
