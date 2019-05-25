---
title: webpack实践之二：单文件vueLoader配置项细节
tags:
  - webpack实践
  - webpack
categories: webpack
top: false
copyright: true
date: 2018-07-14 08:58:42
---
我们在通过vue-cli初始化一个webpack的vue项目时，在目录/build中会出现一个vue-loader.conf.js的配置文件，因为vue-loader的配置项比较多，最好的实践是单独将其提取出来，放在一个单独的配置文件中，然后在base配置的vue-loader中，作为一个options传入。
<!--more-->
那么有哪些很常用的配置呢，先看一个配置
```css
// vue-loader.config.js
module.exports = (isDev) => {
  return {
    preserveWhitepace: true,
    extractCSS: !isDev,
    cssModules: {
      localIdentName: isDev ? '[path]-[name]-[hash:base64:5]' : '[hash:base64:5]',
      camelCase: true
    },
    // hotReload: false, // 根据环境变量生成
  }
}
```

## cssModules
抛弃普通的css问题，利用js管理样式，这时就可以通过`this.$style.className`来进行管理。而且这时可以通过localIdentName的管理，可以实现类名全hash，有很好的加密效果。**twitter的样式就是这样实现的，更狠的是，他们每个css属性都是一个单独的类名。**

配置项内容是一个对象，有很多可配置的属性：

### localIdentName
在css处理过程中，node会有一些默认的属性传进来，比如这些path,name，hash等，这些都是当前的环境存在的，这样生成的类型就包含的当前的文件信息，实现了文件的隔离。**当然这用scope也可以实现，不过这里可以只用hash来实现class名字的加密，这一项scope是实现不了的。**根据团队需求，确认好用哪种就行了。
```css
localIdentName: isDev ? '[path]-[name]-[hash:base64:5]' : '[hash:base64:5]',
```
### camelCase
允许使用驼峰的方式添加类名，这里是直接对应的，因为css中常用的连接符在js中是非法的，这个配置相对必要。

### 小结
这里因为我们还有css-loader，两个同时可以用。

## hotReload
热重载，假如关闭的话，会以刷新页面的方式，修改样式，体验不好。

但是这个我们一般不会配置，webpack会根据当前的环境变量自动设置这些。

## postCss
这里需要一个但是的配置文件，我们在后面细说

## preLoader
预先进行的处理，这里比如ts的处理，一般都是先将其转换为普通的js，在通过配置的js处理

## postLoader
后进行的处理

**参考资料**
[]()

![](http://static.zhyjor.com/wexin.png)
