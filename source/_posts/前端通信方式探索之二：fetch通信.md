---
title: 前端通信方式探索之二：fetch通信
tags:
  - 前端通信方式探索
  - 前端通信
categories: 前端通信
top: false
copyright: true
date: 2017-05-09 13:42:20
---
随着前端异步的发展, XHR 这种耦合方式的书写不利于前端异步的 Promise 回调. 而且,写起来也是很复杂. fetch API 本来是在 SW(ServiceWorkers) 中提出的, 不过, 后面觉得好用, 就把他挂载到 window 对象下. 这样, 在前端的正常通信中, 我们也可以直接调用. 
<!--more-->

## 兼容性
作为一个未来常用的api,看一下他的兼容性.

![](http://oankigr4l.bkt.clouddn.com/201807191627_156.png)

在 PC 端上, 就 FF, Opera 和 Chrome 比较 fashion. mobile 的话, 基本上是不能用的. 当然, 官方已经有一个现成的 [polyfill](https://github.com/github/fetch) 可以使用。

Chrome 45+， Opera 44+，Firefox 51+ 和 IE Edge 等这些版本的浏览器开始支持 Fetch API。移动端浏览器也在逐步得到支持。

我们可以通过对 window.fetch 的能力检测，判断出浏览器是否支持 Fetch API。github 官方推出了一个 Fetch API 的 polyfill 库，可以让更多浏览器提前感受到 Fetch API 的便捷的开发体验。

一般一个新的feature的使用需要判断兼容性，这块可以参考一下[ Modernizr 这个库](https://modernizr.com/)。

## 基本使用
可以说, fetch 就是 ajax + Promise. 使用的方式和 jquery 提供的 $.ajax() 差不多.
```js
fetch('http://wthrcdn.etouch.cn/weather_mini?citykey=101010100')
    .then(function (response) {
            if (response.status !== 200) {
                console.log(`返回的响应码${response.status}`)
                return
            }

            // 获取返回数据
            response.json().then(function (data) {
                document.body.innerText = data.toString()
                console.log(data)
            })
        }
    ).catch(function (err) {
    console.log('Fetch Error: -S', err)
})
```
then 和 catch 是 promise 自带的两个方法, 我这里就不多说了. 我们来看一下,json 是干嘛的.

因为返回回来的数据不仅仅包括后台的返回的 Text 内容, 还有一些 Headers. 所以在, then 方法里面返回来的 res 实际上并不是我们在业务中想要的内容. 就和在 XHR 里返回数据是一个道理, 我们最终要的是 responseText 这个数据. 而 json() 方法实际做的事情,就是调用 JSON.parse() 处理数据, 并且返回一个新的 Promise. 看一下 polyfill 源码就应该了解.

```js
this.json = function() {
    return this.text().then(JSON.parse)
}
```
这里需要注意的是，fetch 中的 response/request 都是 [stream 对象](https://streams.spec.whatwg.org/)。


## fetch 传输格式
上面的 demo 是一个 get 方法的请求, 当然, 除了 get , 还有其他的 HTTP Method, PUT, DELETE, POST, PATCH 等. 这里, 我们就说一个 POST, 其他方法的基本格式还是类似的.
```js
fetch("http://www.example.org/submit.php", {
  method: "POST",
  headers: {
    "Content-Type": "application/x-www-form-urlencoded"
  },
  body: "this is a post Msg"
}).then(function(res) {
  if (res.ok) {
    // doSth
  } else if (res.status == 401) {
    // doSth
  }
});
```
看起来 fetch 和 $.ajax 并没有多大的区别… but… fetch 里面的内容,真不少. 往底层看一看, fetch 实际上是 Request,Headers,Response 3个接口的整合. 不过, 这3个只能在 SW 里面使用. 这里当做原理,参数一下即可.

### Headers 操作
Headers 的操作无非就是 CRUD, 这里我就不过多赘述,直接看代码吧:
```js
var content = "Hello World";
var reqHeaders = new Headers();
reqHeaders.append("Content-Type", "text/plain"
reqHeaders.append("Content-Length", content.length.toString());
reqHeaders.append("X-Custom-Header", "自定义头");
```
当然, 你也可以使用字面量的形式:
```js
reqHeaders = new Headers({
  "Content-Type": "text/plain",
  "Content-Length": content.length.toString(),
  "X-Custom-Header": "自定义头",
});
```
接下来就是, 头部的内容的检测相关.
```js
console.log(reqHeaders.has("Content-Type")); // true
console.log(reqHeaders.has("Set-Cookie")); // false
reqHeaders.set("Content-Type", "text/html");
reqHeaders.append("X-Custom-Header", "新增自定义头");
 
console.log(reqHeaders.get("Content-Length")); // 11
console.log(reqHeaders.getAll("X-Custom-Header")); // ["自定义头", "新增自定义头"]
 
reqHeaders.delete("X-Custom-Header");
console.log(reqHeaders.getAll("X-Custom-Header")); // []
```
不过, 鉴于安全性的考虑, 有时候在多人协作或者子版块管理时, 对于头部的限制还是需要的. 这里, 我们可以通过 guard 属性, 设置 Headers 的[相关策略](https://fetch.spec.whatwg.org/#headers). guard 通常可以取 “immutable”, “request”, “request-no-cors”, “response”, “none”. 我们这里不探讨全部, 仅仅看一下 request 这个选项. 当你设置了 request 之后, 如果你设置的 Header 涉及到 forbidden header name (这个是浏览器自动设置的), 那么该次操作是不会成功的. forbidden header name 通常有:
Accept-Charset，Accept-Encoding，Access-Control-Request-Headers等。

对比与 fetch, 我们没有办法去设置 Headers的 guard, 所以, 这只能在 SW 里使用.

### Request 操作
Request 的基本用法和 fetch 差不多.
```js
var uploadReq = new Request("/uploadImage", {
  method: "POST",
  headers: {
    "Content-Type": "image/png",
  },
  body: "image data"
});

fetch("/uploadImage", {
  method: "POST",
  headers: {
    "Content-Type": "image/png",
  },
  body: "image data"
});
```
那 fetch 有什么用呢？ 关键的地方在于，fetch 实际上就是 request/reponse 的容器，request/response 相当于就是两个元数据，fetch 只是实际进行的操作。所以，为了达到更高的复用性，我们可以 ajax 的请求，实例化为一个个具体的对象。
```js
var getName = new Request(...,{//...});
var getGender = new Request(...,{//...});

// 发送请求
fetch(getName)
.then((res)=>{});

fetch(getGender)
.then((res)=>{});
```
在浏览器里, 一切请求都逃不过跨域和不跨域的问题. fetch 也是. 对于跨域的请求, 主要的影响还是体现在 Response 中, 这 fetch Request 这, 没多大影响. 不过, 我们需要在 fetch 设置 mode 属性, 来表示这是一个跨域的请求.
```js
fetch('https://www.villainhr.com/cors-enabled/some.json', {mode: 'cors'})  
  .then(function(response) {  
    return response.text();  
  }) 
```
常用的 mode 属性值有:
* same-origin: 表示只请求同域. 如果你在该 mode 下进行的是跨域的请求的话, 那么就会报错.
* no-cors: 正常的网络请求, 主要应对于没有后台没有设置 Access-Control-Allow-Origin. 就是用来处理 script, image 等的请求的. 他是 mode 的默认值.
* cors: 用来发送跨域的请求. 在发送请求时, 需要带上.
* cors-with-forced-preflight: 这是专门针对 xhr2 支持出来的 preflight，会事先多发一次请求给 server，检查该次请求的合法性。

另外, 还有一个关于 cookie 的跨域内容. 在 XHR2 中,我们了解到, withCredentials 这个属性就是用来设置在进行跨域操作时, 对不同域的 Server 是否发送本域的 cookie. 一般设置为 omit(不发送). 在 fetch 当中, 使用的是 credentials 属性. credentials 常用取值为:
* omit: 发送请求时,不带上 cookie. 默认值.
* same-origin: 发送同域请求时,会带上 cookie.
* include: 只要发送请求,都会带上 cookie.

所以, 如果你想发送 ajax 时, 带上 cookie, 那么你就需要使用 same-origin, 如果想在跨域时也带上 cookie, 那么就需要 include.

```js
// 跨域请求
fetch('https://www.villainhr.com/cors-enabled/some.json', {mode: 'cors',credentials:'include'})  
  .then(function(response) {  
    return response.text();  
  }) 
```

### Response 操作
response 应该算和 fetch 最为接近的一个对象. Response 的实际其实就是 fetch 回调函数传回的参数. Response 中比较常用的属性有四个: status, statusText, ok, type.
* status: 返回的状态码. 100~500+
* statusText: 返回状态码代表的含义. 比如, 返回"ok".
* ok: 用来检差 status 是否在200和299之间.
* type: 表示请求是否跨域, 或是否出错. 取值为: “basic”, “cors”, “default”, “error” 或 “opaque”.

```js
fetch('https://www.villainhr.com/cors-enabled/some.json', {mode: 'cors',credentials:'include'})  
  .then(function(response) {  
    // ...
  }) 
```
这里, 我们主要关心一下 type 上面挂载的一些属性.
* basic: 同域通信类别. 可以正常的访问 response 的 header(除了 Set-Cookie 头).
* cors: 跨域通信类别. 一般只能访问以下的头:
 * Cache-Control
 * Content-Language
 * Content-Type
 * Expires
 * Last-Modified
 * Pragma
* error: 网络错误类别.
* opaque: 无法理解类别. 当使用 no-cors 发送跨域请求时,会触发.

另外,在 response 上面,还挂载了几个常用的方法: text(),json().

* text(): 主要用来处理 server 返回的 string 类型数据.
* josn(): 主要用来处理 server 返回的 json 类型数据.

使用方式都是流式 API.
```js
fetch('https://www.villainhr.com/cors-enabled/some.json')  
  .then(function(res) {  
    res.text().then((text)=>{...})
    res.json().then((obj)=>{...})
  }) 
```
## body 处理
我们通过 ajax 请求数据时，可能会收到，ArrayBuffer，Blob/File，string，FormData 等等。并且，在发送的时候比如：
```js
var form = new FormData(document.getElementById('login-form'));
fetch("/login", {
  method: "POST",
  body: form
})
```
fetch 会自动设置相关的 Content-Type 的头。另外，如果我们可以手动生成一个响应流（方便后面其他操作）。

```js
var res = new Response(new File(["chunk", "chunk"], "archive.zip",{ type: "application/zip" }));

```
### 流的处理
因为，req/res 都是以流的形式存在的，即，req/res 的 body 只能被使用一次。相当于就是一个文件从缓存读到硬盘里面，那么原来文件就已经消失了。我们可以通过 bodyUsed 去检查，该对象是否已经被使用。
```
var res = new Response("one time use");
console.log(res.bodyUsed); // false
res.text().then(function(v) {
  console.log(res.bodyUsed); // true
});
console.log(res.bodyUsed); // true
 
res.text().catch(function(e) {
  console.log("Tried to read already consumed Response");
});
```
这样做的原因主要是为了让以后 Web 更好的处理视频的相关数据。那如果我有时候想要使用多次，那该怎么办？ 例如，我们 Service Worker 中，使用 caches API 缓存响应，然后后面我还要将该响应返回给浏览器，那么这里 response 流就被使用了两次。这里，就和普通的流操作一样，将该流克隆一份，使用:
```js
addEventListener('fetch', function(evt) {
  var sheep = new Response("Dolly");
  console.log(sheep.bodyUsed); // false
  var clone = sheep.clone();
  console.log(clone.bodyUsed); // false
 
  clone.text();
  console.log(sheep.bodyUsed); // false
  console.log(clone.bodyUsed); // true
 
  evt.respondWith(cache.add(sheep.clone()).then(function(e) {
    return sheep;
  });
});
```

## 总结
虽然 Fecth API 使用方便符合语义化，但是现阶段它也有所限制。Fetch API 是基于 Promise，由于 Promise 没有处理 timeout 的机制，所以无法通过原生方式处理请求超时后的中断，和读取进度的能力。但是相信未来为了支持流，Fetch API 最终将会提供可以中断执行读取资源的能力，并且提供可以读取进度的 API。

**参考资料**
[前端 fetch 通信](https://www.villainhr.com/page/2016/09/25/%E5%89%8D%E7%AB%AF%20fetch%20%E9%80%9A%E4%BF%A1)
[This API is so Fetching!](https://hacks.mozilla.org/2015/03/this-api-is-so-fetching/)
[introduction-to-fetch](https://developers.google.com/web/updates/2015/03/introduction-to-fetch)
[传统 Ajax 已死，Fetch 永生](https://github.com/camsong/blog/issues/2)
[了解 Fetch API](https://aotu.io/notes/2017/04/10/fetch-API/)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)