---
title: vue项目从开发到发布脚手架配置
date: 2017-10-08 14:52:35
tags: 
  - vue 
  - js
  
categories: vue
copyright: true
---

使用vue全家桶构建一个完整的单页面应用的配置过程，包括从开发，到测试以及发布的过程中的各种配置，比如ESLink,webpack等等。

<!--more-->

### ESLint配置

在使用`vue-cli`初始化一个vue项目时，我们可以选择添加ESLint，以对我们的项目中的js进行检查。添加后工程的根目录下会多出两个文件：
* `.eslintignore`类似Git的`.gitignore`用来忽略一些文件不使用ESLint检查。
* `.eslintrc.js`是ESLint配置文件，用来设置插件、自定义规则、解析器等配置。

**.eslintrc.js**
```
// https://eslint.org/docs/user-guide/configuring

module.exports = {
  root: true,
  parser: 'babel-eslint',
  parserOptions: {
    sourceType: 'module'
  },
  env: {
    browser: true,
  },
  // https://github.com/standard/standard/blob/master/docs/RULES-en.md
  extends: 'standard',
  // required to lint *.vue files
  plugins: [
    'html'
  ],
  // add your custom rules here
  'rules': {
    // allow paren-less arrow functions
    'arrow-parens': 0,
    // allow async-await
    'generator-star-spacing': 0,
    // allow debugger during development
    'no-debugger': process.env.NODE_ENV === 'production' ? 2 : 0,
    'no-new': 0
  }
}

```

**解析器(parser)：**使用了babel-eslint，这个可以在package.json中找到
**环境配置(env)：**在浏览器中使用eslint。 
**继承(extends)：**该配置文件继承了[standard](https://github.com/standard/standard/tree/master/docs)规则，文档包含各种语言版本，可自己选择。
**规则(rules)：**书写的要求,在rules中每个配置项后面第一个值是eslint规则的错误等级。off” 或 0 - 关闭这条规则 ，“warn” 或 1 - 违反规则会警告（不会影响项目运行），“error” 或 2 - 违反规则会报错（屏幕上一堆错误代码~）

#### 配置遇到的问题

**1、Do not use ‘new’ for side effects**
删除了/* eslint-disable no-new*/这段注释引发的，/* eslint-disable */这段注释的作用就是不让eslint检查注释下面的代码。
```
new Vue({
  el: '#app',
  router,
  template: '<App/>',
  components: { App }
})
```
**错误原因：**不可以直接new一个新对象，需要将新对象赋值给一个变量。
```
var vm = new Vue()
```

#### Tips
ESLink报错的位置都有一个链接，可以直接去看错误的原因
