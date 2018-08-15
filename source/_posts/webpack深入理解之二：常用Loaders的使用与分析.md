---
title: webpack深入理解之二：常用Loaders的使用与分析
tags:
  - webpack深入理解
  - webpack
categories: webpack
top: false
copyright: true
date: 2018-04-18 10:00:50
---
loader是用在某种类型的文件处理上的，用于对模块的源代码进行转换。本文我们了解常用的loader，并且实现一个简单的loader。
<!--more-->

## loader是什么
loader 用于对模块的源代码进行转换。loader 可以使你在 import 或"加载"模块时预处理文件。因此，loader 类似于其他构建工具中“任务(task)”，并提供了处理前端构建步骤的强大方法。loader 可以将文件从不同的语言（如 TypeScript）转换为 JavaScript，或将内联图像转换为 data URL。loader 甚至允许你直接在 JavaScript 模块中 import CSS文件！

### css-loader
```bash
npm i style-loader css-loader --dev
```
在webpack中添加配置到module.rules中：
```
{
    test: /\.css$/,
    use: [
      'style-loader',
      'css-loader'// 这里的执行顺序是从右向左
    ]
  }
```
对于css，可以使用**css module**来进行配置，修改上述的css-loader如下：
```
'css-loader?modules&localIdentName=[name]-[hash:base64:5]'
```

### file-loader
用于处理各种图标、图片文件，这里webapck不能直接读取文件，需要通过file-loader
```

```

**参考资料**
[]()

![](http://oankigr4l.bkt.clouddn.com/wexin.png)