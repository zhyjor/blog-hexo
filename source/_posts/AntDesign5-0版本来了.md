---
title: Ant Design 5.0 正式发布了，你要升级吗
tags:
  - javascript
categories: javascript
top: false
copyright: true
date: 2022-11-18 14:31:46
---
![](https://static.zhyjor.com/blog/4E72CEF8-10AB-408C-8E33-80DE5399B6A3.png)
周五了，这周忙里偷闲去了两天桐庐，淡季加上工作日，人好少。而且作为一个标准的江南小城，山青水秀，慢生活的基调就会让人整个松弛下来，即使就简单的在酒店附近走走，就已经是很舒服了。

好了，闲话少说，今天antd正式发布了5.0版本，笔者是antd重度用户，公司的B端业务组件就是基于antd定制开发的，在5.0发布之前，也在一直在关注beta版本，让我们一起看看5.0在技术上引入了什么新的变化吧

<!--more-->

本文不对设计的变化做评价，仅在技术选型、工程化等技术角度进行分析

## css-in-js
antd动态主题使用了css-in-js方案，抛弃了一直以来的less，放弃了css variables能力，这算是5.0引入的最大变化了，说到css-in-js旧不得不说最近关于css-in-js的一些争议

### css-in-js争议
最近由于Sam的那篇[Why We're Breaking Up with CSS-in-JS](https://dev.to/srmagura/why-were-breaking-up-wiht-css-in-js-4g9b)，直接将css-in-js推到了风口浪尖上，其实这个时候发布了强依赖css-in-js的5.0多少有些尴尬，官方也没有对这个问题进行过多的说明，只是复述了一下使用场景

归根结底，还是Sam这篇文章写的太客观，作为[Emotion](https://emotion.sh/docs/introduction)主要开发者，对css-in-js的有着更深的理解，很客观的说明了方案的优缺点，最后抛出弃用css-in-js最核心的原因：性能问题，这一点是无解的，css-in-js需要在react重渲染组件时序列化className，这就不可避免地带来运行时的性能损失

目前作者使用的方案是css module，除了在css中直接使用js变量需要特定的方式兼容外，其他css-in-js提供的有点，都可以直接兼容，并且没有性能的损失，这应该就是作者弃用css-in-js的核心原因了

### ant design 5.0用css-in-js做了什么
对于动态定制主题而言，关键也是在于如何在性能和维护成本之间做取舍，css-in-js方案可以直接在样式中使用js变量，这对定制主题而言确实可以省掉一些模版代码。and design 5.0使用了[@ant-design/cssinjs](https://github.com/ant-design/cssinjs)作为自己的css-in-js方案，打开文档去看看，官方说法也很明确
> It's a subset of Emotion with design token logic wrapper.
是基于`Emotion`定制了一部分能力的，直接依赖了`@emotion/hash`, `@emotion/unitless`，文档上也直接推荐使用`Emotion`，而`@ant-design/cssinjs`通过牺牲动态性来获取更高的缓存效率，从而减少运行时的性能损耗，`@ant-design/cssinjs`提供的DerivativeToken能力也是这一版本一个亮点，可以简化一些动态主题的配置，会在下一节进行介绍

另外使用了css-in-js后，天然支持TreeShaking，不需要再配置插件了

## Design Token
在ant design v4版本是，笔者经历的使用antd的ToB项目中，很多是需要主题定制的,需要动态主题的地方目前主要还是定义css变量的方式，比如：
```css
color: var(--color);
```
通过将`--color`挂在到`:root`的方式，进行动态主题配置，在v5版本的介绍中，通过Design Token 模型可以派生出几乎所有需要定制的颜色、间距、大小等。且利用上文提到的css-in-js方案，也不再需要和v4一样定义一堆挂在到`:root`上的变量了，确实简化了很多动态主题的配置，这里贴上一张官方的配图
![](https://static.zhyjor.com/blog/4434FCF4-3AF1-4D3E-846C-B7A5E4027DC7.png)

除了整体的可定制，各个组件也可以通过外层的配置来实现样式定制能力,这里就贴一下官方的demo
```js
<ConfigProvider
    theme={{
      components: {
        Radio: {
          colorPrimary: '#00b96b',
        },
      },
    }}
  >
    <Radio>Radio</Radio>
    <Checkbox>Checkbox</Checkbox>
  </ConfigProvider>
```
## 总结
作为antd的深度用户，笔者也会慢慢将自己基于antd的内部组件库慢慢开始升级，目前来看相对痛点的就是自定义主题的升级，因为很难复用旧的逻辑，这点需要先利用v5的能力，保留旧的方案，慢慢替换为design token的方式；另外，还是需要观察一下css-in-js的性能，虽然是B端项目，用户体验上也是不能打折。



**参考资料**
[Ant Design 5.0 正式发布](https://mp.weixin.qq.com/s/qL7UMdHicrk-4b1vYVSIWQ)

![](https://static.zhyjor.com/wexin.png)
