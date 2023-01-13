---
title: 深入理解koa之一：20行代码实现的洋葱圈中间件模型
tags:
  - koa
  - js
  - node
  - 后端
categories: node
top: false
copyright: true
date: 2023-01-13 14:59:04
---
下雨了，也快过年了，很多人应该都已经确定回家的行程了吧，下雨当然不能阻挡回家的脚步。最喜欢在家里的柿子树下听着外面爆竹的声音，那一刻年味儿就回来了

闲言少叙，开始正文
<!--more-->
koa想必很多人直接或间接的都用过，其源码不知道阅读本文的你有没有看过，相当精炼，本文想具体说说koa的中间件模型，一起看看[koa-compose](https://github.com/koajs/compose)的源码，这也是koa系列的第一篇文章，后续会更新一下koa相关的其他知识点

## koa中间件demo
先让我们启动一个koa服务
```js
// app.js
const koa = require('koa');
const app = new koa();
app.use(async (ctx, next) => {
  console.log('进入第一个中间件')
  next();
  console.log('退出第一个中间件')
})
app.use(async (ctx, next) => {
  console.log('进入第2个中间件')
  next();
  console.log('退出第2个中间件')
})

app.use((ctx, next) => {
  console.log('进入第3个中间件')
  next();
  console.log('退出第3个中间件')
})

app.use(ctx => {
  ctx.body = 'hello koa'
})

app.listen(8080, () => {
  console.log('服务启动，监听8080端口')
})

```
上述的服务在访问的时候会得到如下结果：

```txt
服务启动，监听8080端口
进入第1个中间件
进入第2个中间件
进入第3个中间件
退出第3个中间件
退出第2个中间件
退出第1个中间件
```
上面的返回结果会让人有些疑惑，有点像一个递归的过程，从现象上看当中间件调用next()的时候，函数会暂停并进入到下一个中间件，当执行了最后一个中间件后，执行代码会回溯上游中间件，并执行next()之后的代码，这就是koa的核心能力，洋葱圈模型

### 洋葱圈模型
先看一张经典的洋葱圈模型的示意图：

![](https://lxchuan12.gitee.io/assets/img/models.0be9c375.png)

在开发过程中，可以将next()之前的代码理解为**捕获阶段**, 而next()之后的代码可以理解为**释放阶段**，开发者结合这两个状态可以实现一些有趣的操作，比如记录一次请求的时间：
```js
async function responseTime(ctx, next) {
  const start = Date.now();
  await next();
  const ms = Date.now() - start;
  ctx.set('X-Response-Time', `${ms}ms`);
}

app.use(responseTime);
```
使用洋葱圈模型可以直接将响应时间记录的操作解耦出来，这样就不需要再去对称的写在业务逻辑中了，这是怎么实现的呢？

## 洋葱圈模型的实现，koa-compose
我们通过`app.use()`添加了很多函数，这些函数最终传递给了compose函数，先贴上koa-compose的源码，这里笔者删除掉了校验入参的一些非主干逻辑，我们可以看到代码也就18行，非常简单，接下来让我们一行一行的去看一下代码
```js
function compose (middleware) {
  return function (context, next) {
    let index = -1
    return dispatch(0)
    function dispatch (i) {
      if (i <= index) return Promise.reject(new Error('next() called multiple times'))
      index = i
      let fn = middleware[i]
      if (i === middleware.length) fn = next
      if (!fn) return Promise.resolve()
      try {
        return Promise.resolve(fn(context, dispatch.bind(null, i + 1)))
      } catch (err) {
        return Promise.reject(err)
      }
    }
  }
}

```
compose接收一个的函数数组`[fn1, fn2, fn3, ...]`，compose调用后，返回了一个匿名函数，匿名函数接收两个参数
* 第一个参数是上下文，对于koa的上下文不在本文的探究范围，我们只要记得这个是在各个中间件中的共享的就可以了
* 第二个参数标记为next，其实就是`undefined`
这个匿名函数记录了一个游标index，初始值是-1；这个游标会记录当前执行到哪个中间件了

**参考资料**
[koa-docs-Zh-CN](https://github.com/demopark/koa-docs-Zh-CN/blob/master/guide.md#debugging-koa)
https://segmentfault.com/a/1190000013447551
https://juejin.cn/post/6844903496257585160
https://ata.alibaba-inc.com/articles/91629?spm=ata.23639746.0.0.85d0152bHZduJX
https://juejin.cn/post/6855129007508488206#heading-5
https://lxchuan12.gitee.io/koa/#_6-koa-compose-%E6%BA%90%E7%A0%81-%E6%B4%8B%E8%91%B1%E6%A8%A1%E5%9E%8B%E5%AE%9E%E7%8E%B0
https://github.com/demopark/koa-docs-Zh-CN/blob/master/guide.md#debugging-koa
https://github.com/koajs/compose/blob/master/index.js

![](https://static.zhyjor.com/wexin.png)
