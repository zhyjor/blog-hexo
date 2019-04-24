---
title: npm实践之一：package字段含义
tags:
  - npm实践
  - npm
  - 前端工程化
categories: 前端
copyright: true
date: 2018-02-26 15:48:55
---
我们先聊聊这些 scripts 所依赖的文件 package.json，以它为基础的 npm 则是 node.js 社区蓬勃发展的顶梁柱。
<!--more-->

## npm init

npm 是 node.js 社区蓬勃发展的顶梁柱。npm 为我们提供了快速创建 package.json 文件的命令 npm init，执行该命令会问几个基本问题，如包名称、版本号、作者信息、入口文件、仓库地址、许可协议等，多数问题已经提供了默认值，你可以在问题后敲回车接受默认值：
可以通过-f(--force),或者--yes快速生成。
```
npm init -f
```

## npm run
作为 npm 内置的核心功能之一，npm run 实际上是 npm run-script 命令的简写。当我们运行 npm run xxx 时，基本步骤如下：
* 从 package.json 文件中读取 scripts 对象里面的全部配置；
* 以传给 npm run 的第一个参数作为键，在 scripts 对象里面获取对应的值作为接下来要执行的命令，如果没找到直接报错；
* 在系统默认的 shell 中执行上述命令，系统默认 shell 通常是 bash

如果不带任何参数执行 npm run，它会列出可执行的所有命令

**参考资料**
[npm的package.json字段含义中文文档](http://www.yyyweb.com/4548.html)

![](http://static.zhyjor.com/wexin.png)
