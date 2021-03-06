---
title: Git原理与使用之六：使用GitHooks能干什么
tags:
  - Git原理与使用
  - Git
categories: Git
top: false
copyright: true
date: 2017-05-24 09:28:30
---
和其它版本控制系统一样，Git 能在特定的重要动作发生时触发自定义脚本，这就是我们所说的钩子，换句话说，钩子就是callback，可以在特定的时候，触发特定的callback。本文主要介绍git hooks、自动部署、Travis CI的相关知识。
<!--more-->
## Git 钩子
Git 钩子(hooks)是在 Git 仓库中特定事件(certain points)触发后被调用的脚本。通过钩子可以自定义 Git 内部的相关（如 git push）行为，在开发周期中的关键点触发自定义的行为。Git 含有两种类型的钩子：客户端的和服务器端的。**客户端钩子由诸如提交和合并这样的操作所调用，而服务器端钩子作用于诸如接收被推送的提交这样的联网操作。**
![](http://static.zhyjor.com/201808240946_295.png)

Git 钩子最常见的使用场景包括根据仓库状态改变项目环境、接入持续集成工作流等。由于脚本是可以完全定制，所以你可以用 Git 钩子来自动化或者优化你开发工作流中任意部分。

### 安装一个钩子
钩子都被存储在 Git 目录下的 hooks 子目录中。 也即绝大部分项目中的 .git/hooks 。 当你用 git init 初始化一个新版本库时，Git 默认会在这个目录中放置一些示例脚本。这些脚本除了本身可以被调用外，它们还透露了被触发时所传入的参数。 

所有的示例都是 shell 脚本，其中一些还混杂了 Perl 代码，不过，任何正确命名的可执行脚本都可以正常使用 —— 你可以用 Ruby 或 Python，或其它语言编写它们。

![](http://static.zhyjor.com/201808240950_288.png)

这些示例的名字都是以 .sample 结尾，.sample拓展名是为了防止它们默认被执行，如果你想安装一个钩子需要启用它们，去掉.sample拓展名即可。

## 客户端钩子
客户端钩子分为很多种。 下面把它们分为：提交工作流钩子、电子邮件工作流钩子和其它钩子。
> 需要注意的是，克隆某个版本库时，它的客户端钩子 并不 随同复制。 如果需要靠这些脚本来强制维持某种策略，建议你在服务器端实现这一功能。

 6 个最有用的本地钩子是：
* pre-commit
* prepare-commit-msg
* commit-msg
* post-commit
* post-checkout
* pre-rebase

前四个钩子让你介入完整的提交生命周期，后两个允许你执行一些额外的操作，分别为 git checkout 和 git rebase 的安全检查。

所有带 pre- 的钩子允许你修改即将发生的操作，而带 post- 的钩子只能用于通知。

### 提交工作流钩子
前四个钩子涉及提交的过程。

#### pre-commit 
**钩子在键入提交信息前运行**。 它用于检查即将提交的快照，例如，检查是否有所遗漏，确保测试运行，以及核查代码。 如果该钩子以非零值退出，Git 将放弃此次提交，不过你可以用 `git commit --no-verify` 来绕过这个环节。 你可以利用该钩子，来检查代码风格是否一致（运行类似 lint 的程序）、尾随空白字符是否存在（自带的钩子就是这么做的），或新方法的文档是否适当。

#### prepare-commit-msg
**钩子在启动提交信息编辑器之前，默认信息被创建之后运行**。 它允许你编辑提交者所看到的默认信息。 该钩子接收一些选项：存有当前提交信息的文件的路径、提交类型和修补提交的提交的 SHA-1 校验。 它对一般的提交来说并没有什么用；然而对那些会自动产生默认信息的提交，如提交信息模板、合并提交、压缩提交和修订提交等非常实用。 你可以结合提交模板来使用它，动态地插入信息。

#### commit-msg 
钩子接收一个参数，此参数即上文提到的，存有当前提交信息的临时文件的路径。 如果该钩子脚本以非零值退出，Git 将放弃提交，因此，可以用来在提交通过前验证项目状态或提交信息。 

#### post-commit
钩子在整个提交过程完成后运行。 它不接收任何参数，但你可以很容易地通过运行 git log -1 HEAD 来获得最后一次的提交信息。 该钩子一般用于通知之类的事情。

### 电子邮件工作流钩子
你可以给电子邮件工作流设置三个客户端钩子。 它们都是由 git am 命令调用的，因此如果你没有在你的工作流中用到这个命令，可以跳到下一节。 如果你需要通过电子邮件接收由 git format-patch 产生的补丁，这些钩子也许用得上。

#### applypatch-msg
第一个运行的钩子是 applypatch-msg 。 它接收单个参数：包含请求合并信息的临时文件的名字。 如果脚本返回非零值，Git 将放弃该补丁。 你可以用该脚本来确保提交信息符合格式，或直接用脚本修正格式错误。

#### pre-applypatch
下一个在 git am 运行期间被调用的是 pre-applypatch 。 有些难以理解的是，它正好运行于应用补丁 之后，产生提交之前，所以你可以用它在提交前检查快照。 你可以用这个脚本运行测试或检查工作区。 如果有什么遗漏，或测试未能通过，脚本会以非零值退出，中断 git am 的运行，这样补丁就不会被提交。

#### post-applypatch
post-applypatch 运行于提交产生之后，是在 git am 运行期间最后被调用的钩子。 你可以用它把结果通知给一个小组或所拉取的补丁的作者。 但你没办法用它停止打补丁的过程。

### 其它客户端钩子
#### pre-rebase 
pre-rebase 钩子运行于变基之前，以非零值退出可以中止变基的过程。 你可以使用这个钩子来禁止对已经推送的提交变基。 Git 自带的 pre-rebase 钩子示例就是这么做的，不过它所做的一些假设可能与你的工作流程不匹配。

#### post-rewrite
post-rewrite 钩子被那些会替换提交记录的命令调用，比如 git commit --amend 和 git rebase（不过不包括 git filter-branch）。 它唯一的参数是触发重写的命令名，同时从标准输入中接受一系列重写的提交记录。 这个钩子的用途很大程度上跟 post-checkout 和 post-merge 差不多。

#### post-checkout
在 git checkout 成功运行后，post-checkout 钩子会被调用。你可以根据你的项目环境用它调整你的工作目录。 其中包括放入大的二进制文件、自动生成文档或进行其他类似这样的操作。

#### post-merge
在 git merge 成功运行后，post-merge 钩子会被调用。 你可以用它恢复 Git 无法跟踪的工作区数据，比如权限数据。 这个钩子也可以用来验证某些在 Git 控制之外的文件是否存在，这样你就能在工作区改变时，把这些文件复制进来。

#### pre-push
pre-push 钩子会在 git push 运行期间， 更新了远程引用但尚未传送对象时被调用。 它接受远程分支的名字和位置作为参数，同时从标准输入中读取一系列待更新的引用。 你可以在推送开始之前，用它验证对引用的更新操作（一个非零的退出码将终止推送过程）。

#### pre-auto-gc
Git 的一些日常操作在运行时，偶尔会调用 git gc --auto 进行垃圾回收。 pre-auto-gc 钩子会在垃圾回收开始之前被调用，可以用它来提醒你现在要回收垃圾了，或者依情形判断是否要中断回收。

## 服务器端钩子
除了客户端钩子，作为系统管理员，你还可以使用若干服务器端的钩子对项目强制执行各种类型的策略。 这些钩子脚本在推送到服务器之前和之后运行。 **推送到服务器前运行的钩子可以在任何时候以非零值退出，拒绝推送并给客户端返回错误消息，还可以依你所想设置足够复杂的推送策略。**

### pre-receive
处理来自客户端的推送操作时，最先被调用的脚本是 pre-receive。 它从标准输入获取一系列被推送的引用。如果它以非零值退出，所有的推送内容都不会被接受。 你可以用这个钩子阻止对引用进行非快进（non-fast-forward,git仓库中已经有一部分代码，所以它不允许你直接把你的代码覆盖上去。）的更新，或者对该推送所修改的所有引用和文件进行访问控制。

### update
update 脚本和 pre-receive 脚本十分类似，不同之处在于它会为每一个准备更新的分支各运行一次。 假如推送者同时向多个分支推送内容，pre-receive 只运行一次，相比之下 update 则会为每一个被推送的分支各运行一次。 它不会从标准输入读取内容，而是接受三个参数：引用的名字（分支），推送前的引用指向的内容的 SHA-1 值，以及用户准备推送的内容的 SHA-1 值。 如果 update 脚本以非零值退出，只有相应的那一个引用会被拒绝；其余的依然会被更新。

### post-receive
post-receive 挂钩在整个过程完结以后运行，可以用来更新其他系统服务或者通知用户。 它接受与 pre-receive 相同的标准输入数据。 它的用途包括给某个邮件列表发信，通知持续集成（continous integration）的服务器，或者更新问题追踪系统（ticket-tracking system） —— 甚至可以通过分析提交信息来决定某个问题（ticket）是否应该被开启，修改或者关闭。 该脚本无法终止推送进程，不过客户端在它结束运行之前将保持连接状态，所以如果你想做其他操作需谨慎使用它，因为它将耗费你很长的一段时间。


## Git 钩子的作用域

Git 钩子是对本地仓库相关操作影响，对于任何 Git 仓库来说钩子都是本地的，初始的钩子都是从 Git 默认模板目录中自动安装。

在开发团队中为了保持团队所使用钩子一致，维护起来算是比较复杂的，因为 .git/hooks 目录不随你的项目一起拷贝，也不受版本控制影响。

![](http://static.zhyjor.com/201808241011_32.png)

> 简单的解决办法是把钩子文件存放在项目的实际目录中（在.git 外），这样就可以像其他文件一样进行版本控制，然后在.git/hooks中创建一个链接，或者简单地在更新后把它们复制到.git/hooks目录下。

## Git 钩子进行自动部署(Push to Deploy)
如何实现 Git 钩子进行自动部署，其实原理很简单，我们只需要监听每次本地 git push到远程服务器，然后远程服务器同步拉取最新文件，重启服务器即可（pm2 reload xx）。

![](http://static.zhyjor.com/201808241013_918.png)

### 创建服务器端仓库
服务器上需要配置两个仓库，一个用于代码中转的远程仓库，一个用于用户访问的本地仓库。这里的「远程仓库」并不等同于托管代码的「中央仓库」，这两个仓库都是为了自动同步代码并部署网站而存在。

在存放远程仓库的目录中（假设是 `/home/USER/repos`）执行 `git init --bare BRIDGE_REPO.git` 会创建一个包含 Git 各种配置文件的「裸仓库」。

切换到存放用户所访问文件的目录（假设为 `/home/USER/www`，如果不存在则在 `/home/USER` 中执行 mkdir www）：
```
git init
git remote add origin ~/repos/BRIDGE_REPO.git
git fetch
git checkout master
```
### 配置 Git Hook
将目录切换至 /home/USER/repos/BRIDGE_REPO.git/hooks，用 cp post-receive.sample post-receive 复制并重命名文件后用 vim post-receive 修改。其内容大致如下：
```bash
#!/bin/sh

unset GIT_DIR

NowPath=`pwd`
DeployPath="../../www"

cd $DeployPath
git pull origin master

cd $NowPath
exit 0
```

**注意： 一定要`unset GIT_DIR`清除变量， 不然会引起`remote: fatal: Not a git repository: ‘.’`错误。**

使用 `chmod +x post-receive` 改变一下权限后，服务器端的配置就基本完成了。

## Webhooks
Github或者Gitlab的Webhooks，允许用户订阅特定的事件，如commit, push，两者不尽相同，但本质差不太多。

### 自动部署脚本

Webhooks的作用就是在特定的事件执行的时候触发自定义的动作。本质上，Github的Webhooks触发后，会给相应的URL(自行设置，后面会讲解)发送POST请求，请求头中含有event等相应的信息。
而正确响应后的事件，比如push完之后，触发自动部署脚本，现在我们来写一个简单的脚本。
```bash
#!/bin/bash
PROJECT_DIR = 'path-to-your-project'

echo 'start'
cd $PROJECT_DIR

echo 'pull code'
git reset --hard origin/master && git clean -f
git pull && git checkout master

echo 'run npm script'
npm run build

echo 'finished'
```
脚本大概的作用就是cd到项目目录，拉取最新的代码，build代码(该步骤不一定需要，如果你的代码直接可以上测试/生产环境)。你必须保证，脚本中涉及的环境变量是可用的，比如git，npm等等。

### 设置Webhooks
这一步就不详细说明了，github、gitlab以及码云上基本都在setting里面有响应的设置，我们在填入在触发一些事件的时候加上对应的回调就可以了，一般都是post请求。下面我们看一下这个回调的服务怎么写，我们需要将这个回调放在我们的服务器上，等在调用。

### 配置回调url
目前Github上有很多处理的handler。对于前端，当然是node的最熟悉，可以采用github-webhook-handler，也可以使用：
```
npm install node-github-webhook --save
```
入口文件：
```js
var http = require('http')
var createHandler = require('node-github-webhook')
var handler = createHandler({ path: '/app', secret: 'appsecret' }) // single handler
function execFunc(content) {
  var exec = require('child_process').exec
  exec(content, function(error, stdout, stderr) {
    if (error) {
      console.error('exec error:' + error)
      return
    }
    console.log('stdout:' + stdout)
    console.log('stderr:' + stderr)
  })
}
http.createServer(function (req, res) {
  handler(req, res, function (err) {
    res.statusCode = 404
    res.end('no such location')
  })
}).listen(7777)
handler.on('error', function (err) {
  console.error('Error:', err.message)
})
handler.on('push', function (event) {
  console.log(
    'Received a push event for %s to %s',
    event.payload.repository.name,
    event.payload.ref
  )
  execFunc('sh ./deploy.sh')
})
```
path就是前面Payload URL的内容，切记，是不包含host的，secret就是自己设置的密码，多个项目也可通过修改这个文件来设置。

### 守护程序与反向代理
理论上，现在就可以运行了。
```
node app.js
```
但是，现在的node-github-webhook遇到错误是直接抛错的，会终止程序的进行，所以最好采用守护进程去运行，如pm2，forever
```
pm2 start app.js
```
**现在程序是在7777端口跑的，需要Ngnix反向代理到80端口。这里就不展开了。**

## Travis CI
Travis CI 提供的是持续集成服务（Continuous Integration，简称 CI）。它绑定 Github 上面的项目，只要有新的代码，就会自动抓取。然后，提供一个运行环境，执行测试，完成构建，还能部署到服务器。

这里不详细展开了，对于github上的项目，可以通过配置Travis设置CI，一般编译通过示例如下：
![](http://static.zhyjor.com/201808241458_294.png)

Travis 要求项目的根目录下面，必须有一个.travis.yml文件。这是配置文件，指定了 Travis 的行为。该文件必须保存在 Github 仓库里面，一旦代码仓库有新的 Commit，Travis 就会去找这个文件，执行里面的命令。这里贴上我hexo博客的构建代码：
```
# blog-hexo/.travis.yml

# 使用语言
language: node_js
# node版本
node_js: stable
# 设置只监听哪个分支
branches:
  only:
  - master
# 缓存，可以节省集成的时间，这里我用了yarn，如果不用可以删除
cache:
  apt: true
  yarn: true
  directories:
    - node_modules
# tarvis生命周期执行顺序详见官网文档
before_install:
- git config --global user.name "xx"
- git config --global user.email "xxxx@163.com"
# 由于使用了yarn，所以需要下载，如不用yarn这两行可以删除
- curl -o- -L https://yarnpkg.com/install.sh | bash
- export PATH=$HOME/.yarn/bin:$PATH
- npm install -g hexo-cli
install:
# 不用yarn的话这里改成 npm i 即可
- yarn
script:
- hexo clean
- hexo generate
after_success:
- cd ./public
- git init
- git add --all .
- git commit -m "Travis CI Auto Builder"
# 这里的 REPO_TOKEN 即之前在 travis 项目的环境变量里添加的
- git push --quiet --force https://$REPO_TOKEN@github.com/zhyjor/zhyjor.github.io
  master
```

这里不详细说明了，[细节可以去阮一峰老师那里阅读。](http://www.ruanyifeng.com/blog/2017/12/travis_ci_tutorial.html)

## 总结
以上就是Git钩子以及一些自动部署，持续集成的相关知识，希望通过本文，能让大家对自动部署的实现有一定的了解。


**参考资料**
[Git 钩子：自定义你的工作流](https://github.com/geeeeeeeeek/git-recipes/wiki/5.4-Git-%E9%92%A9%E5%AD%90%EF%BC%9A%E8%87%AA%E5%AE%9A%E4%B9%89%E4%BD%A0%E7%9A%84%E5%B7%A5%E4%BD%9C%E6%B5%81)
[用 Git 钩子进行简单自动部署](https://aotu.io/notes/2017/04/10/githooks/index.html)
[python web 通过Git Hooks实现自动部署](https://zhuanlan.zhihu.com/p/25902833)
[用 Git Hooks 进行自动部署](https://segmentfault.com/a/1190000003836345)
[给你的项目增加Webhooks，自动进行部署（包含Github/Gitlab）](https://excaliburhan.com/post/add-webhooks-to-your-project.html)

![](http://static.zhyjor.com/wexin.png)
