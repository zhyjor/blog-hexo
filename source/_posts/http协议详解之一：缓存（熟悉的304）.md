---
title: http协议详解之一：缓存（熟悉的304）
tags:
  - http
  - http协议详解
categories: http
top: false
copyright: true
date: 2018-01-11 14:39:27
---
http协议的缓存机制是web性能优化的重要手段，对于前端开发进行到某些阶段的同学，应该是必不可少的基础知识。在之前分析腾讯粑粑的VasSnoic混合开发优化包的时候，也发下大佬们对缓存的应用出神入化。为了我们的前端架构师之路，让我们一起看看http的缓存到底是何方神圣吧。其他相关知识请参见[《http协议详解的系列》]()博客。
<!--more-->
对于浏览器，我们一般的理解就是请求静态资源后，浏览器会对其进行缓存，至于为什么缓存，怎么进行的并不清楚。

## 缓存规则解析
为方便大家理解，我们认为浏览器存在一个缓存数据库,用于存储缓存信息。
在客户端第一次请求数据时，此时缓存数据库中没有对应的缓存数据，需要请求服务器，服务器返回后，将数据存储至缓存数据库中。
![](https://images2015.cnblogs.com/blog/632130/201702/632130-20170210141639213-1923993391.png)

HTTP缓存有多种规则，根据是否需要重新向服务器发起请求来分类，分为两大类(强制缓存，对比缓存)
在详细介绍这两种规则之前，先通过时序图的方式，让大家对这两种规则有个简单了解。

**已存在缓存数据时，基于强制缓存**
![](https://images2015.cnblogs.com/blog/632130/201702/632130-20170210135521072-1812985836.png)

**已存在缓存数据时，仅基于对比缓存**
![](https://images2015.cnblogs.com/blog/632130/201702/632130-20170210141716838-764535017.png)

**对缓存机制不太了解的同学可能会问，基于对比缓存的流程下，不管是否使用缓存，都需要向服务器发送请求，那么还用缓存干什么？**
这个问题我们后续讨论。

我们可以看到两类缓存规则的不同，强制缓存如果生效，不需要再和服务器发生交互，而对比缓存不管是否生效，都需要与服务端发生交互。
两类缓存规则可以同时存在，强制缓存优先级高于对比缓存，也就是说，当执行强制缓存的规则时，如果缓存生效，直接使用缓存，不再执行对比缓存规则。

## 强制缓存
从上文我们得知，强制缓存，在缓存数据未失效的情况下，可以直接使用缓存数据，**那么浏览器是如何判断缓存数据是否失效呢？**
我们知道，在没有缓存数据的时候，浏览器向服务器请求数据时，服务器会将数据和缓存规则一并返回，缓存规则信息包含在响应header中。

对于强制缓存来说，响应header中会有两个字段来标明失效规则（Expires/Cache-Control），使用chrome的开发者工具，可以很明显的看到对于强制缓存生效时，网络请求的情况。

**命中强缓存的情况下，返回的 HTTP 状态码为 200 **
![](https://images2015.cnblogs.com/blog/632130/201702/632130-20170210141755072-1978466289.png)

### Expires

Expires的值为服务端返回的到期时间，即下一次请求时，请求时间小于服务端返回的到期时间，直接使用缓存数据。
不过Expires 是HTTP 1.0的东西，现在默认浏览器均默认使用HTTP 1.1，所以它的作用基本忽略。
另一个问题是，到期时间是由服务端生成的，但是客户端时间可能跟服务端时间有误差，这就会导致缓存命中的误差。
所以**HTTP 1.1 的版本，使用Cache-Control替代。**

### Cache-Control
Cache-Control 是最重要的规则。常见的取值有private、public、no-cache、max-age，no-store，默认为private。

* private: 客户端可以缓存
* public: 客户端和代理服务器(cdn)都可缓存（前端的同学，可以认为public和private是一样的）
* max-age=xxx:   缓存的内容将在 xxx 秒后失效
* s-maxage=xxx: s-maxage 就是用于表示 cache 服务器上（比如 cache CDN）的缓存的有效时间的，并只对 public 缓存有效。
* no-cache: 需要使用对比缓存来验证缓存数据（后面介绍）,我们为资源设置了 no-cache 后，每一次发起请求都不会再去询问浏览器的缓存情况，而是直接向服务端去确认该资源是否过期（即走我们下文即将讲解的协商缓存的路线）。
* no-store:  所有内容都不会缓存，强制缓存，对比缓存都不会触发（对于前端开发来说，缓存越多越好），只允许你直接向服务端发送请求、并下载完整的响应。

如下：
![](https://images2015.cnblogs.com/blog/632130/201702/632130-20170210141836104-1513192908.png)

图中Cache-Control仅指定了max-age，所以默认为private，缓存时间为31536000秒（365天）也就是说，在365天内再次请求这条数据，都会直接获取缓存数据库中的数据，直接使用。

## 对比缓存
顾名思义，需要进行比较判断是否可以使用缓存。
浏览器第一次请求数据时，服务器会将缓存标识与数据一起返回给客户端，客户端将二者备份至缓存数据库中。
再次请求数据时，客户端将备份的缓存标识发送给服务器，服务器根据缓存标识进行判断，判断成功后，**返回304状态码，通知客户端比较成功，可以使用缓存数据。**
**第一次访问：**
![](https://images2015.cnblogs.com/blog/632130/201702/632130-20170210141911682-1756976419.png)
**再次访问**
![](https://images2015.cnblogs.com/blog/632130/201702/632130-20170210141921697-379821074.png)

通过两图的对比，我们可以很清楚的发现，在对比缓存生效时，状态码为304，并且报文大小和请求时间大大减少。
原因是，服务端在进行标识比较后，只返回header部分，通过状态码通知客户端使用缓存，不再需要将报文主体部分返回给客户端。

对于对比缓存来说，缓存标识的传递是我们着重需要理解的，它在请求header和响应header间进行传递，
一共分为两种标识传递，接下来，我们分开介绍。

### Last-Modified  /  If-Modified-Since.

**Last-Modified**

服务器在响应请求时，告诉浏览器资源的最后修改时间。

![](https://images2015.cnblogs.com/blog/632130/201702/632130-20170210142249541-789089587.png)

**If-Modified-Since**
再次请求服务器时，通过此字段通知服务器上次请求时，服务器返回的资源最后修改时间。
服务器收到请求后发现有头If-Modified-Since 则与被请求资源的最后修改时间进行比对。
若资源的最后修改时间大于If-Modified-Since，说明资源又被改动过，则响应整片资源内容，返回状态码200；
若资源的最后修改时间小于或等于If-Modified-Since，说明资源无新修改，则响应HTTP 304，告知浏览器继续使用所保存的cache。

![](https://images2015.cnblogs.com/blog/632130/201702/632130-20170210142307166-135607673.png)

### Etag  /  If-None-Match（优先级高于Last-Modified  /  If-Modified-Since）

**Etag**
服务器响应请求时，告诉浏览器当前资源在服务器的唯一标识（生成规则由服务器决定）。
![](https://images2015.cnblogs.com/blog/632130/201702/632130-20170210142054182-1766818273.png)

Etag 的生成过程需要服务器额外付出开销，会影响服务端的性能，这是它的弊端。因此启用 Etag 需要我们审时度势。正如我们刚刚所提到的——Etag 并不能替代 Last-Modified，它只能作为 Last-Modified 的补充和强化存在。 **Etag 在感知文件变化上比 Last-Modified 更加准确，优先级也更高。当 Etag 和 Last-Modified 同时存在时，以 Etag 为准。**

**If-None-Match**
再次请求服务器时，通过此字段通知服务器客户段缓存数据的唯一标识。
服务器收到请求后发现有头If-None-Match 则与被请求资源的唯一标识进行比对，
不同，说明资源又被改动过，则响应整片资源内容，返回状态码200；
相同，说明资源无新修改，则响应HTTP 304，告知浏览器继续使用所保存的cache。
![](https://images2015.cnblogs.com/blog/632130/201702/632130-20170210142115479-1921175758.png)

### 既生Last-Modified何生Etag
HTTP1.1中Etag的出现主要是为了解决几个Last-Modified比较难解决的问题：
* 一些文件也许会周期性的更改，但是他的内容并不改变(仅仅改变的修改时间)，这个时候我们并不希望客户端认为这个文件被修改了，而重新GET；
* 某些文件修改非常频繁，比如在秒以下的时间内进行修改，(比方说1s内修改了N次)，If-Modified-Since能检查到的粒度是s级的，这种修改无法判断(或者说UNIX记录MTIME只能精确到秒)；
* 某些服务器不能精确的得到文件的最后修改时间。

这时，利用Etag能够更加准确的控制缓存，因为Etag是服务器自动生成或者由开发者生成的对应资源在服务器端的唯一标识符。

**Last-Modified与ETag是可以一起使用的，服务器会优先验证ETag，一致的情况下，才会继续比对Last-Modified，最后才决定是否返回304。**

## 用户的行为对缓存的影响
![](https://images2015.cnblogs.com/blog/408483/201605/408483-20160525202949975-1541314356.png)

## 强缓存如何重新加载缓存缓存过的资源
上面说到，使用强缓存时，浏览器不会发送请求到服务端，根据设置的缓存时间浏览器一直从缓存中获取资源，在这期间若资源产生了变化，浏览器就在缓存期内就一直得不到最新的资源，那么如何防止这种事情发生呢？

通过更新页面中引用的资源路径，让浏览器主动放弃缓存，加载新资源。

类似下图所示：
![](https://pic2.zhimg.com/8a8676e933478d1a73777d84a5de55f5_b.jpg)
这样每次文件改变后就会生成新的query值，这样query值不同，也就是页面引用的资源路径不同了，之前缓存过的资源就被浏览器忽略了，因为资源请求的路径变了。



## 总结

对于强制缓存，服务器通知浏览器一个缓存时间，在缓存时间内，下次请求，直接用缓存，不在时间内，执行比较缓存策略。
对于比较缓存，将缓存信息中的Etag和Last-Modified通过请求发送给服务器，由服务器校验，返回304状态码时，浏览器直接使用缓存。
**浏览器第一次请求**

![](https://images2015.cnblogs.com/blog/632130/201702/632130-20170210142134291-1976923079.png)

**浏览器再次请求时**

![](https://images2015.cnblogs.com/blog/632130/201702/632130-20170210141453338-1263276228.png)


我们可以在响应报文输出时指定头部   Expires:具体时间、或  Cache-Control:max-age=10  或  Etag  或  Last-modified 的方式去使浏览器缓存生效。

当浏览器发现响应报文有Expires或Cache-Control，即启用本地缓存；当发现有 Etag  或  Last-modified，则下次发送请求给服务器时，会带上对应的if-modified-Since 或 If-none-match首部去询问。

nginx的话，如果指定Expires指令，则它会在响应报文中添加Expires和Cache-Control:max-age。nginx默认给静态文件的响应会加上 Last-modified 首部，旧版的nginx不自动带上Etag，nginx认为使用Last-modified已经足够了，我也认为nginx在实际使用中意义差别不大。

**参考资料**

[掌握 HTTP 缓存——从请求到响应过程的一切（下）](https://zhuanlan.zhihu.com/p/25596667)
[浏览器的协商缓存与强缓存](http://caibaojian.com/browser-cache.html)
[彻底弄懂HTTP缓存机制及原理](https://www.cnblogs.com/chenqf/p/6386163.html)
[HTTP最强资料大全](https://juejin.im/post/58ddb636ac502e0063992865)
[前端缓存机制](https://juejin.im/post/5b0ea4f1518825155d66a97b)
[HTTP----HTTP缓存机制](https://juejin.im/post/5a1d4e546fb9a0450f21af23)

[一般·人生苦短，了解一下前端必须明白的http知识点](https://juejin.im/post/5b34e6ba51882574d20bbdd4)

[面试 -- 网络 HTTP](https://juejin.im/post/5872309261ff4b005c4580d4)
[前端跨域方法论](https://juejin.im/post/5b91d3be5188255c95380b5e)

![](http://static.zhyjor.com/wexin.png)
