---
title: webpack实践之三：eslint的最优实践
tags:
  - webpack实践
  - webpack
categories: webpack
top: false
copyright: true
date: 2018-07-15 09:49:33
---
eslint的加入对我们写规范的js代码很有帮助，一些低级的错误可以直接报错。特别是在团队协作的时候，不能每个人都自己的风格，这样写出的代码是不能看的。
<!--more-->

## 继承现有规则
一般我们都是直接继承‘standard’的规则的，很多团队也都有自己的很好的配置。假如我们不想自己做这些事情的话，继承现有的也是很合适的一种做法

## .eslintrc文件
可以先看一下这个文件的配置写法:
```
{
  "extends": "standard",
  "plugins": [
    "html"
  ],
  "parser": "babel-eslint",
  "rules": {
    "no-new": "off"
  }
}

```
plugin的html配置因为.vue文件类似html文件，eslint无法识别其中的script，因此需要添加这个插件，这个需要安装一个插件：`eslint-plugin-html`。

## 配置检查与自动修复

这时我们就可以在package.json的scripts中添加指令了：
```
"lint": "eslint --ext .js --ext .jsx --ext .vue client/"
```
注意`--ext`指的是扩展名，最后指明需要执行检查的文件夹。

**可以使用使用lint进行自动修复**
```
"lint-fix": "eslint --fix --ext .js --ext .jsx --ext .vue client/"
```

## 自动检查
上一个方式需要手动的进行检查是否满足，假如需要进行自动检查的需要一些插件支持：eslint-loader,babel-loader。
注意这里需要在.eslintrc文件中配置一个parse，因为es6的语法需要babel进行处理，这样直接使用loader可能会有问题，因此需要添加一个loader：
```
// webpack.config.base.js
module: {
	rules: [
	  {
	    test: /\.(vue|js|jsx)$/,
	    loader: 'eslint-loader',
	    exclude: /node_modules/,
	    enforce: 'pre'
	  },
	  {
	    test: /\.vue$/,
	    loader: 'vue-loader',
	    options: createVueLoaderOptions(isDev)
	  },
	  {
	    test: /\.jsx$/,
	    loader: 'babel-loader'
	  },
	  {
	    test: /\.js$/,
	    loader: 'babel-loader',
	    exclude: /node_modules/
	  }
	]
}
```
注意这里的
```
exclude: /node_modules/,
enforce: 'pre'
```

## 添加.editorconfig文件
一个团队会有不同的软件，每个人的习惯不同，尤其是团队较大的时候，这个时候，通用的软件配置，很有必要。可以避免因为编辑器差异带来的奇怪的问题。

配置文件如下：
```
root = true

[*]
charset = utf-8
end_of_line = lf
indent_size = 2
indent_style = space
insert_final_newline = true
trim_trailing_whitespace = true
```
## githook阻止不规范的提交
在我们开发完成后，假如忘记检查就直接提交了代码，这会把不规范的代码提交的远程仓库，这是不合理的。我们可以利用一个包**husky**，利用githook，处理我们的eslint检查。**当然了，假如安装husky在git init之前，那就肯定不生效的，因为husky需要在./.git/config里进行hook的配置。**

```
"precommit": "npm run lint-fix"
```

其实上面的命令就是利用了githook，具体的指令 还是由我们自己配置。


**参考资料**
[Standard - JavaScript 代码规范 ](https://standardjs.com/readme-zhcn.html)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)