---
title: vue进阶之五：vue-router的使用
tags:
  - vue进阶
  - vue
categories: vue
top: false
copyright: true
date: 2018-07-26 14:39:07
---
使用总结
<!--more-->

默认使用的是hash路由

有服务的渲染的一般不会使用hash的情况。

## new Router配置项
new router，加上base配置项：/base/，可以在路径上加上这一部分。

### linkActiveClass,linkExactActiveClass
配置一些路由的的dom的样式。

### scrollBehavior
切换的时候，时候滚动。一般接收三个参数（to, from, savePosition），直接返回0,或者savePosition就可以。

### parseQuery
接收一个（query）接收字符串

### stringQuery
接收一个（obj），可以自己处理

### fallback
不是所有的都支持history的那种形式。加上后就变成了hash形式。

## devServer
需要做路径映射的设置，尤其是在history模式的时候

historyApiFallback:{index:index.html}

## 路由的命名和参数传递

### name
直接使用router-link里面的to-》name直接跳转

### meta
里面可以添加自定义的信息，有些信息不是想拿就拿的，放在meta里的才可以使用。

### children
子路由，一般在他的组件底下需要添加一个router-view，匹配到路由的时候再加上。

## 路由的动画
transition

## 传参
尽量组件和路由解耦，复用性会提高
### id传参
path:'/path:id'
变成了params

### query
不用在定义的时候就假如

### props:true（推荐这种用法）

这个时候：id的值会作为props传给组件


## 命名路由
在不同的路由下需要显示不同的东西，在不同的路由下给不同的组件
`<router-view name="a">`

在路由配置表里对component设置不同的配置对象default

## 导航守卫(导航钩子)

### 全局钩子

#### beforeEach

#### beforeResolve
在beforeEnter和beforeRouterEnter之后触发

#### afterEach

### 路由配置表钩子
#### beforeEnter
调用顺序在beforeEach和beforeResolve之间

### 组件内钩子
#### beforeRouterEnter
可以获取页面要用到的数据，这里拿不到组件的上下文this，这里next之前根本没有初始化这个组件。可以在next里面将获取到的数据塞到实例里面。**这里会有一个回调函数，拿到vm对象。**，页面进入的时候数据就已经获取到了。

#### beforeRouterUpdate
传参路由的情况下切换，会调用。同样的路由形式切换的时候才会触发。切换的时候可以在这里做数据的请求，**不然就要添加一个watch，这样就不太好了**，还可以再这里弹出一个错误提醒。

**这里假如在mounted,这个时候，这个生命周期不会执行，会有坑。**

#### beforeRouterLeave
修改表单数据的时候离开了，这个时候问用户是否离开，给用户提供安全性。

## 异步组件
component，接收一个函数，直接通过import(xxx.vue)这种形式就可以。使用这种语法需要一个特殊的webpack插件`babel-plugin-syntax-dynamic-import`,需要在.babelrc中添加这个插件。



**参考资料**
[]()

![](http://oankigr4l.bkt.clouddn.com/wexin.png)