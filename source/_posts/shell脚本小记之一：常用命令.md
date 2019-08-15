---
title: shell脚本小记之一：常用命令
tags:
  - shell
categories: shell
top: false
copyright: true
date: 2019-04-24 14:38:42
---
shell中的常见命令
<!--more-->
```shell
sed -i "" "s/http:\/\/oankigr4l\.bkt\.clouddn\.com/http:\/\/static\.zhyjor\.com/g" `grep "http://oankigr4l.bkt.clouddn.com" -rl _posts`
```
**参考资料**
[Shell 编程范例](https://tinylab.gitbooks.io/shellbook/content/)
[程序执行的一刹那](https://tinylab.gitbooks.io/cbook/content/zh/chapters/02-chapter3.html)
[Shell脚本调试技术](https://www.ibm.com/developerworks/cn/linux/l-cn-shell-debug/index.html)
[BASH 的调试手段](http://tinylab.org/bash-debugging-tools/)
[bash: "expr index string1 string2" gives "syntax error"](https://discussions.apple.com/thread/923299)


![](http://static.zhyjor.com/wexin.png)