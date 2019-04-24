---
title: koa与express分析与实践之一：简介
tags:
  - koa与express分析与实践
categories: 后端
top: false
copyright: true
date: 2018-06-14 15:14:17
---
Express 是一个自身功能极简，完全是由路由和中间件构成一个的 web 开发框架：从本质上来说，一个 Express 应用就是在调用各种中间件。koa 是由 Express 原班人马打造的，致力于成为一个更小、更富有表现力、更健壮的 Web 框架。
<!--more-->

## express简介
init一个node项目，项目初始化后安装express
```
npm install express --save
```
使用express的代码如下：
```js
var express = require('express');
var app = express();

app.get('/', function (req, res) {
  res.send('Hello World!');
});

var server = app.listen(3000, function () {
  var host = server.address().address;
  var port = server.address().port;

  console.log('Example app listening at http://%s:%s', host, port);
});
```
上面的代码启动一个服务并监听从 3000 端口进入的所有连接请求。他将对所有 (/) URL 或 路由 返回 “Hello World!” 字符串。
### express生成器
通过应用生成器工具 express 可以快速创建一个应用的骨架。
```
npm install express-generator -g

express myapp
cd myapp 
npm install
set DEBUG=myapp & npm start
```
通过 Express 应用生成器创建的应用一般都有如下目录结构：
```
.
├── app.js
├── bin
│   └── www
├── package.json
├── public
│   ├── images
│   ├── javascripts
│   └── stylesheets
│       └── style.css
├── routes
│   ├── index.js
│   └── users.js
└── views
    ├── error.jade
    ├── index.jade
    └── layout.jade

7 directories, 9 files
```
### express路由
路由（Routing）是由一个 URI（或者叫路径）和一个特定的 HTTP 方法（GET、POST 等）组成的，涉及到应用如何响应客户端对某个网站节点的访问。每一个路由都可以有一个或者多个处理器函数，当匹配到路由时，这个/些函数将被执行。
```
app.METHOD(PATH, HANDLER)
```
其中，app 是一个 express 实例；METHOD 是某个 HTTP 请求方式中的一个；PATH 是服务器端的路径；HANDLER 是当路由匹配到时需要执行的函数。

使用字符串模式的路由是可以使用正则的。

```js
// 匹配 abcd、abbcd、abbbcd等
app.get('/ab+cd', function(req, res) {
  res.send('ab+cd');
});

// 匹配 abcd、abxcd、abRABDOMcd、ab123cd等
app.get('/ab*cd', function(req, res) {
  res.send('ab*cd');
});

// 匹配 /abe 和 /abcde
app.get('/ab(cd)?e', function(req, res) {
 res.send('ab(cd)?e');
});

//使用正则表达式的路由路径示例：
// 匹配任何路径中含有 a 的路径：
app.get(/a/, function(req, res) {
  res.send('/a/');
});

// 匹配 butterfly、dragonfly，不匹配 butterflyman、dragonfly man等
app.get(/.*fly$/, function(req, res) {
  res.send('/.*fly$/');
});
```

### 路由句柄
著作权归作者所有。
商业转载请联系作者获得授权,非商业转载请注明出处。
链接:http://caibaojian.com/express-basic.html
来源:http://caibaojian.com

可以为请求处理提供多个回调函数，其行为类似 中间件。唯一的区别是这些回调函数有可能调用 next('route') 方法而略过其他路由回调函数。

路由句柄有多种形式，可以是一个函数、一个函数数组，或者是两者混合，如下所示
```js
app.get('/example/b', function (req, res, next) {
  console.log('response will be sent by the next function ...');
  next();
}, function (req, res) {
  res.send('Hello from B!');
});

//使用回调函数数组处理路由：

var cb0 = function (req, res, next) {
  console.log('CB0');
  next();
}

var cb1 = function (req, res, next) {
  console.log('CB1');
  next();
}

var cb2 = function (req, res) {
  res.send('Hello from C!');
}

app.get('/example/c', [cb0, cb1, cb2]);
```

### 响应方法
下表中响应对象（res）的方法向客户端返回响应，终结请求响应的循环。如果在路由句柄中一个方法也不调用，来自客户端的请求会一直挂起。

方法 描述
```js
res.download() 提示下载文件。
res.end() 终结响应处理流程。
res.JSON() 发送一个 JSON 格式的响应。
res.jsonp() 发送一个支持 JSONP 的 JSON 格式的响应。
res.redirect() 重定向请求。
res.render() 渲染视图模板。
res.send() 发送各种类型的响应。
res.sendFile 以八位字节流的形式发送文件。
res.sendStatus() 设置响应状态代码，并将其以字符串形式作为响应体的一部分发送。
```

### app.route()
可使用 app.route() 创建路由路径的链式路由句柄。由于路径在一个地方指定，这样做有助于创建模块化的路由，而且减少了代码冗余和拼写错误。
```js
app.route('/book')
  .get(function(req, res) {
    res.send('Get a random book');
  })
  .post(function(req, res) {
    res.send('Add a book');
  })
  .put(function(req, res) {
    res.send('Update the book');
  });
```
### express.Router
可使用 express.Router 类创建模块化、可挂载的路由句柄。Router 实例是一个完整的中间件和路由系统，因此常称其为一个 “mini-app”。

在 app 目录下创建名为 birds.js 的文件，内容如下：
```js
var express = require('express');
var router = express.Router();

// 该路由使用的中间件
router.use(function timeLog(req, res, next) {
  console.log('Time: ', Date.now());
  next();
});
// 定义网站主页的路由
router.get('/', function(req, res) {
  res.send('Birds home page');
});
// 定义 about 页面的路由
router.get('/about', function(req, res) {
  res.send('About birds');
});

module.exports = router;
```
然后在应用中加载路由模块：
```js
var birds = require('./birds');
...
app.use('/birds', birds);
```
应用即可处理发自 /birds 和 /birds/about 的请求，并且调用为该路由指定的 timeLog 中间件。

### 利用 Express 托管静态文件
通过 Express 内置的 express.static 可以方便地托管静态文件，例如图片、CSS、JavaScript 文件等。

将静态资源文件所在的目录作为参数传递给 express.static 中间件就可以提供静态资源文件的访问了。例如，假设在 public 目录放置了图片、CSS 和 JavaScript 文件，你就可以：
```js
app.use(express.static('public'));
```
现在，public 目录下面的文件就可以访问了。

```
http://localhost:3000/images/kitten.jpg
http://localhost:3000/css/style.css
http://localhost:3000/js/app.js
http://localhost:3000/images/bg.png
http://localhost:3000/hello.html
```

如果你的静态资源存放在多个目录下面，你可以多次调用 express.static 中间件。
```js
app.use(express.static('public'));
app.use(express.static('files'));
```
如果你希望所有通过 express.static 访问的文件都存放在一个“虚拟（virtual）”目录（即目录根本不存在）下面，可以通过为静态资源目录指定一个挂载路径的方式来实现，如下所示：
```js
app.use('/static', express.static('public'));
```
现在，你就爱可以通过带有 “/static” 前缀的地址来访问 public 目录下面的文件了。
```
http://localhost:3000/static/images/kitten.jpg
http://localhost:3000/static/css/style.css
http://localhost:3000/static/js/app.js
http://localhost:3000/static/images/bg.png
http://localhost:3000/static/hello.html
```
### 常见问题

#### 如何处理 404 ？
在 Express 中，404 并不是一个错误（error）。因此，错误处理器中间件并不捕获 404。这是因为 404 只是意味着某些功能没有实现。也就是说，Express 执行了所有中间件、路由之后还是没有获取到任何输出。你所**需要做的就是在其所有他中间件的后面添加一个处理 404 的中间件**。如下：
```js
app.use(function(req, res, next) {
  res.status(404).send('Sorry cant find that!');
});
```
#### Express 支持哪些模板引擎？
Express 支持任何符合 (path, locals, callback) 接口规范的模板引擎，[具体可看这个项目。](https://github.com/tj/consolidate.js)

#### 如何渲染纯 HTML 文件？
不需要！无需通过 res.render() 渲染 HTML。你可以通过 res.sendFile() 直接对外输出 HTML 文件。如果你需要对外提供的资源文件很多，可以使用 express.static() 中间件。


## koa的使用

**Koa 必须使用 7.6 以上的版本。如果你的版本低于这个要求，就要先升级 Node。**

Koa 应用程序是一个包含一组中间件函数的对象，它是按照类似堆栈的方式组织和执行的。 Koa 类似于你可能遇到过的许多其他中间件系统。一个关键的设计点是在其低级中间件层中提供高级“语法糖”。 这提高了互操作性，稳健性，并使书写中间件更加愉快。这包括诸如内容协商，缓存清理，代理支持和重定向等常见任务的方法。 尽管提供了相当多的有用的方法 Koa 仍保持了一个很小的体积，因为没有捆绑中间件。
```js
const Koa = require('koa');
const app = new Koa();

app.use(async ctx => {
  ctx.body = 'Hello World';
});

app.listen(3000);
```

### 级联
Koa 中间件以更传统的方式级联，您可能习惯使用类似的工具 - 之前难以让用户友好地使用 node 的回调。然而，使用 async 功能，我们可以实现 “真实” 的中间件。对比 Connect 的实现，通过一系列功能直接传递控制，**直到一个返回，Koa 调用“下游”，然后控制流回“上游”。**

下面以 “Hello World” 的响应作为示例，当请求开始时首先请求流通过 x-response-time 和 logging 中间件，然后继续移交控制给 response 中间件。当一个中间件调用 next() 则该函数暂停并将控制传递给定义的下一个中间件。当在下游没有更多的中间件执行后，堆栈将展开并且每个中间件恢复执行其上游行为。

### 实例方法
应用程序设置是 app 实例上的属性，目前支持如下：
* app.env 默认是 NODE_ENV 或 "development"
* app.proxy 当真正的代理头字段将被信任时
* app.subdomainOffset 对于要忽略的 .subdomains 偏移[2]

```
app.listen(...) // 应用程序被绑定到端口
app.callback() // 返回适用于 http.createServer() 方法的回调函数来处理请求
app.use(function) // 将给定的中间件方法添加到此应用程序
app.keys= // 设置签名的 Cookie 密钥。
app.context // app.context 是从其创建 ctx 的原型
app.on('error',func)
```

### 上下文(Context)
Koa Context 将 node 的 request 和 response 对象封装到单个对象中，为编写 Web 应用程序和 API 提供了许多有用的方法。 这些操作在 HTTP 服务器开发中频繁使用，它们被添加到此级别而不是更高级别的框架，这将强制中间件重新实现此通用功能。

每个请求都将创建一个 Context，并在中间件中作为接收器引用，或者 ctx 标识符，如以下代码片段所示：
```js
app.use(async ctx => {
  ctx; // 这是 Context
  ctx.request; // 这是 koa Request
  ctx.response; // 这是 koa Response
});
```
为方便起见许多上下文的访问器和方法直接委托给它们的 ctx.request或 ctx.response ，不然的话它们是相同的。 例如 ctx.type 和 ctx.length 委托给 response 对象，ctx.path 和 ctx.method 委托给 request。
```
ctx.req // Node 的 request 对象.
ctx.res // Node 的 response 对象.绕过 Koa 的 response 处理是 不被支持的. 应避免使用以下 node 属性res.statusCode,res.writeHead(),res.write()res.end()
ctx.request // koa 的 Request 对象.
ctx.response // koa 的 Response 对象.
ctx.state // 推荐的命名空间，用于通过中间件传递信息和你的前端视图。
ctx.app //应用程序实例引用
ctx.cookies.get(name, [options]) //通过 options 获取 cookie name
ctx.cookies.set(name, value, [options]) // 通过 options 设置 cookie name 的 value
ctx.throw([status], [msg], [properties]) // Helper 方法抛出一个 .status 属性默认为 500 的错误，这将允许 Koa 做出适当地响应。
ctx.assert(value, [status], [msg], [properties]) // 当 !value 时，Helper 方法抛出类似于 .throw() 的错误。这与 node 的 assert() 方法类似.
ctx.respond // 为了绕过 Koa 的内置 response 处理，你可以显式设置 ctx.respond = false;。 如果您想要写入原始的 res 对象而不是让 Koa 处理你的 response，请使用此参数。
```
### Request 别名
以下访问器和 Request 别名等效：
```
ctx.header 
ctx.headers 
ctx.method 
ctx.method=
ctx.url
ctx.url=
ctx.originalUrl
ctx.origin
ctx.href
ctx.path
ctx.path=
ctx.query
ctx.query=
ctx.querystring
ctx.querystring=
ctx.host
ctx.hostname
ctx.fresh
ctx.stale
ctx.socket 
ctx.protocol
ctx.secure
ctx.ip
ctx.ips
ctx.subdomains
ctx.is()
ctx.accepts()
ctx.acceptsEncodings()
ctx.acceptsCharsets()
ctx.acceptsLanguages()
ctx.get()

```

### Response 别名
以下访问器和 Response 别名等效：
```
ctx.body
ctx.body=
ctx.status
ctx.status=
ctx.message
ctx.message=
ctx.length=
ctx.length
ctx.type=
ctx.type
ctx.headerSent
ctx.redirect()
ctx.attachment()
ctx.set()
ctx.append()
ctx.remove()
ctx.lastModified=
ctx.etag= 

```

### 响应(Response)
Koa Response 对象是在 node 的 vanilla 响应对象之上的抽象，提供了诸多对 HTTP 服务器开发有用的功能。
```
response.header // 响应标头对象
response.headers // 响应标头对象。别名是 response.header
response.socket // 请求套接字
response.status // 获取响应状态。默认情况下，response.status 设置为 404 而不是像 node 的 res.statusCode 那样默认为 200
response.status= // 通过数字代码设置响应状态
response.message // 获取响应的状态消息. 默认情况下, response.message 与 response.status 关联
response.message= // 将响应的状态消息设置为给定值
response.length= // 将响应的 Content-Length 设置为给定值
response.length // 以数字返回响应的 Content-Length，或者从ctx.body推导出来，或者undefined
response.body // 获取响应主体
response.body= // 将响应体设置为以下之一：string 写入,Buffer 写入,Stream 管道,Object || Array JSON-字符串化,null 无内容响应,如果 response.status 未被设置, Koa 将会自动设置状态为 200 或 204。
response.get(field) // 不区分大小写获取响应标头字段值 field
response.set(field, value) // 设置响应标头 field 到 value
response.append(field, value) // 用值 val 附加额外的标头 field
response.set(fields) // 用一个对象设置多个响应标头fields
response.remove(field) // 删除标头 field
response.type // 获取响应 Content-Type 不含参数 "charset"
response.type= // 设置响应 Content-Type 通过 mime 字符串或文件扩展名
response.is(types...) // 非常类似 ctx.request.is(). 检查响应类型是否是所提供的类型之一。这对于创建操纵响应的中间件特别有用
response.redirect(url, [alt]) // 执行 [302] 重定向到 url.要更改 “302” 的默认状态，只需在该调用之前或之后分配状态。要变更主体请在此调用之后。
response.attachment([filename]) // 将 Content-Disposition 设置为 “附件” 以指示客户端提示下载。(可选)指定下载的 filename
response.headerSent // 检查是否已经发送了一个响应头。 用于查看客户端是否可能会收到错误通知
response.lastModified // 将 Last-Modified 标头返回为 Date, 如果存在
response.lastModified= // 将 Last-Modified 标头设置为适当的 UTC 字符串。您可以将其设置为 Date 或日期字符串
response.etag= // 设置包含 " 包裹的 ETag 响应， 请注意，没有相应的 response.etag getter
response.vary(field) // 在 field 上变化
response.flushHeaders() // 刷新任何设置的标头，并开始主体

```

## Koa 还是 Express？
koa是一个比express更精简，使用node新特性的中间件框架，相比之前express就是一个庞大的框架。
* 如果你喜欢diy，很潮，可以考虑koa，它有足够的扩展和中间件，而且自己写很简单
* 如果你想简单点，找一个框架啥都有，那么先express

koa是大势所趋。

**参考资料**
[学习nodejs：express 入门和基础知识](http://caibaojian.com/express-basic.html)
[一文讲透koa-源码剖析](https://juejin.im/entry/59e747f0f265da431c6f668e)
[Node.js 框架对比之 Express VS Koa](https://juejin.im/entry/58a11f61128fe1005823a257)
[Koa 还是 Express？](https://cnodejs.org/topic/55815f28395a0c1812f18257)

[koa官方文档](https://koa.bootcss.com/#)


![](http://static.zhyjor.com/wexin.png)
