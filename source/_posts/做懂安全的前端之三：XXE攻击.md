---
title: 做懂安全的前端之三：XXE攻击
tags:
  - 做懂安全的前端
  - 安全
categories: 安全
top: false
copyright: true
date: 2018-07-04 15:45:00
---
现在越来越多主要的web程序被发现和报告存在XXE(XML External Entity attack)漏洞，比如说facebook、paypal等等。 举个例子，我们扫一眼这些网站最近奖励的漏洞，充分证实了前面的说法。尽管XXE漏洞已经存在了很多年，但是它从来没有获得它应得的关注度。很多XML的解析器默认是含有XXE漏洞的，这意味着开发人员有责任确保这些程序不受此漏洞的影响。
<!--more-->

## xml基础
要了解xxe漏洞，那么一定得先明白基础知识，了解xml文档的基础组成。

XML用于标记电子文件使其具有结构性的标记语言，可以用来标记数据、定义数据类型，是一种允许用户对自己的标记语言进行定义的源语言。XML文档结构包括XML声明、DTD文档类型定义（可选）、文档元素。

![](http://static.zhyjor.com/201807041624_420.png)

### xml文档的构建模块
所有的 XML 文档（以及 HTML 文档）均由以下简单的构建模块构成：
#### 元素
元素是 XML 以及 HTML 文档的主要构建模块，元素可包含文本、其他元素或者是空的。
实例:
```xml
<body>body text in between</body>
<message>some message in between</message>
```
空的 HTML 元素的例子是 "hr"、"br" 以及 "img"。



#### 属性
属性可提供有关元素的额外信息
```xml
<img src="computer.gif" />
```
#### 实体
实体是用来定义普通文本的变量。实体引用是对实体的引用。


#### PCDATA
PCDATA 的意思是被解析的字符数据（parsed character data）。
PCDATA 是会被解析器解析的文本。这些文本将被解析器检查实体以及标记。
#### CDATA
CDATA 的意思是字符数据（character data）。
CDATA 是不会被解析器解析的文本。

### DTD(文档类型定义)
DTD（文档类型定义）的作用是定义 XML 文档的合法构建模块。

DTD 可以在 XML 文档内声明，也可以外部引用。

#### 内部声明
eg:

```
<!DOCTYOE test any>
```
完整实例：
```xml
<?xml version="1.0"?>
<!DOCTYPE note [
  <!ELEMENT note (to,from,heading,body)>
  <!ELEMENT to      (#PCDATA)>
  <!ELEMENT from    (#PCDATA)>
  <!ELEMENT heading (#PCDATA)>
  <!ELEMENT body    (#PCDATA)>
]>
<note>
  <to>George</to>
  <from>John</from>
  <heading>Reminder</heading>
  <body>Don't forget the meeting!</body>
</note>
```
#### 外部声明（引用外部DTD）
eg:
```
<!DOCTYPE test SYSTEM 'http://www.test.com/evil.dtd'>
```
完整实例:
```xml
<?xml version="1.0"?>
<!DOCTYPE note SYSTEM "note.dtd">
<note>
<to>George</to>
<from>John</from>
<heading>Reminder</heading>
<body>Don't forget the meeting!</body>
</note> 
```
而note.dtd的内容为:
```xml
<!ELEMENT note (to,from,heading,body)>
<!ELEMENT to (#PCDATA)>
<!ELEMENT from (#PCDATA)>
<!ELEMENT heading (#PCDATA)>
<!ELEMENT body (#PCDATA)>
```

### DTD实体
DTD实体是用于定义引用普通文本或特殊字符的快捷方式的变量，可以内部声明或外部引用。

** 实体又分为一般实体和参数实体**
* **一般实体的声明语法:`<!ENTITY 实体名 "实体内容“>`
引用实体的方式：&实体名；**
* **参数实体只能在DTD中使用，参数实体的声明格式： `<!ENTITY % 实体名 "实体内容“>`
引用实体的方式：`%实体名`；**

#### 内部实体声明
eg:
```
<!ENTITY eviltest "eviltest">
```
完整实例:
```xml
<?xml version="1.0"?>
<!DOCTYPE test [
<!ENTITY writer "Bill Gates">
<!ENTITY copyright "Copyright W3School.com.cn">
]>

<test>&writer;&copyright;</test>
```

#### 外部实体声明
```xml
<?xml version="1.0"?>
<!DOCTYPE test [
<!ENTITY writer SYSTEM "http://www.w3school.com.cn/dtd/entities.dtd">
<!ENTITY copyright SYSTEM "http://www.w3school.com.cn/dtd/entities.dtd">
]>
<author>&writer;&copyright;</author>
```

## XXE的攻击与危害（XML External Entity）
xxe也就是xml外部实体注入。也就是上文中加粗的那一部分。

### 攻击方式

#### 方式一：直接通过DTD外部实体声明
![](http://static.zhyjor.com/201807041604_910.png)

#### 方式二：通过DTD文档引入外部DTD文档，再引入外部实体声明
XML内容

![](http://static.zhyjor.com/201807041605_961.png)

DTD文件内容：

![](http://static.zhyjor.com/201807041605_949.png)

#### 方式三：通过DTD外部实体声明引入外部实体声明
好像有点拗口，其实意思就是先写一个外部实体声明，然后引用的是在攻击者服务器上面的外部实体声明
具体看例子,XML内容

![](http://static.zhyjor.com/201807041606_373.png)

dtd文件内容：

![](http://static.zhyjor.com/201807041607_348.png)

### 支持的协议有哪些？
不同程序支持的协议如下图：

![](http://static.zhyjor.com/201807041608_40.png)

其中php支持的协议会更多一些，但需要一定的扩展支持。

![](http://static.zhyjor.com/201807041608_504.png)



### 产生哪些危害？
#### XXE危害1：读取任意文件
![](http://static.zhyjor.com/201807041612_276.png)
![](http://static.zhyjor.com/201807041611_166.png)

该CASE是读取/etc/passwd，有些XML解析库支持列目录，攻击者通过列目录、读文件，获取帐号密码后进一步攻击，如读取tomcat-users.xml得到帐号密码后登录tomcat的manager部署webshell。

另外，数据不回显就没有问题了吗？如下图，

![](http://static.zhyjor.com/201807041612_841.png)

不，可以把数据发送到远程服务器，

#### XXE危害2：执行系统命令
![](http://static.zhyjor.com/201807041613_175.png)
![](http://static.zhyjor.com/201807041614_817.png)

该CASE是在安装expect扩展的PHP环境里执行系统命令，其他协议也有可能可以执行系统命令。

#### XXE危害3：探测内网端口

![](http://static.zhyjor.com/201807041615_369.png)

该CASE是探测192.168.1.1的80、81端口，通过返回的“Connection refused”可以知道该81端口是closed的，而80端口是open的。

#### XXE危害4：攻击内网网站
![](http://static.zhyjor.com/201807041615_8.png)

该CASE是攻击内网struts2网站，远程执行系统命令。

## 防御XXE攻击
### 方案一、使用开发语言提供的禁用外部实体的方法
```
PHP：

libxml_disable_entity_loader(true);


JAVA:

DocumentBuilderFactory dbf =DocumentBuilderFactory.newInstance();

dbf.setExpandEntityReferences(false);


Python：

from lxml import etree

xmlData = etree.parse(xmlSource,etree.XMLParser(resolve_entities=False))
```

### 方案二、过滤用户提交的XML数据
关键词：<!DOCTYPE和<!ENTITY，或者，SYSTEM和PUBLIC。

## 微信支付的案例
[微信支付官方SDK被曝严重漏洞，目前还未修复](http://www.sohu.com/a/239120907_114877?qq-pf-to=pcqq.group)

## 总结
无论是WEB程序，还是PC程序，只要处理用户可控的XML都可能存在危害极大的XXE漏洞，开发人员在处理XML时需谨慎，在用户可控的XML数据里禁止引用外部实体。

**参考资料**
[未知攻焉知防——XXE漏洞攻防](https://security.tencent.com/index.php/blog/msg/69)
[XXE漏洞的学习与利用总结](https://www.cnblogs.com/r00tuser/p/7255939.html)

![](http://static.zhyjor.com/wexin.png)
