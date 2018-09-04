---
title: JavaScript常见问题之五：防抖与节流
tags:
  - JavaScript常见问题
  - js
categories: js
top: false
copyright: true
date: 2018-04-10 09:12:52
---
函数防抖和函数节流都是防止某一时间频繁触发，但是这两兄弟之间的原理却不一样。函数防抖是某一段时间内只执行一次，而函数节流是间隔时间执行。

<!--more-->

debounce防抖,在事件被触发n秒后再执行回调，如果在这n秒内又被触发，则重新计时。throttle节流,规定在一个单位时间内，只能触发一次函数。如果这个单位时间内触发多次函数，只有一次生效。

**参考资料**
[7分钟理解JS的节流、防抖及使用场景](https://juejin.im/post/5b8de829f265da43623c4261)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)