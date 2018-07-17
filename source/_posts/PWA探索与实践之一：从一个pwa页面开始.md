---
title: PWA探索与实践之一：从一个pwa页面开始
tags:
  - PWA探索与实践
  - PWA
categories: 前端
top: false
copyright: true
date: 2017-05-06 23:30:06
---
pwa关系到未来前端的方向，对于提高webapp的性能与体验有着很重大的意义。本系列从一个简单的pwa页面开始，到最后完成一个知乎日报web端的开发。现在微博据说已经[全量上了pwa](https://m.weibo.cn/)
<!--more-->
## 什么是 PWA
Progressive Web App, 简称 PWA，是提升 Web App 的体验的一种新方法，能给用户原生应用的体验。

PWA 能做到原生应用的体验不是靠特指某一项技术，而是经过应用一些新技术进行改进，在安全、性能和体验三个方面都有很大提升，PWA 本质上是 Web App，借助一些新技术也具备了 Native App 的一些特性，兼具 Web App 和 Native App 的优点。

对于webapp的痛点相信很多开发者都是知道的。除了性能差距，推送、入口无法通过传统的方式解决。PWA 的主要特点包括下面三点：
* 可靠 - 即使在不稳定的网络环境下，也能瞬间加载并展现
* 体验 - 快速响应，并且有平滑的动画响应用户的操作
* 粘性 - 像设备上的原生应用，具有沉浸式的用户体验，用户可以添加到桌面

其实理解起来就是就是可以在设备上有缓存，在弱网条件下也可以打开应用，而且可添加到桌面，不用每次都进入浏览器，输入网址或者通过书签打开应用；而且可以进行消息的推送。

这些功能都是怎么实现的？其实这不是通过一种技术实现的，而是通过一系列技术实现的。随着移动端的崛起，pwa的前景也更加明确。

## 实现PWA需要什么

### 离线和缓存
“站点可以秒开，离线的情况下也可以正常浏览”，这对前端是很有诱惑的。这里的实现需要一个名为Service Worker的东西
#### Service Worker
浏览器中的 javaScript 都是运行在一个单一主线程上的，在同一时间内只能做一件事情。随着 Web 业务不断复杂，我们逐渐在 js 中加了很多耗资源、耗时间的复杂运算过程，这些过程导致的性能问题在 WebApp 的复杂化过程中更加凸显出来。

这个时候有个叫 Web Worker 的 API 被造出来了，这个 API 的唯一目的就是解放主线程，Web Worker 是脱离在主线程之外的，将一些复杂的耗时的活交给它干，完成后通过 postMessage 方法告诉主线程，而主线程通过 onMessage 方法得到 Web Worker 的结果反馈。

Service Worker 在 Web Worker 的基础上加上了持久离线缓存能力。当然在 Service Worker 之前也有在 HTML5 上做离线缓存的 API 叫 AppCache。 但是 AppCache 存在很多 不能忍受的缺点。

Service Worker 有以下功能和特性：
* 一个独立的 worker 线程，独立于当前网页进程，有自己独立的 worker context。
* 一旦被 install，就永远存在，除非被手动 unregister
* 用到的时候可以直接唤醒，不用的时候自动睡眠
* 可编程拦截代理请求和返回，缓存文件，缓存的文件可以被网页进程取到（包括网络离线状态）
* 离线内容开发者可控
* 能向客户端推送消息
* 不能直接操作 DOM
* 必须在 HTTPS 环境下才能工作
* 异步实现，内部大都是通过 Promise 实现

所以我们基本上知道了 Service Worker 的伟大使命，就是让缓存做到优雅和极致，让 Web App 相对于 Native App 的缺点更加弱化，也为开发者提供了对性能和体验的无限遐想。Service Worker 相当于浏览器和网络之间的代理服务器，可以拦截网络请求，做一些你可能需要的处理(请求资源从缓存中获取等)。

#### 缓存
其实这个就是 我们平时做的 Session 啊、localStorage、CacheStorage 之类的。这里用的就是 cacheStorage 缓存，它提供了一个ServiceWorker类型的工作者或window范围可以访问的所有命名缓存的主目录, 并维护字符串的映射名称到相应的 Cache 对象。 主要方法包括：

![](http://oankigr4l.bkt.clouddn.com/201807171518_937.png)

有了这些方法你可以对你的缓存进行操作。目前还在草案状态，仅火狐和谷歌浏览器支持此特性。

PWA是通过 ServiceWorker 访问 cache ,所以需要注册 ServiceWorker 工作者。在之前别忘记判断浏览器是否支持。
```js
if ('serviceWorker' in navigator) {
    window.addEventListener('load', function () {
        navigator.serviceWorker.register('/sw.js', {scope: '/'})
            .then(function (registration) {

                // 注册成功
                console.log('ServiceWorker registration successful with scope: ', registration.scope);
            })
            .catch(function (err) {

                // 注册失败:(
                console.log('ServiceWorker registration failed: ', err);
            });
    });
}
```

#### sw创建缓存
关于 sw.js 中具体的缓存的代码：

创建需要缓存的文件
```js
'use strict'
let cacheName = 'pwa-demo-assets'; // 缓存名字
let imgCacheName = 'pwa-img';
let filesToCache;
filesToCache = [ // 所需缓存的文件
    '/',
    '/index.html',
    '/scripts/app.js',
    '/assets/imgs/48.png',
    '/assets/imgs/96.png',
    '/assets/imgs/192.png',
    '/dist/js/app.js',
    '/manifest.json'
];

self.addEventListener('install', function(e) {
    e.waitUntil(
	    // 安装服务者时，对需要缓存的文件进行缓存
        caches.open(cacheName).then(function(cache) {
            return cache.addAll(filesToCache);
        })
    );
});


self.addEventListener('fetch', (e) => {
    // 判断地址是不是需要实时去请求，是就继续发送请求
    if (e.request.url.indexOf('/api/400/200') > -1) {
        e.respondWith(
            caches.open(imgCacheName).then(function(cache){
                 return fetch(e.request).then(function (response){
                    cache.put(e.request.url, response.clone()); // 每请求一次缓存更新一次新加载的图片
                    return response;
                });
            })
        );
    } else {
        e.respondWith(
	        // 匹配到缓存资源，就从缓存中返回数据
            caches.match(e.request).then(function (response) {
                return response || fetch(e.request);
            })
        );
    }

});

```


#### 小结
Service Worker 出于安全性和其实现原理，在使用的时候有一定的前提条件。

* 由于 Service Worker 要求 HTTPS 的环境，我们通常可以借助于 github page 进行学习调试。当然一般浏览器允许调试 Service Worker 的时候 host 为 localhost 或者 127.0.0.1 也是 ok 的。
* Service Worker 的缓存机制是依赖 Cache API 实现的
* 依赖 HTML5 fetch API
* 依赖 Promise 实现


### 推动的实现
基本原理是，你的客户端要和推送服务进行绑定，会生成一个绑定后的推送服务 API 接口，服务端调用此接口，发送消息。同时，浏览器也要支持推送功能，在注册 sw 时, 加上推送功能的判断。这都是通过 ServiceWorker 去实现的。
```js
if ('serviceWorker' in navigator && 'PushManager' in window) {
	navigator.serviceWorker.register(sw.js)
	.then(function(swReg) {
        swRegistration = swReg;
    }).catch(function(error) {
        console.error('Service Worker Error', error);
        });
 } else {
     console.warn('Push messaging is not supported');
 }

```
PushManager 注册好之后， 那么要做的就是浏览器和服务器的绑定了。

![](http://oankigr4l.bkt.clouddn.com/201807171526_525.png)

此图是用户订阅某个应用程序的推送服务。
客户端传入应用程序服务器公钥，向将生成端点的 webpush 服务器( 这是谷歌自己实现的一个推送功能的服务器)发出网络请求，将生成的端点(一个推送服务)与应用程序公钥关联，并将端点返回给应用程序。浏览器会将此端点添加到 PushSubscription，通过 promise异步成功时，可以将它的信息保存到你的数据库。

![](http://oankigr4l.bkt.clouddn.com/201807171527_309.png)

服务器发送推送的时候,请求相关接口，验证成功后推送服务会发消息给客户端。如果你要自己实现推送，自己服务器要有公钥和私钥的获取， 这里可以通过 `https://web-push-codelab.glitch.me` 获取， 用 chrome 的 webpush 推送。

### 添加到桌面
一个 manifest.json 配置文件，然后在页面引入此文件就好了
```js
<!-- 加载清单 -->
<link rel="manifest" href="./manifest.json">

```
内容如下：
```json
{
    "short_name": "pwa",
    "name": "pwa - demo", // 应用名称
    "icons": [ // 应用显示图标，根据容器大小适配
        {
            "src": "assets/imgs/48.png",
            "type": "image/png",
            "sizes": "48x48"
        },
        {
            "src": "assets/imgs/96.png",
            "type": "image/png",
            "sizes": "96x96"
        },
        {
            "src": "assets/imgs/192.png",
            "type": "image/png",
            "sizes": "192x192"
        }
    ],
    "background_color": "#2196F3", // 刚打开页面时的背景
    "theme_color": "#2196F3", // 主题颜色
    "display": "standalone", //独立显示
    "start_url": "index.html?launcher=true" // 启动的页面
}

```

这时通过chrome的“创建快捷方式”就可以将图标放到桌面了。

## 总结
这个时候，我们[**第一个pwa的项目**](https://github.com/zhyjor/first-pwa-page)也就出来了,就是一个页面。我们启动node服务，打开页面，可以将其添加到桌面上。而且这个时候，当我们停掉node服务后，刷新页面，页面就是通过缓存打开的。这个时候假如用chrome的`ctrl+F5`刷新页面，就会发现页面离线了，这个时候因为我们已经将缓存删除了。

我们已经可以发现pwa实现的核心就是service worker的功能实现，这个会在接下来的文章中重点说明。


**参考资料**
[Lavas 是一套基于 Vue 的 PWA 解决方案](https://lavas.baidu.com/guide)
[第一本 PWA 中文书](https://juejin.im/entry/5a1c394a5188255851326da5)
[PWA超简单入门](https://juejin.im/post/5abba6a7f265da239706ec60)
[知乎日报 API 分析(如何规范api设计)](https://blog.csdn.net/h330531987/article/details/78726635)
[一个知乎日报pwa](https://yiweifen.com/html/news/WaiYu/121591.html)
[一个知乎日报pwa](https://www.jianshu.com/p/f48d5ed0ba91)
[《PWA技术学习与实践》系列文章](https://juejin.im/post/5ac8a67c5188255c5668b0b8)
[当vue遇到pwa--vue+pwa移动端适配解决方案模板案例](https://juejin.im/post/5af264296fb9a07aa54248f9)
[什么是 PWA](https://juejin.im/post/5a9e8ad5f265da23a40456d4)

[**PWA超简单入门**](https://juejin.im/post/5abba6a7f265da239706ec60)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)