---
title: 微信开发小记之一：微信内置浏览器IOS和Android的区别
tags:
  - 微信开发小记
  - 微信
categories: 微信
top: false
copyright: true
date: 2018-06-30 10:39:54
---
**在Android上**，微信6.1版本以上的android用户，都是使用的QQ浏览器的X5内核。5.4-6.1之间的版本，若用户安装了QQ浏览器就是使用的X5内核，若用户未安装浏览器，使用的是系统内核。**而在IOS(IPhone)上，**有两种：WKWebview和UIWebview,从IOS8开始支持WKWebview。
<!--more-->

内核的不同造成了不少问题：
## 微信IOS端返回页面不刷新
使用history的replaceState属性替换当前网页链接（其实作用是在不增加history长度的基础上，仍然使用当前网面链接不能使用popState,因为它的作用是增加了history的长度，后退时会出错，往往跳不出循环）。 
完整代码如下：
```
$(function() {
        pushHistory();
    });
    function pushHistory() {
        window.addEventListener("popstate", function(e) {
//          alert("后退");
            self.location.reload();
        }, false);
        var state = {
            title : "",
            url : "#"
        };
        window.history.replaceState(state, "", "#");
    };
```
* popState事件只有在作用go(-1),back(),forward()等操作时才会触发。
* 重点是self.location.reload();,后退后刷新当前页面。其它人写的文章里缺少这一块，弄的我很是郁闷。 
* 微信里在监听到iphone后退事件后会触发popState事件，在PopState事件里执行：self.location.reload();即可刷新后退后的页面。

**参考资料**
[iphone上的微信内置浏览器和Android上的微信内置浏览器的内核不一样吗？？](https://www.zhihu.com/question/26489550)
[如何让微信IOS端，返回页面可刷新](https://zhuanlan.zhihu.com/p/26733114)

**[微信里iphone后退不刷新问题解决方案，真实有效](https://blog.csdn.net/achenyuan/article/details/77769992)**

![](http://oankigr4l.bkt.clouddn.com/wexin.png)