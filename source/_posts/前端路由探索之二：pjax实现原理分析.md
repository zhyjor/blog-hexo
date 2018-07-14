---
title: 前端路由探索之二：pjax实现原理分析
tags:
  - 前端路由探索
  - 路由
categories: 前端
top: false
copyright: true
date: 2018-07-02 15:23:52
---
现在很多网站( facebook,  twitter)都支持这样的一种浏览方式， 当你点击一个站内的链接的时候， 不是做页面跳转， 而是只是站内页面刷新。 这样的用户体验， 比起整个页面都闪一下来说， 好很多。 其中有一个很重要的组成部分， 这些网站的ajax刷新是支持浏览器历史的， 刷新页面的同时， 浏览器地址栏位上面的地址也是会更改， 用浏览器的回退功能也能够回退到上一个页面。 那么如果我们想要实现这样的功能， 我们如何做呢？ 我发现pjax提供了一个脚本支持这样的功能。 pjax项目地址在  https://github.com/defunkt/jquery-pjax 。 实际的效果见：  http://pjax.heroku.com/ 没有勾选pjax的时候， 点击链接是跳转的。 勾选了之后， 链接都是变成了ajax刷新。
<!--more-->

**参考资料**
[Pjax是什么以及为什么推荐大家用](https://blog.csdn.net/u010620152/article/details/62422076)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)