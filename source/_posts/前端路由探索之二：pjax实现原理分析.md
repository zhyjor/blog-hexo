---
title: 前端路由探索之二：pjax实现原理分析
tags:
  - 前端路由探索
  - 路由
categories: 前端
top: false
copyright: true
date: 2018-07-02 15:23:52
---
 pushState + ajax = pjax
<!--more-->
## 历史
web发展经历了一个漫长的周期，尤其是ajax的出现，让JavaScript以及整个web的发展翻开了崭新的一页。

利用ajax局部刷新页面，相信很多人玩得相当熟练了。如果整个页面的刷新都是使用ajax，我们可以称之为一个webapp，所有的逻辑都是在当页处理，这种形式的页面带来的体验是十分不错的，减少了那些比较“冗余”的页面跳转、新开页面等。不过，webapp的代码是十分不好维护的，页面逻辑太多太深。不比现在层出不穷的mvvm框架可以让你随便high,在几年前，自己做webapp的话出点小问题，整个页面就会瘫痪，而且不方便定位bug，可维护性很低。

## PJAX的实现与应用
### ajax弊端
ajax是一个非常好玩的小东西，不过用起来也会存在一些问题。

我们可以利用ajax进行无刷新改变文档内容，但是没办法去修改URL，有童鞋要问，**这里为什么一定要修改URL呢？**一个URL代表一个特定的网络资源，ajax修改了页面的内容，所以用不同的URL去标识他们，这个还是挺有必要的。

比如我们设计了一个单词查询的页面，比较合理的UR应该是`http://example.com/word`，不同的word对应不同的内容，但是如果整个页面都是ajax实现，我们就没法去修改/word了，当然我们可以使用hash如`http://example.com#word`，但这样就不能很好的处理浏览器的前进和后退问题。如：在页面中查询了单词A的翻译，接着又查询了单词B，这个时候浏览器的浏览历史会生成`http://example.com#A`和`http://example.com#B`两个记录，可是当我们从B转回A的时候，AJAX的效果还停留在B的状态（页面显示的还是单词B的翻译）。部分浏览器对此问题引入了onhashchange的接口，只要URL的hash值发生变化，我们的程序就可以监听并做出相应。不过对于那些木有这个接口的浏览器，就得定时去判断hash的变化了。

而这样的方式对搜索引擎是十分不友好的，twitter和google约定使用hash bang (#!xxx)，也就是hash后面的第一个字符为感叹号，这样的网址他们是会爬取的，但是其他搜索引擎不支持。**PJAX可以在改变页面内容的同时也改变他的URL**，下面来说说PJAX和他的应用。

### 什么是PJAX
history API中有几个新特性，分别是history.pushState和history.replaceState，我们把pushState+AJAX进行封装，合起来就是PJAX~ 虽说实现技术上没什么新东西，但是概念上还是有所不同的。

PJAX的基本思路是，用户点击一个链接，通过ajax更新页面变化的部分，然后使用HTML5的pushState修改浏览器的URL地址，这样有效地避免了整个页面的重新加载。如果浏览器不支持history的两个新API或者JS被禁用了，那这个链接就只能跳转并重新刷新整个页面了。和传统的ajax设计稍微不同，ajax通常是从后台获取JSON数据，然后由前端解析渲染，而PJAX请求的是一个在服务器上生成好的HTML碎片。
过程如下图：

![](http://static.zhyjor.com/201807201541_609.png)

* 客户端向服务器发送一个普通的请求（1）
* 其实也就是点击了一个链接，服务器会响应这个请求（2）
* 返回一个html文档。客户端向服务器发送一个有PJAX标志的请求（3）
* 此时服务器只返回一个html碎片（4）

但是这两次请求都让客户端的URL变化了，希望上面的说明可以让你明白了PAJX和AJAX的区别了。

### PJAX的实现
[先看一个官方DEMO吧](http://pjax.heroku.com/)。

可以看一下php写的服务器端的代码
```php
<?php
error_reporting(false);

$num = $_GET['num'];

if(array_key_exists('HTTP_X_PJAX', $_SERVER) && $_SERVER['HTTP_X_PJAX'] === 'true'){
    if($num == 1) {
?>
        <div class="imgwrap">
            <img src="./images/1.jpg" />
        </div>
        <span><a href="num=2" class="next">下一张&gt;&gt;</a></span>
<?php
    } else if ($num == 2) {
?>
        <div class="imgwrap">
            <img src="./images/2.jpg" />
        </div>
        <span><a href="num=1" class="previous">&lt;&lt;上一张</a>
        <a href="num=3" class="next">下一张&gt;&gt;</a></span>
<?php
    } else {
?>
        <div class="imgwrap">
            <img src="./images/3.jpg" />
        </div>
        <span><a href="num=2" class="previous">&lt;&lt;上一张</a></span>
<?php
    }
}
?>
```

并不是每个连接都使用PJAX来加载，如果有X_PJAX标识，我们才会添加相应的处理。js中稍加注意可以看到：

```js
$.ajax({
    "url": "./interface.php",
    "data": {
        "num": num
    },
    "dataType": "html",
    "headers": {
        "X_PJAX": true
    }
});
```
请求中：

```
Accept:text/html, */*; q=0.01
Accept-Encoding:gzip,deflate,sdch
Connection:keep-alive
Host:qianduannotes.duapp.com
User-Agent:Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36
X-Requested-With:XMLHttpRequest
X_PJAX:true
```
在请求的header中加了一个X_PJAX的头，而后台在处理的时候也做了判断：
```php
function is_pjax(){
    return array_key_exists('HTTP_X_PJAX', $_SERVER) 
            && $_SERVER['HTTP_X_PJAX'] === 'true';
}
```
并不是一定要求在header头部中加入X_PJAX的信息，你也可以在url中加入相关的参数，比如:http://example.com?pjax=1，或者其他方式，只要前后端达到一个共识就行。

## 开源的PJAX库
[jquery-pjax项目地址](https://github.com/defunkt/jquery-pjax) 
[welefen/pjax-不再维护](https://github.com/welefen/pjax)
[Yahoo团队](https://yuilibrary.com/yui/docs/pjax/)

## 注意事项
* 如果浏览器不支持pushState接口函数，那就只能退化为ajax或者使用hash bang了
* 本地环境下使用的话，浏览器会报错：`Uncaught SecurityError: A history state object with URL file:///E:/baidu_app/demo/PJAX/pic-2' cannot be created in a document with origin 'null'. ，所以如果你要测试的话，请把代码丢到服务器上！
* 为了得到更好的体验，PJAX经常配合localStorage来使用，把请求到的内容缓存到本地，再一次请求的时候先从本地查看。如果你的内容是动态变化的，缓存的时候加一个缓存时间，方便更新缓存。
* 还有一个容易忽略的东西是统计，使用PJAX只会局部刷新页面，如果忽略了对统计函数的更新，那就会让你失去很多数据。



**参考资料**
[Pjax是什么以及为什么推荐大家用](https://blog.csdn.net/u010620152/article/details/62422076)
[Building Super Fast Web Apps with PJAX](https://ntotten.com/2012/04/09/building-super-fast-web-apps-with-pjax/)
[pjax的实现与应用](https://www.cnblogs.com/hustskyking/p/history-api-in-html5.html)


![](http://static.zhyjor.com/wexin.png)
