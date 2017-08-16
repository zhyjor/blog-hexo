---
title: js之事件冒泡
date: 2017-08-16 20:18:35
tags:
  - js
  - 冒泡机制
categories: js
---
###1：事件目标
事件处理程序中的变量event保留着事件对象，event.target属性保存着事件的目标元素。该属性没有被所有浏览器实现 。jQuery对这个事件对象进行扩展，使得在任何浏览器中都能够使用这个属性。通过.target，可以确定DOM中首先接收到事件的元素（即实际被单击的元素）。而且，我们知道this引用的是处理事件的DOM元素，可以确定点击的元素就是我们需要的

```
<pre><code>
$(document).ready(function(){
 $('#switcher').click(function(event){
  $('#switcher .button').toggleClass('hidden');
  })
 })

$(document).ready(function(){
 $('#switcher').click(function(event){
  if(event.target==this){
  $('#switcher .button').toggleClass('hidden');
  }
  })
 })
</code></pre>
```

此时的代码确保了被单击的元素是`id="switcher"`，而不是其他后代元素。

###2：事件捕获与事件冒泡
事件冒泡与事件捕获是描述事件触发时序问题的术语，事件捕获指的是从document到触发事件的那个节点，即自上而下的去触发事件。相反的，事件冒泡是自下而上的去触发事件。绑定事件方法的第三个参数，就是控制事件触发顺序是否为事件捕获。true,事件捕获；false,事件冒泡。默认false,即事件冒泡。Jquery的`e.stopPropagation`会阻止冒泡。

```
<pre>
<code>

html代码

&lt;ul&gt;
   &lt;li&gt;item1&lt;/li&gt;
   &lt;li&gt;item2&lt;/li&gt;
   &lt;li&gt;item3&lt;/li&gt;
   &lt;li&gt;item4&lt;/li&gt;
   &lt;li&gt;item5&lt;/li&gt;
   &lt;li&gt;item6&lt;/li&gt;
   &lt;
/ul&gt;

//事件绑定代码
//利用事件冒泡实现：

　　$("ul").on("click",function(e){
       $(e.target).css("background-color","#ddd").siblings().css("background-color","white");
    })
//也可以给所有事件都绑定上

　　$("li").on("click",function(){
       $(this).css("background-color","#ddd").siblings().css("background-color","white");
   })

</code>
</pre>
```

两种方法看似相似但相差甚远：

* 前者少了一个遍历所有li节点的操作，所以在性能上肯定是更优的。

* 如果我们在绑定事件完成后，页面又动态的加载了一些元素
 `$("&lt;li&gt;item7&lt;/li&gt;").appendTo("ul");`
这时候，第二种方案，由于绑定事件的时候item7还不存在，所以为了效果，我们还要给它再绑定一次事件。而利用冒泡方案由于是给ul绑定的所以不存在问题

###3：阻止事件冒泡
事件冒泡就是事件传播，有些时候我们为了获取某个元素的点击事件而不是某个其他的后代元素或者父元素，我们可以采用上述的e.target的方式，我们也可以对按钮的事件进行过滤，即取消事件冒泡。我们使用`.stopPropagation()`，这个方法也是一种纯JavaScript特性，但在跨浏览器的环境中则无法安全地使用 。不过，只要我们通过jQuery来注册所有的事件处理程序，就可以放心地使用这个方法。在你要处理的事件之前加上e.preventDefault();那么就取消了行为（通俗理解：相当于做了个return操作），不执行之后的语句了。

使用方式如下：

```
<pre>
<code>
$(document).ready(function(){
 $('#switcher .button').click(funtion(event){
  //……
   event.stopPropagation();
  })
 })
</code>
</pre>

```

同以前一样，需要为用作单击处理程序的函数添加一个参数，以便访问事件对象。然后，通过简单地调用event.stopPropagation()就可以避免其他所有DOM元素响应这个事件。这样一来，单击按钮的事件会被按钮处理，而且只会被按钮处理。

###4：默认事件

可能有些人会疑惑`.preventDefault()`哪去了,这就牵扯到默认操作了。如果我们将单击事件处理程序放在一个锚元素上，而不是的一个正常的div等元素，就会有个问题：用户单击连接时，浏览器就会加载一个新的页面。但是这种行为与我们讨论的事件处理程序不是同一个概念，这个单击锚元素的默认操作。同理，用户编辑完表格的回车键的点击触发的submit事件，也是一个默认操作。

我们想取消这种默认操作采用的方式是`.preventDefault()`而不是`.stopPropagetion()`。我们对表单的提交信息检查不通过时可以通过此方法进行阻止默认操作。

**事件传播和默认操作是相互独立的两套机制，在二者任何一方发生时，都可以终止另一方。如果想要同时停止事件传播和默认操作，可以在事件处理程序中返回false，这是对在事件对象上同时调用.stopPropagation()和.preventDefault()的一种简写方式。**

[点击查看参考内容](http://www.cnblogs.com/jams742003/archive/2009/08/29/1556187.html)

![f14](http://oankigr4l.bkt.clouddn.com/f14.jpg)
