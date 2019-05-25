---
title: vue进阶之七：通用组件开发
tags:
  - vue进阶
  - vue
categories: vue
top: false
copyright: true
date: 2018-07-29 13:53:58
---
全局调用的message的开发
<!--more-->

## notification
全局通用的时候，类似vue的方法，我们可以用个api那种形式来调用的形式。通过两个方法，Vue.extend(),

instance.$mount()可以直接生成一个dom，然后我们的$mount()没有传节点的参数，就是生成了dom但是没有挂载，可以自己挂载到对应的dom节点。以及propsData属性的传递。

**什么时候删除呢**，可以在动画之后，添加一个动画结束的事件：after-leave

隐藏后，需要destroy掉组件对象，删除掉dom,

隐藏后，需要调整一下dom的高度，不然看起来很难受，有很大的空格。这可以通过after-enter触发，来修改。

无法watch一个插槽，插槽的不是响应

## 跨域处理
可以在devServer中设置一些跨域头

koa-session

pm2

**参考资料**
[]()

![](http://static.zhyjor.com/wexin.png)
