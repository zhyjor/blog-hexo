---
title: webpack实践之一：简单使用
tags:
  - webpack实践
  - webpack
categories: webpack
top: false
copyright: true
date: 2018-07-09 08:59:36
---
标题为webpack配置中的一句话重点，其实就是有些不太引人注意，但是很重要，或者能很好的提高用户体验的细节。
<!--more-->

## vue-style-loader
对于vue文件中的css，因为对于vue文件中的style，默认是按照普通文本处理的。而且这里修改样式不是同步更新到页面上，也就是说没有热更新。添加这个loader后，**就可以实现热更新了**

## rimraf
这里可以用来删除一个文件，文件夹，这个通常用在重新打包之前，删除旧的打包文件的操作。
```
// 删除dist文件夹
rimraf dist
```

**参考资料**
[Webpack4+ 多入口程序构建](https://juejin.im/post/5af3a6cbf265da0ba266ff25)
[Webpack 打包优化之速度篇](https://jeffjade.com/2017/08/12/125-webpack-package-optimization-for-speed/)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)