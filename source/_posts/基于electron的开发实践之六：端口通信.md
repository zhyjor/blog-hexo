---
title: 基于electron的开发实践之六：端口通信
tags:
  - electron
  - 基于electron的开发实践
categories: 前端
top: false
copyright: true
date: 2019-07-22 17:31:11
---
在window、mac、linux系统中，他们都有一个共同之处就是以文件夹的形式来组织文件的。并且都有各自的组织方式，以及都有如何查询和显示哪些文件给用户的方法。那么从现在开始我们来学习下如何使用Electron来构建文件浏览器这么一个应用。
<!--more-->

**参考资料**
[tessel/node-usb](https://github.com/tessel/node-usb)
[Electron构建一个文件浏览器应用(一)](https://www.cnblogs.com/tugenhua0707/p/11080473.html)
[MadLittleMods/node-usb-detection](https://github.com/MadLittleMods/node-usb-detection)
[node-hid/node-hid](https://github.com/node-hid/node-hid)
[song940/node-escpos ESC/POS Printer driver for node](https://github.com/song940/node-escpos)

[Mount point of connected device (devicePath)](https://github.com/MadLittleMods/node-usb-detection/issues/19)

[Using MTP on macOS with Node.js](https://blog.gerritniezen.com/using-mtp-on-macos/)

![](http://static.zhyjor.com/wexin.png)