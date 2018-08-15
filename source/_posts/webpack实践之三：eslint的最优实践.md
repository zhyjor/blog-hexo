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

## 手动实现一个配置
把 eslint 安装为项目依赖而非全局命令，项目可移植性更高。
```
npm install eslint -D
```
用 eslint 做检查需要配置规则集，存放规则集的文件就是配置文件，使用如下文件生成配置文件,：
```
./node_modules/.bin/eslint --init
```
回车后根目录下就有了 .eslintrc.js 配置文件：

```
module.exports = {
  env: {
    es6: true,
    node: true,
  },
  extends: 'eslint:recommended',
  rules: {
    indent: ['error', 4],
    'linebreak-style': ['error', 'unix'],
    quotes: ['error', 'single'],
    semi: ['error', 'always'],
  },
};
```
在 package.json 的 scripts 字段中新增命令 eslint：
```
{
  "scripts": {
    "eslint": "eslint *.js",
  },
}
```

## eslint 完成 react、vue.js 代码的检查
使用 eslint-plugin-react 检查 react 代码，使用 react-plugin-react-native 检查 react-native 代码，如果你比较懒，可以直接使用 eslint-config-airbnb，里面内置了 eslint-plugin-react，新人常遇到 peerDependencies 安装失败问题可参照 npmjs 主页上的方法解决.

推荐使用 vue.js 官方的 eslint 插件：eslint-plugin-vue 来检查 vue.js 代码，具体的配置方法官方 README 写的清晰明了，这里就不赘述了。

上面的几种 eslint 规则集的官方仓库都列出了各自支持的规则，如果你需要关闭某些规则，可以直接在自己的 .eslintrc* 里面的 rules 中配置.

**参考资料**
[Standard - JavaScript 代码规范 ](https://standardjs.com/readme-zhcn.html)
[用 husky 和 lint-staged 构建超溜的代码检查工作流](https://juejin.im/post/592615580ce463006bf19aa0)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)