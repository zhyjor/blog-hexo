---
title: 做懂安全的前端之二：跨站脚本攻击（XSS）
tags:
  - 做懂安全的前端
  - 安全
categories: 安全
top: false
copyright: true
date: 2018-05-26 12:37:36
---
跨站脚本攻击: Cross Site Scripting
<!--more-->
## 能做什么
* 获取页面数据
* 获取cookies
* 劫持前端逻辑
* 发送请求
* 偷取网站的任意数据
* 偷取用户资料
* 偷取用户密码和登陆态
* 欺骗用户

## 案例
* 站酷（在下一个显示了搜索的关键词，而且这里的搜索词还显示到了地址栏，这样构造后了url发给别人就可以了，可以盗取身份了）
![](http://static.zhyjor.com/201805271024_291.png)
* QQ空间，日志，富文本
![](http://static.zhyjor.com/201805271035_835.png)
* 商城提交信息，是否可以提交脚本呢，可以到后台工作人员的后台。因为存在**http Referer这个http头**，拿到后台的地址

## 分类
可以简单分为两类，一般来说，反射型一般需要用户手动点击一个有代码的url，这样一般的用户还是可以分辨出来的，但是假如是存储型的就很难发现了，危害更大
![](http://static.zhyjor.com/201805271043_989.png)
### 反射型


**参考资料**
[前端安全系列（一）：如何防止XSS攻击？](https://juejin.im/post/5bad9140e51d450e935c6d64)

![](http://static.zhyjor.com/wexin.png)
