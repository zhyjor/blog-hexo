---
title: 前端进阶er会遇到的问题
tags:
  - 面试
categories: 前端
top: false
copyright: true
date: 2018-10-12 08:50:51
---
遇到的一些常见的问题的总结，大概记录一下，查漏补缺
<!--more-->
## js
### es6
### js基础

## css
### 常见布局

## 浏览器
浏览器的渲染
响应式页面怎么做

## 框架
### vue

### jquery

## http
### 缓存
### https
### 常见状态码
### http2.0

## 优化

## html

###  html语义化的理解，有什么好处
根据内容的结构化（内容语义化），选择合适的标签（代码语义化）便于开发者阅读和写出更优雅的代码的同时让浏览器的爬虫和机器很好地解析。 注意：
1.尽可能少的使用无语义的标签div和span；
2.在语义不明显时，既可以使用div或者p时，尽量用p,
因为p在默认情况下有上下间距，对兼容特殊终端有利；
3.不要使用纯样式标签，如：b、font、u等，改用css设置。
4.需要强调的文本，可以包含在strong或者em标签中（浏览器预设样式，能用CSS指定就不用他们），strong默认样式是加粗（不要用b），em是斜体（不用i）；
5.使用表格时，标题要用caption，表头用thead，主体部分用tbody包围，尾部用tfoot包围。表头和一般单元格要区分开，表头用th，单元格用td；
6.表单域要用fieldset标签包起来，并用legend标签说明表单的用途；
7.每个input标签对应的说明文本都需要使用label标签，并且通过为input设置id属性，在lable标签中设置for=someld来让说明文本和相对应的input关联起来。


## CSS
### 盒模型
ie盒模型算上border、padding及自身（不算margin），标准的只算上自身窗体的大小 css设置方法如下
```
/* 标准模型 */
box-sizing:content-box;
 /*IE模型*/
box-sizing:border-box;
```

### css优先级确定
* 每个选择器都有权值，权值越大越优先
* 继承的样式优先级低于自身指定样式
* ！important优先级最高 js也无法修改
* 权值相同时，靠近元素的样式优先级高 顺序为内联样式表（标签内部）> * 内部样式表（当前文件中）> 外部样式表（外部文件中）

### CSS实现水平垂直居中
仅居中元素定宽高适用

* absolute + 负margin
* absolute + margin auto
* absolute + calc

居中元素不定宽高
* absolute + transform
* lineheight
* writing-mode
* table
* css-table
* flex
* grid

### 如何清除浮动,为什么要清除
不清除浮动会发生高度塌陷：浮动元素父元素高度自适应（父元素不写高度时，子元素写了浮动后，父元素会发生高度塌陷）

* clear清除浮动（添加空div法）在浮动元素下方添加空div,并给该元素写css样式：   {clear:both;height:0;overflow:hidden;}
* 给浮动元素父级设置高度
* 父级同时浮动（需要给父级同级元素添加浮动）
* 父级设置成inline-block，其margin: 0 auto居中方式失效
* 给父级添加overflow:hidden 清除浮动方法
* 万能清除法 after伪类 清浮动（现在主流方法，推荐使用）


## js
### 什么是立即执行函数？使用立即执行函数的目的是什么？为什么立即执行函数可以立即执行
常见两种方式
```
1.(function(){...})()
  (function(x){
	  console.log(x);
  })(12345)
2.(function(){...}())
  (function(x){
	  console.log(x);
  }(12345))
```
作用 不破坏污染全局的命名空间，若需要使用，将其用变量传入如
（function(window){...}(window)）

正常的js解析器遇到圆括号会当成表达式来执行，所以可以立即执行。

### 什么是NaN？它的类型是什么？如何可靠地测试一个值是否等于NaN？
NaN属性表示“不是数字”的值。这个特殊值是由于一个操作数是非数字的（例如“abc”/ 4）或者因为操作的结果是非数字而无法执行的。

虽然这看起来很简单，但NaN有一些令人惊讶的特征，如果人们没有意识到这些特征，就会导致bug。

一方面，虽然NaN的意思是“不是数字”，但它的类型是，数字：
```
console.log(typeof NaN === "number"); // logs "true"
```
测试数字是否等于NaN的半可靠方法是使用内置函数isNaN()，但即使使用 isNaN()也不是一个好的解决方案。

此外，NaN相比任何事情 - 甚至本身！ - 是false：
```
console.log(NaN === NaN); // logs "false"
```

一个更好的解决方案要么是使用value!==value，如果该值等于NaN，那么只会生成true。另外，ES6提供了一个新的Number.isNaN()函数 ，它与旧的全局isNaN()函数不同，也更加可靠。

### Promise的原理
在Promise的内部，有一个状态管理器的存在，有三种状态：pending、fulfilled、rejected。　　　　
(1) promise 对象初始化状态为 pending。　　　　
(2) 当调用resolve(成功)，会由pending => fulfilled。　　　　
(3) 当调用reject(失败)，会由pending => rejected。

**promise.race()**方法也可以处理一个promise实例数组但它和**promise.all()**不同，从字面意思上理解就是竞速，那么理解起来上就简单多了，也就是说在数组中的元素实例那个率先改变状态，就向下传递谁的状态和异步结果。但是，其余的还是会继续进行的。



## http
### http中的状态码302代表的是什么意思
302重定向表示临时性转移(Temporarily Moved )，当一个网页URL需要短期变化时使用。

301重定向/跳转一般，表示本网页永久性转移到另一个地址。    

301是永久性转移(Permanently Moved),SEO常用的招式，会把旧页面的PR等信息转移到新页面301重定向与302重定向的区别   301重定向是永久的重定向，搜索引擎在抓取新内容的同时也将旧的网址替换为重定向之后的网址。  
302重定向是临时的重定向，搜索引擎会抓取新的内容而保留旧的网址。因为服务器返回302代码，搜索引擎认为新的网址只是暂时的。

### 缓存
* Expires在http1.0中使用，与服务器时间有误差，在1.1中由Cache-control替代

### Cookie sessionStorage localStorage
共同点：都是保存在浏览器端，且同源的。

区别：
* cookie数据始终在同源的http请求中携带，即cookie在浏览器和服务器间来回传递。而sessionStorage和localStorage不会自动把数据发给服务器，仅在本地保存。
* cookie数据不能超过4k(适合保存小数据)。sessionStorage和localStorage容量较大
* 数据有效期不同sessionStorage：仅在当前浏览器窗口关闭前有效。localStorage：始终有效，窗口或浏览器关闭也一直保存，需手动清楚；cookie只在设置的cookie过期时间之前一直有效，即使窗口或浏览器关闭。
* 作用域不同。sessionStorage不在不同的浏览器窗口中共享；localStorage 在所有同源窗口中都是共享的；cookie也是在所有同源窗口中都是共享的。
* 应用场景：localStorage：常用于长期登录（+判断用户是否已登录），适合长期保存在本地的数据。sessionStorage ：敏感账号一次性登录； cookies与服务器交互。

## dom
### 请描述dom事件的流程，即从触发到结束的整个过程
事件流包括三个阶段:事件捕获阶段、处于目标阶段和事件冒泡阶段。首先发生的是事件捕获，

为截获事件提供了机会。然后是实际的目标接收到事件。最后一个阶段是冒泡阶 段，可以在这个阶段对事件做出响应。单击`<div>`元素会按照如下图：
![](http://static.zhyjor.com/201809141647_927.png)

### script标签到defer和async属性有什么作用和区别
async属性，表示后续文档的加载和渲染与js脚本的加载和执行是并行进行的，即异步执行。defer属性，加载后续文档的过程和js脚本的加载(此时仅加载不执行)是并行进行的(异步)，js脚本的执行需要等到文档所有元素解析完成之后，DOMContentLoaded事件触发执行之前。

区别：

* defer和async在网络加载过程是一致的，都是异步执行的；
* .两者的区别在于脚本加载完成之后何时执行，defer更符合大多数场景对应用脚本加载和执行的要求；
* 如果存在多个有defer属性的脚本，那么它们是按照加载顺序执行脚本的；而对于async，它的加载和执行是紧紧挨着的，无论声明顺序如何，只要加载完成就立刻执行，它对于应用脚本用处不大，因为它完全不考虑依赖。


## 安全

### XSS
跨网站指令码（英语：Cross-site scripting，通常简称为：XSS）是一种网站应用程式的安全漏洞攻击，是代码注入的一种。它允许恶意使用者将程式码注入到网页上，其他使用者在观看网页时就会受到影响。这类攻击通常包含了 HTML 以及使用者端脚本语言。

**XSS 分为三种：反射型，存储型和 DOM-based**

**最普遍的做法是转义输入输出的内容，对于引号，尖括号，斜杠进行转义**

### 什么是CSRF攻击，如何预防
跨站请求伪造（英语：Cross-site request forgery），也被称为 one-click attack 或者 session riding，通常缩写为 CSRF 或者 XSRF， 是一种挟制用户在当前已登录的Web应用程序上执行非本意的操作的攻击方法。

简单点说，CSRF 就是利用用户的登录态发起恶意请求。

**如何防御**
Get 请求不对数据进行修改
不让第三方网站访问到用户 Cookie
阻止第三方网站请求接口
请求时附带验证信息，比如验证码或者 token

### 密码安全
对于密码存储来说，必然是不能明文存储在数据库中的，否则一旦数据库泄露，会对用户造成很大的损失。并且不建议只对密码单纯通过加密算法加密，因为存在彩虹表的关系。

通常需要对密码加盐，然后进行几次不同加密算法的加密。

## 浏览器
### 什么是跨域，如何解决

因为浏览器出于安全考虑，有同源策略。也就是说，如果协议、域名或者端口有一个不同就是跨域，Ajax 请求会失败。

我们可以通过以下几种常用方法解决跨域的问题
* JSONP，JSONP 使用简单且兼容性不错，但是只限于 get 请求。
* CORS，服务端设置 Access-Control-Allow-Origin 就可以开启 CORS。 该属性表示哪些域名可以访问资源，如果设置通配符则表示所有网站都可以访问资源。
* document.domain ，该方式只能用于二级域名相同的情况下，比如 a.test.com 和 b.test.com 适用于该方式。
* postMessage 这种方式通常用于获取嵌入页面中的第三方页面数据。一个页面发送消息，另一个页面判断来源并接收消息

### Event loop
众所周知 JS 是门非阻塞单线程语言，因为在最初 JS 就是为了和浏览器交互而诞生的。如果 JS 是门多线程的语言话，我们在多个线程中处理 DOM 就可能会发生问题（一个线程中新加节点，另一个线程中删除节点），当然可以引入读写锁解决这个问题。

JS 在执行的过程中会产生执行环境，这些执行环境会被顺序的加入到执行栈中。如果遇到异步的代码，会被挂起并加入到 Task（有多种 task） 队列中。一旦执行栈为空，Event Loop 就会从 Task 队列中拿出需要执行的代码并放入执行栈中执行，所以本质上来说 JS 中的异步还是同步行为。

不同的任务源会被分配到不同的 Task 队列中，任务源可以分为 微任务（microtask） 和 宏任务（macrotask）。在 ES6 规范中，microtask 称为 jobs，macrotask 称为 task。

微任务包括 process.nextTick ，promise ，Object.observe ，MutationObserver

宏任务包括 script ， setTimeout ，setInterval ，setImmediate ，I/O ，UI rendering

**所以正确的一次 Event loop 顺序是这样的**

* 执行同步代码，这属于宏任务
* 执行栈为空，查询是否有微任务需要执行
* 执行所有微任务
* 必要的话渲染 UI
* 然后开始下一轮 Event loop，执行宏任务中的异步代码

### Load 和 DOMContentLoaded 区别
Load 事件触发代表页面中的 DOM，CSS，JS，图片已经全部加载完毕。

DOMContentLoaded 事件触发代表初始的 HTML 被完全加载和解析，不需要等待 CSS，JS，图片加载。

### 重绘（Repaint）和回流（Reflow）

重绘是当节点需要更改外观而不会影响布局的，比如改变 color 就叫称为重绘
回流是布局或者几何属性需要改变就称为回流。
回流必定会发生重绘，重绘不一定会引发回流。回流所需的成本比重绘高的多，改变深层次的节点很可能导致父节点的一系列回流。

**所以以下几个动作可能会导致性能问题：**

* 改变 window 大小
* 改变字体
* 添加或删除样式
* 文字改变
* 定位或者浮动
* 盒模型


## 性能优化
你做过什么优化性能的举动

## vue
### 生命周期分析

```
beforeCreate: function () {
        console.group('beforeCreate 创建前状态===============》');
},
created: function () {
    console.group('created 创建完毕状态===============》');           
},
beforeMount: function () {
    console.group('beforeMount 挂载前状态===============》');          
},
mounted: function () {
    console.group('mounted 挂载结束状态===============》');        
},
beforeUpdate: function () {
    console.group('beforeUpdate 更新前状态===============》');          
},
updated: function () {
    console.group('updated 更新完成状态===============》');           
},
beforeDestroy: function () {
    console.group('beforeDestroy 销毁前状态===============》');          
},
destroyed: function () {
    console.group('destroyed 销毁完成状态===============》');      
}
```

### Vue组件间通信

#### 父组件向子组件通信
* 使用props，父组件可以使用props向子组件传递数据。
* 使用$children可以在父组件中访问子组件。

#### 子组件向父组件通信
* 子组件通过$emit触发事件，回调给父组件。
*  通过修改父组件传递的props来修改父组件数据,**但是并不推荐这么做，并不建议直接修改props的值**
*  使用$parent可以访问父组件的数据。

#### 非父子组件、兄弟组件之间的数据传递
* 非父子组件通信，Vue官方推荐使用一个Vue实例作为中央事件总线。新建中央事件线,$emit 发送数据, $on 监听并接受数据
* 使用vuex


**参考资料**
[]()

![](http://static.zhyjor.com/wexin.png)
