---
title: webpack深入理解之一：常用Plugins的使用与分析
tags:
  - webpack
  - webpack深入理解
  - 前端工程化
categories: webpack
top: false
copyright: true
date: 2018-04-18 10:00:32
---
本文简答介绍插件的使用方法，对于重要的plugin从原理的角度分析其实现的方法。
<!--more-->

## 重要Plugins

### `extract-text-webpack-plugin` 插件

#### 使用

Extact text from bundle into a file, 从bundle中提取出特定的text到一个文件中，使用`extract-text-webpack-plugin`就可将css从js中独立抽离出来。简单使用如下：

```js
$ npm install extract-text-webpack-plugin --save-dev

var ExtractTextPlugin = require("extract-text-webpack-plugin");
module.exports = {
    module: {
        loaders: [
            { test: /\.css$/, loader: ExtractTextPlugin.extract("style-loader", "css-loader") }
        ]
    },
    plugins: [
        new ExtractTextPlugin("styles.css")
    ]
}
```
它将从每一个用到了require("*.css")的entry chunks文件中抽离出css到单独的output文件

####  api
```
new ExtractTextPlugin([id: string], filename: string, [options])
```
|Name|Type|Description|
|:--:|:--:|:----------|
|**`id`**|`{String}`|Unique ident for this plugin instance. (For advanced usage only, by default automatically generated)|
|**`filename`**|`{String\|Function}`|Name of the result file. May contain `[name]`, `[id]` and `[contenthash]`|
|**`allChunks`**|`{Boolean}`|Extract from all additional chunks too (by default it extracts only from the initial chunk(s))<br />When using `CommonsChunkPlugin` and there are extracted chunks (from `ExtractTextPlugin.extract`) in the commons chunk, `allChunks` **must** be set to `true`|
|**`disable`**|`{Boolean}`|Disables the plugin|
|**`ignoreOrder`**|`{Boolean}`|Disables order check (useful for CSS Modules!), `false` by default|

* `[name]` name of the chunk
* `[id]` number of the chunk
* `[contenthash]` hash of the content of the extracted file
* `[<hashType>:contenthash:<digestType>:<length>]` optionally you can configure
  * other `hashType`s, e.g. `sha1`, `md5`, `sha256`, `sha512`
  * other `digestType`s, e.g. `hex`, `base26`, `base32`, `base36`, `base49`, `base52`, `base58`, `base62`, `base64`
  * and `length`, the length of the hash in chars

> :warning: `ExtractTextPlugin` generates a file **per entry**, so you must use `[name]`, `[id]` or `[contenthash]` when using multiple entries.


## 其他常用Plugins
### 修改行为
### 优化
### 其他


**参考资料**
[webpack4-用之初体验，一起敲它十一遍](https://juejin.im/post/5adea0106fb9a07a9d6ff6de)
[Webpack 常见静态资源处理 - 模块加载器（Loaders）+ExtractTextPlugin插件](https://www.cnblogs.com/sloong/p/5826818.html)
[webpack官方文档](https://webpack.js.org/concepts/)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)