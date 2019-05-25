---
title: 浏览器的数据存储方案之二：CacheObject（缓存）
tags:
  - 浏览器的数据存储方案
categories: 浏览器
top: false
copyright: true
date: 2018-07-19 10:36:33
---
Cache 虽然是在 SW 中定义的，但是我们也可以直接在 window 域下面直接使用它。它通过 Request/Response 流（就是 fetch）来进行内容的缓存。
<!--more-->

## 概览

每个域名可以有多个 Cache Object，具体我们可以在控制台中查看：

![](http://static.zhyjor.com/201807191037_507.png)

并且 Cache Object 是懒更新，实际上，就可以把它比喻为一个文件夹。如果你不自己亲自更新，系统是不会帮你做任何事情的。对于删除也是一样的道理，如果你不显示删除，它会一直存在的。不过，浏览器对于每个域名的 Cache Object 数量是有限制的，并且，会周期性的删掉一些缓存信息。最好的办法，是我们自己管理资源，官方给出的建议是: 使用版本号进行资源管理。

service worker中删除特定版本的缓存资源：
```js
self.addEventListener('activate', function(event) {
  var cacheWhitelist = ['v2'];

  event.waitUntil(
    caches.keys().then(function(keyList) {
      return Promise.all(keyList.map(function(key) {
        if (cacheWhitelist.indexOf(key) === -1) {
          return caches.delete(key);
        }
      }));
    })
  );
});
```
## Cache Object 操作相关方法
这里，我们就可以将 Cache Object 理解为一个持久性数据库，那么针对于数据库来说，简单的操作就是 CRUD。而 Cache Object 也提供了这几个接口，并且接口结果都是通过 Promise 对象返回的，成功返回对应结果，失败则返回 undefined:
### Cache.match
`Cache.match(request, options)`: 成功时，返回对应的响应流response。当然，查找的时候使用的是正则匹配，表示是否含有某个具体字段。
options:
* ignoreSearch[boolean]:是否忽略 querystring 的查找。即，我们查找的区域不包括 qs。比如: `http://foo.com/?value=bar`，我们不会再搜索 `?value=bar` 这几个字符。
* ignoreMethod[boolean]:当设置为 true 时，会防止 Cache 验证 http method，默认情况下，只有 GET 和 HEAD 能够通过。默认值为 false。
* ignoreVary[boolean]:当设置为 true 时，表示不对 vary 响应头做验证。即， Cache 只需要通过 URL 做匹配即可，不需要对响应头 vary 做验证。默认值为 false。
* cacheName[String]: 自己设置的缓存名字。一般用不到，match 会自动忽略。

```js
cache.match(request,{options}).then(function(response) {
  //do something with the response
});
```

### Cache.matchAll
Cache.matchAll(request, options): 成功时，返回一个数组，包含所有匹配到的响应流。options 和上面的一样，这里就不多说了。
```js
cache.matchAll(request,{options}).then(function(response) {
    response.forEach(function(element, index, array) {
      cache.delete(element);
    });
});
```

### Cache.add
Cache.add(url): 这实际上就是一个语法糖。fetch + put。即，它会自动的向路由发起请求，然后缓存获取到的内容。
```js
cache.add(url).then(function() {
  // 请求的资源被成功缓存
});

# 等同于
fetch(url).then(function (response) {
  if (!response.ok) {
    throw new TypeError('bad response status');
  }
  return cache.put(url, response);
})
.then(res=>{
    // 成功缓存
})
```

### Cache.addAll
Cache.addAll(requests):这个就是上面 cache.add 的 Promise.all 实现方式。接受一个 Urls 数组，然后发送请求，缓存上面所有的资源。

```js
this.addEventListener('install', function(event) {
  event.waitUntil(
    caches.open('v1').then(function(cache) {
      return cache.addAll([
        '/public/',
        '/public/index.html',
        '/public/style.css',
        '/public/app.js'
      ]);
    })
  );
});
```
### Cache.put
Cache.put(request, response): 将请求的资源以 req/res 键值对的形式进行缓存。如果，之前已经存在对应的 req（即，key 值），那么以前的值将会被新值覆盖。
```js
cache.put(request, response).then(function() {
  // 成功缓存
});
```

### Cache.delete
Cache.delete(request, options): 用来删除指定的 cache。如果你不删除，该资源会永远存在（除非电脑自动清理）。

### Cache.keys
Cache.keys(request, options): 返回当前缓存资源的所有 key 值。
```js
cache.keys().then(function(keys) {
    keys.forEach(function(request, index, array) {
      cache.delete(request);
    });
  });
```
可以查看到上面的参数都共同的用到了 request 这就是 fetch 套件里面的请求流，具体，可以参考一下前面的代码。上面所有方法都是返回一个 Promise 对象，用来进行异步操作。

上面简单介绍了一下 Cache Object，但**实际上，Cache 的管理方式是两级管理。即，最外层是 Cache Storage，下一层是 Cache Object。**

## Cache Storage
浏览器会给每个域名预留一个 Cache Storage（只有一个）。然后，剩下的缓存资源，全部都存在下面。我们可以理解为，这就是一个顶级缓存目录管理。而我们获取 Cache Object 的唯一途径，就是通过 caches.open() 进行获取。这里，我们就可以将 open 方法理解为 没有已经存在的 Cache Object 则新建，否则直接打开。它的相关操作方法也有很多：

### CacheStorage.match
CacheStorage.match(request,{options})：在所有的 Cache Object 中进行缓存匹配。返回值为 Promise
```js
caches.match(event.request).then(function(resp) {
  return resp || fetch(event.request).then(function(r) {
    caches.open('v1').then(function(cache) {
      cache.put(event.request, r);
    });
    return r.clone();
  });
});
```
### CacheStorage.has
CacheStorage.has(cacheName): 用来检查是否存在指定的 Cache Object。返回 Boolean 代表是否存在。
```js
caches.has('v1').then(function(hasCache) {
 // 检测是否存在 Cache Object Name 为 v1 的缓存内容
  if (!hasCache) {
    // 没存在
  } else {
    //...
  }
}).catch(function() {
  // 处理异常
});
```

### CacheStorage.open
CacheStorage.open(cacheName): 打开指定的 Cache Object。并返回 Cache Object。
```js
caches.open('v1').then(function(cache) {
    cache.add('/index.html');
  });  
```

### CacheStorage.delete
CacheStorage.delete(cacheName): 用来删除指定的 Cache Object，返回值为 Boolean:
```js
caches.delete(cacheName).then(function(isDeleted) {
  // 检测是否删除成功
});

# 通过,可以通过 Promise.all 的形式来删除多个 cache object
Promise.all(keyList.map(function(key) {
        if (cacheList.indexOf(key) === -1) {
          return caches.delete(keyList[i]);
        }
      });
```

### CacheStorage.keys
CacheStorage.keys(): 以数组的形式，返回当前 Cache Storage 保存的所有 Cache Object Name。

```js
event.waitUntil(
 caches.keys().then(function(keyList) {
      return Promise.all(keyList.map(function(key) {
        if (['v1','v2'].indexOf(key) === -1) {
          return caches.delete(keyList[i]);
        }
      });
    })
    );
```

上面就是关于 Cache Storage 的所有内容。

## Cache 匹配问题
Cache 上挂载的匹配方法，对于资源的搜索是针对 RequestInfo 对象。该对象的描述内容为：
```js
type RequestInfo = Request | string;

declare var Request: {
    prototype: Request;
    new(input: Request | string, init?: RequestInit): Request;
};
```
通过某些方法 delete、match 搜索缓存时，可以传入 string。例如：
```js
cache.delete('/images/image.png').then(function(response) {
    someUIUpdateFunction();
  });
```
但是，你存储的时候，往往存储的是 Request 对象，这就造成了一个差异点。什么样的 string 能够匹配对象的 Request 内容呢？

这里，我们可以从 delete 方法的 CacheQueryOptions 入手。

```js
interface CacheQueryOptions {
    cacheName?: string;
    ignoreMethod?: boolean | false;
    ignoreSearch?: boolean | false;
    ignoreVary?: boolean | false;
}
```
我们传入一个正常 url 给 delete 方法后。内核底层实际上，会针对该 string 生成一个 request 对象。默认转化为：

```js
https://www.villainhr.com/styles/article.css?_bid=31133

// 转化为 fake-Reqeust
{
    url: "https://www.villainhr.com/styles/article.css?_bid=31133",
    method:"get",
    vary:""
}
```
然后以此进行匹配。直接用代码来作一份试例,[可参考](https://developer.mozilla.org/en-US/docs/Web/API/Cache/delete)：
```js
let cache = await this.open();

await cache.add("https://www.villainhr.com/styles/article.css?_bid=31133")


# 成功匹配
let res_no_search = await cache.match("https://www.villainhr.com/styles/article.css",{
            ignoreSearch:true
        });

# 成功匹配
let res_with_hash = await cache.match("https://www.villainhr.com/styles/article.css#test",{
            ignoreSearch:true
        })
```



**参考资料**
[Service Worker 全面进阶](https://www.villainhr.com/page/2017/01/08/Service%20Worker%20%E5%85%A8%E9%9D%A2%E8%BF%9B%E9%98%B6)

![](http://static.zhyjor.com/wexin.png)
