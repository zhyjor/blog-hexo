---
title: npm实践之二：scripts的最优配置
tags:
  - npm实践
  - npm
  - 前端工程化
categories: 前端
top: false
copyright: true
date: 2018-03-15 09:23:51
---
npm script 相比 grunt、gulp 之类的构建工具简单很多，因为它消除了这些构建工具所带来的抽象层，并带给我们更大的自由度。随着社区的发展，各种基础工具你都可以信手拈来，只要你会使用 npmjs.com 去搜索，或者去 libraries.io 上搜索。
<!--more-->

# 入门篇

## 多个script
通常来说，前端项目会包含 js、css、less、scss、json、markdown 等格式的文件，为保障代码质量，给不同的代码添加检查是很有必要的，代码检查不仅保障代码没有低级的语法错误，还可确保代码都遵守社区的最佳实践和一致的编码风格，在团队协作中尤其有用，即使是个人项目，加上代码检查，也会提高你的效率和质量。

一般我们会检查一下这些文件，html一般不检查。

* eslint，可定制的 js 代码检查，1.1 中有详细的配置步骤；
* stylelint，可定制的样式文件检查，支持 css、less、scss；
* jsonlint，json 文件语法检查，踩过坑的同学会清楚，json 文件语法错误会知道导致各种失败；
* markdownlint-cli，Markdown 文件最佳实践检查，个人偏好；
* mocha，测试用例组织，测试用例运行和结果收集的框架；
* chai，测试断言库，必要的时候可以结合 sinon 使用；

### 串并执行

只需要用 && 符号把多条 npm script 按先后顺序串起来**即可让多个 npm script 串行**。需要注意的是，串行执行的时候如果前序命令失败（通常进程退出码非0），后续全部命令都会终止。有些情况下我们需要检查并行，比如不同文件代码风格的检查。**运行从串行改成并行，实现方式更简单，把连接多条命令的 && 符号替换成 & 即可。**


npm 内置支持的多条命令并行跟 js 里面同时发起多个异步请求非常类似，它只负责触发多条命令，而不管结果的收集，如果并行的命令执行时间差异非常大，有时会出现子命令晚于run命令结束，在命令的增加 & wait 即可**(这条命令适合在 linux 下面)**。如下：
```
npm run lint:js & npm run lint:css & npm run lint:json & npm run lint:markdown & mocha tests/ & wait
```

加上 wait 的额外好处是，如果我们在任何子命令中启动了长时间运行的进程，比如启用了 mocha 的 --watch 配置，可以使用 ctrl + c 来结束进程，如果没加的话，你就没办法直接结束启动到后台的进程。

**npm-run-all 实现更轻量和简洁的多命令运行**,修改 package.json 实现多命令的串行执行：
```
npm i npm-run-all -D
// 串行执行
"test": "npm-run-all lint:js lint:css lint:json lint:markdown mocha"
// 支持通配符匹配分组的 npm script，可以直接匹配命令的key
"test": "npm-run-all lint:* mocha"
// 并行执行的时候，我们并不需要在后面增加 & wait，因为 npm-run-all 已经帮我们做了。
"test": "npm-run-all --parallel lint:* mocha"
```

## 参数传递
如下：
```
"lint:js": "eslint *.js",
"lint:js:fix": "npm run lint:js -- --fix",
```
要格外注意 --fix 参数前面的 -- 分隔符，意指要给 npm run lint:js 实际指向的命令传递额外的参数。


## 日志输出
使用 --loglevel silent，或者 --silent，或者更简单的 -s 来控制日志输出级别。排查脚本问题的时候比较有用，需要使用 --loglevel verbose，或者 --verbose，或者更简单的 -d 来控制，这个日志级别的输出实例详细打印出了每个步骤的参数、返回值。

# 进阶篇

## npm script钩子
运行 npm run test 的时候，分 3 个阶段：
* 检查 scripts 对象中是否存在 pretest 命令，如果有，先执行该命令；
* 检查是否有 test 命令，有的话运行 test 命令，没有的话报错；
* 检查是否存在 posttest 命令，如果有，执行 posttest 命令；

##  在 npm script 中使用变量
环境变量特性能让我们在 npm script 中直接调用依赖包里的可执行文件，更强大的是，npm 还提供了 $PATH 之外的更多的变量，比如当前正在执行的命令、包的名称和版本号、日志输出的级别等。

DRY（Don't Repeat Yourself）是基本的编程原则，在 npm script 中使用预定义变量和自定义变量让我们更容易遵从 DRY 原则，因为使用这些变量之后，npm script 就具备了自适应的能力，我们可以直接把积累起来的 npm script 使用到其他项目里面，而不用做任何修改。

### 预定义变量
首先我们来看预定义变量，通过运行 npm run env 就能拿到完整的变量列表，可以通过以下指令拿到部分排序后的预定义环境变量。
```
npm run env | grep npm_package | sort
```
部分排序后的预定义变量：
```
// 作者信息...
npm_package_author_email=wangshijun2010@gmail.com
npm_package_author_name=wangshijun
npm_package_author_url=http://github.com/wangshijun
// 依赖信息...
npm_package_devDependencies_markdownlint_cli=^0.5.0
npm_package_devDependencies_mocha=^4.0.1
npm_package_devDependencies_npm_run_all=^4.1.2
// 各种 npm script
npm_package_scripts_lint=npm-run-all --parallel lint:*
npm_package_scripts_lint_css=stylelint *.less
npm_package_scripts_lint_js=eslint *.js
npm_package_scripts_lint_js_fix=npm run lint:js -- --fix
npm_package_scripts_lint_json=jsonlint --quiet *.json
// 基本信息
npm_package_version=0.1.0
npm_package_gitHead=3796e548cfe406ec33ab837ac00bcbd6ee8a38a0
npm_package_license=MIT
npm_package_main=index.js
npm_package_name=hello-npm-script
npm_package_readmeFilename=README.md
// 依赖的配置
npm_package_nyc_exclude_0=**/*.spec.js
npm_package_nyc_exclude_1=.*.js
```
**变量的使用方法遵循 shell 里面的语法，直接在 npm script 给想要引用的变量前面加上 $ 符号即可。**

```
{
  "dummy": "echo $npm_package_name"
}
```
### 自定义变量
我们还可以在 package.json 中添加自定义变量，并且在 npm script 中使用这些变量。
```
"version": "0.1.0",
"config": {
    "port": 3000
  }
```
可以通过下面的方式来获取：
```
"cover:serve": "http-server coverage_archive/$npm_package_version -p $npm_package_config_port",
```
## 命令行自动补全
能不能实现类似 bash、zsh 里面的命令自动补全？答案是肯定的！npm 自身提供了自动完成工具 completion，将其集成到 bash 或者 zsh 里也非常容易。官方文档里面的集成方法如下：

```bash
npm completion >> ~/.bashrc
npm completion >> ~/.zshrc
```
它其实在你的配置文件中追加了一大坨 shell。上面命令中的 >> 意思是把前面命令的输出追加到后面的文件中。

npm 命令补全到目前为止显然还不够高效，能不能补全 package.json 里面的依赖名称？能不能在补全 npm script 的时候列出这个命令是干啥的？这里有个zsh的插件：zsh-better-npm-completion

有以下便利：
* 在 npm install 时自动根据历史安装过的包给出补全建议
* 在 npm uninstall 时候根据 package.json 里面的声明给出补全建议
* 在 npm run 时补全建议中列出命令细节

# 高阶篇

## npm script 跨平台兼容
不是所有的 shell 命令都是跨平台兼容的，甚至各种常见的文件系统操作也是不兼容的。**特别说明，windows 环境建议使用 git bash 来运行 npm script，使用 windows 自带的 cmd 可能会遇到比较多的问题**

### 文件系统操作的跨平台兼容
npm script 中涉及到的文件系统操作包括文件和目录的创建、删除、移动、复制等操作，而**社区为这些基本操作也提供了跨平台兼容的包**，列举如下：
* rimraf 或 del-cli，用来删除文件和目录，实现类似于 rm -rf 的功能；
* cpr，用于拷贝、复制文件和目录，实现类似于 cp -r 的功能；
* make-dir-cli，用于创建目录，实现类似于 mkdir -p 的功能；


### 用 cross-var 引用变量
Linux 和 Windows 下引用变量的方式是不同的，Linux 下直接可以用 `$npm_package_name`，而 Windows 下必须使用 `%npm_package_name%`，我们可以使用 cross-var 实现跨平台的变量引用。
```
npm install cross-var --save-dev
```
直接在原始命令前增加 cross-var 命令即可，而内含了两条子命令，我们需要用引号把整个命令包起来（注意这里是用的双引号，且必须转义），然后在前面加上 cross-var。
```
"cover:archive": "mkdir -p coverage_archive/$npm_package_version && cp -r coverage/* coverage_archive/$npm_package_version"
// 修改为
"cover:archive": "cross-var \"mkdir -p coverage_archive/$npm_package_version && cp -r coverage/* coverage_archive/$npm_package_version\"",
```

### 用 cross-env 设置环境变量
不同平台的环境变量语法不同，我们可以使用 cross-env 来实现 npm script 的跨平台兼容。比如我们在运行测试时，需要加上 NODE_ENV=test，或者在启动静态资源服务器时自定义端口号。

```
npm install cross-env --save-dev
```

直接在设置了环境变量的命令前面加上 cross-env 即可。

```
"test": "NODE_ENV=test mocha tests/"
// 修改为
"test": "cross-env NODE_ENV=test mocha tests/",
```

###小结
关于 npm script 的跨平台兼容，还有几点需要大家注意：
* 所有使用引号的地方，建议使用双引号，并且加上转义；
* 没做特殊处理的命令比如 eslint、stylelint、mocha、opn 等工具本身都是跨平台兼容的；
* 推荐linux,win可以考虑看看 Windows 10 里面引入的 Subsystem，让你不用虚拟机即可在 Windows 下使用大多数 Linux 命令。
* 如果你在编写 npm script 过程中有更多的跨平台兼容需求，基本思路是去 npmjs.com 上找对应的包，关键词自然少不了 cross platform，你遇到的问题，肯定很多其他人遇到过，相信我，你并不孤独！

## script 拆到单独文件中
借助 scripty 我们可以将 npm script 剥离到单独的文件中，从而把复杂性隔到单独的模块里面，让代码整体看起来更加清晰。**scripty 也支持通配符运行、脚本并行等特性、静默模式**。
```
npm install scripty --save-dev
```

按照 scripty 的默认约定，npm script 命令和各文件需要有指定的对应关系。而且在 shell 脚本里面是可以随意使用 npm 的内置变量和自定义变量的。修改 package.json，让保留的命令都指向 scripty，调用哪个脚本都由 scripty 来处理。
```
"scripts": {
	"cover": "scripty",
	"cover:serve": "scripty",
	"cover:open": "scripty"
}
```

## 用 node.js 脚本替代复杂的 npm script
Node.js 丰富的生态能赋予我们更强的能力，对于前端工程师来说，使用 Node.js 来编写复杂的 npm script 具有明显的 2 个优势：首先，编写简单的工具脚本对前端工程师来说额外的学习成本很低甚至可以忽略不计，其次，因为 Node.js 本身是跨平台的，用它编写的脚本出现跨平台兼容问题的概率很小。

### 安装依赖

在 Node.js 脚本中我们也能体味到 shelljs 这个工具包的强大:
```
npm install shelljs --save-dev
```
此外，我们计划使用 chalk 来给输出加点颜色，让脚本变的更有趣，同样安装到 devDependencies 里面：
```
npm install chalk --save-dev
```
### 创建 Node.js 脚本
shelljs 为我们提供了各种常见命令的跨平台支持，比如 cp、mkdir、rm、cd 等命令，此外，理论上你可以在 Node.js 脚本中使用任何 npmjs.com 上能找到的包。清理归档目录、运行测试、归档并预览覆盖率报告的完整 Node.js 代码如下：

```js
const { rm, cp, mkdir, exec, echo } = require('shelljs');
const chalk = require('chalk');

console.log(chalk.green('1. remove old coverage reports...'));
rm('-rf', 'coverage');
rm('-rf', '.nyc_output');

console.log(chalk.green('2. run test and collect new coverage...'));
exec('nyc --reporter=html npm run test');

console.log(chalk.green('3. archive coverage report by version...'));
mkdir('-p', 'coverage_archive/$npm_package_version');
cp('-r', 'coverage/*', 'coverage_archive/$npm_package_version');

console.log(chalk.green('4. open coverage report for preview...'));
exec('npm-run-all --parallel cover:serve cover:open');
```
关于改动的几点说明：
* 简单的文件系统操作，建议直接使用 shelljs 提供的 cp、rm 等替换；
* 部分稍复杂的命令，比如 nyc 可以使用 exec 来执行，也可以使用 istanbul 包来完成；
* 在 exec 中也可以大胆的使用 npm script 运行时的环境变量，比如 $npm_package_version；

然后修改package.json中的脚本指向：
```
"scripts": { 
	"cover": "node scripts/cover.js",
}
```
# 实战

## 文件变化时自动运行 npm script
代码检查自动化可以通过一些包来实现：
```
npm install onchange --save-dev

"watch:lint": "onchange -i \"**/*.js\" \"**/*.less\" -- npm run lint",
```
实际上onchange使用了跨平台的文件系统监听包 chokidar。onchange 有个不太醒目的特性是，文件系统发生变化之后，他在运行指定命令之前输出哪个文件发生了哪些变化。

##  livereload 实现自动刷新
react 种子项目生成工具 create-react-app 中就使用了这种技术。

但随着技术的演化，在单页应用中刷新页面意味着客户端状态的全部丢失，特别是复杂的单页应用刷新意味着更大量的重复工作才能回到刷新前的状态，于是社区又捣鼓出了 Hot Module Replacement，简称为 HMR，比如使用 vue-cli 创建的 webpack 种子项目中就包含这种特性，react-native 也内置了这种特性，来帮助开发者提高效率。

**livereload是自动刷新技术的鼻祖，后续的 HMR、HR 等都是它的改良版。**

## Git Hooks 中执行 npm script
Git 在代码版本管理之外，也提供了类似 npm script 里 pre、post 的钩子机制，叫做 Git Hooks，钩子机制能让我们在代码 commit、push 之前（后）做自己想做的事情。

### gitHook

本地项目通过 npm script 为本地仓库配置了 pre-commit、pre-push 钩子检查，为远程仓库（Remotes）配置 pre-receive 钩子检查。两种钩子的检查目的各不相同，**本地检查是为了尽早给提交代码的同学反馈**，哪些地方不符合规范，哪些地方需要注意；**而远程检查是为了确保远程仓库收到的代码是符合团队约定的规范的**，因为如果没有远程检查环节，熟悉 Git 的同学使用 --no-verify（简写为 -n） 参数跳过本地检查时，本地检查就形同虚设。

我们应该在 Git Hooks 里面做哪些事情呢？通常来说：检查编码规范，把低级错误趁早挖出来修好；运行测试，用自动化的方法做功能回归。

前端社区里有多种结合 npm script 和 git-hooks 的方案，比如 pre-commit、husky，相比较而言 husky 更好用，它支持更多的 Git Hooks 种类，再结合 lint-staged 试用就更溜。

### husky 优化钩子

husky 的基本工作原理可以稍作解释下，翻看 husky 的 package.json，注意其中的 scripts 声明：
```
"scripts": {
	"test": "jest",
	"format": "prettier --single-quote --no-semi --write **/*.js",
	"install": "node ./bin/install.js",
	"uninstall": "node ./bin/uninstall.js"
}
```
然后再检查我们仓库的 .git/hooks 目录，会发现里面的钩子都被 husky 替换掉了。

**需要在 scripts 对象中增加 husky 能识别的 Git Hooks 脚本：**
```
"scripts": {
    "precommit": "npm run lint",
    "prepush": "npm run test",
    "lint": "npm-run-all --parallel lint:*",
    "lint:js": "eslint *.js"
}
```
这两个命令的作用是在代码提交前运行所有的代码检查 npm run lint；在代码 push 到远程之前，运行 lint 和自动化测试。

### 用 lint-staged 改进 pre-commit
大型项目、遗留项目中接入过 lint 工作流，每次提交代码会检查所有的代码，可能比较慢就不说了，接入初期 lint 工具可能会报告几百上千个错误。好在，可以用lint-staged 来缓解这个问题，**每个团队成员提交的时候，只检查当次改动的文件**，示例配置如下：
```
"scripts": {
	"precommit": "lint-staged",
},
"lint-staged": {
	"*.js": "eslint",
	"*.less": "stylelint",
	"*.css": "stylelint",
	"*.json": "jsonlint --quiet",
	"*.md": "markdownlint --config .markdownlint.json"
}
```

## 实现构建流水线
在现代前端项目的交付工作流中，部署前最关键的环节就是构建，构建环节要完成的事情通常包括：
* 源代码预编译：比如 less、sass、typescript；
* 图片优化、雪碧图生成；
* JS、CSS 合并、压缩；
* 静态资源加版本号和引用替换；
* 静态资源传 CDN 等。

正常的资源依赖关系是：**css、html 文件中引用了图片；html 文件中引用了 css、js；**

显而易见，我们的构建过程必须遵循下面的步骤才能不出错：

* 压缩图片；
* 编译 less、压缩 css；
* 编译、压缩 js；
* 给图片加版本号并替换 js、css 中的引用；
* 给 js、css 加版本号并替换 html 中的引用；

### 图片构建过程
图片构建的经典工具是 imagemin，它也提供了命令行版本 imagemin-cli
```
npm i imagemin-cli -D

imagemin client/images/* --out-dir=dist/images
```
###  样式构建过程
我们使用 less 编写样式，所以需要预编译样式代码，可以使用 less 官方库自带的命令行工具 lessc，使用 sass 的同学可以直接使用 node-sass。此外，样式预编译完成之后，我们需要使用 cssmin 来完成代码预压缩。
```bash
npm install cssmin --save-dev

// bash
for file in client/styles/*.css
do
  lessc $file | cssmin > dist/styles/$(basename $file)
done
```
### JS 构建过程
我们使用 ES6 编写 JS 代码，所以需要 uglify-es 来进行代码压缩，如果你不使用 ES6，可以直接使用 uglify-js 来压缩代码
```
npm install uglify-es --save-dev

for file in client/scripts/*.js
do
  ./node_modules/uglify-es/bin/uglifyjs $file --mangle > dist/scripts/$(basename $file)
done
```
uglify-es 支持很多其他的选项，以及 sourcemap，对 JS 代码做极致的优化

### 资源版本号和引用替换
给静态资源加版本号的原因是线上环境的静态资源通常都放在 CDN 上，或者设置了很长时间的缓存，或者两者兼有，如果资源更新了但没有更新版本号，浏览器端是拿不到最新内容的，手动加版本号的过程很繁琐并且容易出错，为此自动化这个过程就显得非有价值，通常的做法是利用文件内容做哈希，比如 md5，然后以这个哈希值作为版本号，版本号附着在文件名里面，线上环境的资源引用全部是带版本号的。

为了实现这个过程，我们需要引入两个小工具：
* hashmark，自动添加版本号；
* replaceinfiles，自动完成引用替换，它需要将版本号过程的输出作为输入；

```
npm i hashmark replaceinfiles -D
```
然后在 scripts/build/hash.sh 中添加如下内容：
```
# 给图片资源加上版本号，并且替换引用
hashmark -c dist -r -l 8 '**/*.{png,jpg}' '{dir}/{name}.{hash}{ext}' | replaceinfiles -S -s 'dist/**/*.css' -d '{dir}/{base}'

# 给 js、css 资源加上版本号，并且替换引用
hashmark -c dist -r -l 8 '**/*.{css,js}' '{dir}/{name}.{hash}{ext}' | replaceinfiles -S -s 'client/index.html' -d 'dist/index.html'
```
本节用到的代码见 [GitHub](https://github.com/wangshijun/automated-workflow-with-npm-script/tree/12-use-npm-script-as-build-pipeline)

## 使用 npm script 进行服务运维
通常来说，项目构建完成之后，就成为待发布的版本，因此版本管理需要考虑，甚至做成自动化的，然后，最新的代码需要部署到线上机器才能让所有用户访问到，部署环节涉及到服务的启动、重启、日志管理等需要考虑。

### 使用 npm script 进行版本管理
每次构建完的代码都应该有新的版本号，修改版本号直接使用 npm 内置的 version 自命令即可，如果是简单粗暴的版本管理，可以在 package.json 中添加如下 scripts：
```
"release:patch": "npm version patch && git push && git push --tags",
"release:minor": "npm version minor && git push && git push --tags",
"release:major": "npm version major && git push && git push --tags",
"precommit": "lint-staged"
```
这 3 条命令遵循 semver 的版本号规范来方便你管理版本，patch 是更新补丁版本，minor 是更新小版本，major 是更新大版本。在必要的时候，可以通过运行 npm run version:patch 来升补丁版本.

### 使用 npm script 进行服务进程和日志管理
在生产环境的服务进程和日志管理领域，pm2 是当之无愧的首选，功能很强大，使用简单，开发环境常用的是 nodemon。
```
 npm install pm2 --save-dev
```
然后添加服务启动配置到项目根目录下 pm2.json
```
{
  "apps": [
    {
      "name": "npm-script-workflow",
      "script": "./server.js",// 服务脚本为 server.js
      "out_file": "./logs/stdout.log",//日志输出文件路径
      "error_file": "./logs/stderr.log",
      "log_date_format": "YYYY-MM-DD HH:mm:ss",//日志时间格式
      "instances": 0,
      "exec_mode": "cluster",//启动方式为 cluster
      "max_memory_restart": "800M",
      "merge_logs": true,
      "env": {
        "NODE_ENV": "production",
        "PORT": 8080,
      }
    }
  ]
}
```
上面的配置指定了服务脚本为 server.js，日志输出文件路径，日志时间格式，进程数量 = CPU 核数，启动方式为 cluster，以及两个环境变量。

###  配置服务部署命令
在没有集成 CI 服务之前，我们的部署命令应该是下面这样的：
```
"predeploy": "yarn && npm run build",
"deploy": "pm2 restart pm2.json",
```
即在部署前需要安装最新的依赖，重新构建，然后使用 pm2 重新启动服务即可，如果你有多台机器跑通1个服务，建议有个集中的 CI 服务器专门负责构建，而部署时就不需要运行 build 了。

每次需要部署服务时只需要运行 npm run deploy 就行了.

### 配置日志查看命令
至于日志，虽然 pm2 提供了内置的 logs 管理命令，如果某台服务器上启动了多个不同的服务进程，那么 pm2 logs 会展示所有服务的日志，个人建议使用如下命令查看当前服务的日志：
```
"logs": "tail -f logs/*"
```
当然如果你有更复杂的日志查看需求，直接用 cat、grep 之类的命令好了。

# 总结
其实仅仅是npm script并没有什么东西，关键是我们将这些工具结合在一起，npm script提供了我们运行的入口。


**参考资料**
[用 husky 和 lint-staged 构建超溜的代码检查工作流](https://juejin.im/post/592615580ce463006bf19aa0)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)