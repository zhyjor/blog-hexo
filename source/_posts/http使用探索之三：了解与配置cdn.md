---
title: http使用探索之三：了解与配置cdn
tags:
  - http使用探索
categories: http
top: false
copyright: true
date: 2018-11-10 16:16:25
---
CDN （Content Delivery Network，即内容分发网络）指的是一组分布在各个地区的服务器。这些服务器存储着数据的副本，因此服务器可以根据哪些服务器与用户距离最近，来满足数据的请求。 CDN 提供快速服务，较少受高流量影响。
<!--more-->

## 为什么要用 CDN
缓存、本地存储带来的性能提升，只能在“获取到资源并把它们存起来”这件事情发生之后！也就是说，首次请求资源的时候，这些招数都是救不了我们的。要提升首次请求的响应能力，我们还需要借助 CDN 的能力，就是在网络传输上利用缓存技术使得Web服务数据流能就近访问，是优化网络数据传输非常有效的技术，从而获得高速的体验和品质保证。

网络缓存技术，其目的就是减少网络中冗余数据的重复传输，使之最小化，将广域传输转为本地或就近访问。互联网上传递的内容，大部分为重复的Web/FTP数据，Cache服务器及应用Caching技术的网络设备，可大大优化数据链路性能，消除数据峰值访问造成的结点设备阻塞。Cache服务器具有缓存功能，所以大部分网页对象（Web page object）,如html, htm, php等页面文件，gif,tif,png,bmp等图片文件，以及其他格式的文件，在有效期（TTL）内，对于重复的访问，**不必从原始网站重新传送文件实体, 只需通过简单的认证（Freshness Validation）- 传送几十字节的Header，即可将本地的副本直接传送给访问者。**

由于缓存服务器通常部署在靠近用户端，所以能获得近似局域网的响应速度，并有效减少广域带宽的消耗。据统计，Internet上超过80%的用户重复访问20%的信息资源，给缓存技术的应用提供了先决的条件。缓存服务器的体系结构与Web服务器不同，缓存服务器能比Web服务器获得更高的性能，缓存服务器不仅能提高响应速度，节约带宽，对于加速Web服务器，有效减轻源服务器的负荷是非常有效的。


## 什么是CDN？
CDN的全称是Content Delivery Network，即内容分发网络。其目的是通过在现有的Internet中增加一层新的网络架构，将网站的内容发布到最接近用户的网络"边缘"，使用户可以就近取得所需的内容，解决Internet网络拥塞状况，提高用户访问网站的响应速度。从技术上全面解决由于网络带宽小、用户访问量大、网点分布不均等原因，解决用户访问网站的响应速度慢的根本原因。

狭义地讲，内容分发布网络(CDN)是一种新型的网络构建方式，它是为能在传统的IP网发布宽带丰富媒体而特别优化的网络覆盖层；从广义的角度，CDN代表了一种基于质量与秩序的网络服务模式。

内容发布网(CDN)是一个经策略性部署的整体系统，包括分布式存储、负载均衡、网络请求的重定向和内容管理４个要件，而内容管理和全局的网络流量管理(Traffic Management)是CDN的核心所在。通过用户就近性和服务器负载的判断，CDN确保内容以一种极为高效的方式为用户的请求提供服务。总的来说，**内容服务基于缓存服务器，也称作代理缓存(Surrogate)，它位于网络的边缘，距用户仅有"一跳"(Single Hop)之遥。**

代理缓存是内容提供商源服务器（通常位于CDN服务提供商的数据中心）的一个透明镜像。这样的架构使得CDN服务提供商能够代表他们客户，即内容供应商，向最终用户提供尽可能好的体验，而这些用户是不能容忍请求响应时间有任何延迟的。据统计，**采用CDN技术，能处理整个网站页面的70%～95％的内容访问量，减轻服务器的压力，提升了网站的性能和可扩展性。**

### 比较
与目前现有的内容发布模式相比较，CDN强调了网络在内容发布中的重要性。通过引入主动的内容管理层的和全局负载均衡，CDN从根本上区别于传统的内容发布模式。在传统的内容发布模式中，内容的发布由ICP的应用服务器完成，而网络只表现为一个透明的数据传输通道，这种透明性表现在网络的质量保证仅仅停留在数据包的层面，而不能根据内容对象的不同区分服务质量。此外，**由于IP网的"尽力而为"的特性使得其质量保证是依靠在用户和应用服务器之间端到端地提供充分的、远大于实际所需的带宽通量来实现的。在这样的内容发布模式下，不仅大量宝贵的骨干带宽被占用，同时ICP的应用服务器的负载也变得非常重，**而且不可预计。当发生一些热点事件和出现浪涌流量时，会产生局部热点效应，从而使应用服务器过载退出服务。这种基于中心的应用服务器的内容发布模式的另外一个缺陷在于个性化服务的缺失和对宽带服务价值链的扭曲，内容提供商承担了他们不该干也干不好的内容发布服务。

纵观整个宽带服务的价值链，内容提供商和用户位于整个价值链的两端，中间依靠网络服务提供商将其串接起来。随着互联网工业的成熟和商业模式的变革，在这条价值链上的角色越来越多也越来越细分。比如内容／应用的运营商、托管服务提供商、骨干网络服务提供商、接入服务提供商等等。在这一条价值链上的每一个角色都要分工合作、各司其职才能为客户提供良好的服务，从而带来多赢的局面。从内容与网络的结合模式上看，内容的发布已经走过了ICP的内容（应用）服务器和IDC这两个阶段。IDC的热潮也催生了托管服务提供商这一角色。但是，IDC并不能解决内容的有效发布问题。内容位于网络的中心并不能解决骨干带宽的占用和建立IP网络上的流量秩序。因此将内容推到网络的边缘，为用户提供就近性的边缘服务，从而保证服务的质量和整个网络上的访问秩序就成了一种显而易见的选择。而这就是内容发布网(CDN)服务模式。CDN的建立解决了困扰内容运营商的内容"集中与分散"的两难选择。无疑对于构建良好的互联网价值链是有价值的，也是不可或缺的。

## CDN 如何工作
DNS服务器根据用户IP地址，将域名解析成相应节点的缓存服务器IP地址，实现用户就近访问。使用CDN服务的网站，只需将其域名解析权交给CDN的GSLB设备，将需要分发的内容注入CDN，就可以实现内容加速了。
### 无CDN时网站的访问过程
我们先来看没有CDN服务时，一个网站是如何向用户提供服务的：
* 用户在自己的浏览器中输入要访问的网站域名。
* 浏览器向本地DNS服务器请求对该域名的解析。
* 本地DNS服务器中如果缓存有这个域名的解析结果，则直接响应用户的解析请求。
* 本地DNS服务器中如果没有关于这个域名的解析结果的缓存，则以递归方式向整个DNS系统请求解析，获得应答后将结果反馈给浏览器。
* 浏览器得到域名解析结果，就是该域名相应的服务设备的IP地址。
* 浏览器向服务器请求内容。
* 服务器将用户请求内容传送给浏览器。

### 有CDN时网站的访问过程
在网站和用户之间加入CDN以后，用户不会有任何与原来不同的感觉。最简单的CDN网络有一个DNS服务器和几台缓存服务器就可以运行了。

* 当用户点击网站页面上的内容URL，经过本地DNS系统解析，DNS系统会最终将域名的解析权交给CNAME指向的CDN专用DNS服务器。
* CDN的DNS服务器将CDN的全局负载均衡设备IP地址返回用户。
* 用户向CDN的全局负载均衡设备发起内容URL访问请求。
* 区域负载均衡设备会为用户选择一台合适的缓存服务器提供服务，选择的依据包括：根据用户IP地址，判断哪一台服务器距用户最近；根据用户所请求的URL中携带的内容名称，判断哪一台服务器上有用户所需内容；查询各个服务器当前的负载情况，判断哪一台服务器尚有服务能力。基于以上这些条件的综合分析之后，区域负载均衡设备会向全局负载均衡设备返回一台缓存服务器的IP地址。
* 全局负载均衡设备把服务器的IP地址返回给用户。
* 用户向缓存服务器发起请求，缓存服务器响应用户请求，将用户所需内容传送到用户终端。如果这台缓存服务器上并没有用户想要的内容，而区域均衡设备依然将它分配给了用户，那么这台服务器就要向它的上一级缓存服务器请求内容，直至追溯到网站的源服务器将内容拉到本地。

### CDN网络实现的具体操作过程
为了实现既要对普通用户透明(即加入缓存以后用户客户端无需进行任何设置，直接使用被加速网站原有的域名即可访问)，又要在为指定的网站提供加速服务的同时降低对ICP的影响，只要修改整个访问过程中的域名解析部分，以实现透明的加速服务，下面是CDN网络实现的具体操作过程。

* 作为ICP，只需要把域名解释权交给CDN运营商，其他方面不需要进行任何的修改；操作时，ICP修改自己域名的解析记录，一般用cname方式指向CDN网络Cache服务器的地址。
* 作为CDN运营商，首先需要为ICP的域名提供公开的解析，为了实现sortlist，一般是把ICP的域名解释结果指向一个CNAME记录；
* 当需要进行sorlist时，CDN运营商可以利用DNS对CNAME指向的域名解析过程进行特殊处理，使DNS服务器在接收到客户端请求时可以根据客户端的IP地址，返回相同域名的不同IP地址；
* 由于从cname获得的IP地址，并且带有hostname信息，请求到达Cache之后，Cache必须知道源服务器的IP地址，所以在CDN运营商内部维护一个内部DNS服务器，用于解释用户所访问的域名的真实IP地址；
* 在维护内部DNS服务器时，还需要维护一台授权服务器，控制哪些域名可以进行缓存，而哪些又不进行缓存，以免发生开放代理的情况。


## CDN的实现
### CDN的技术手段
实现CDN的主要技术手段是高速缓存、镜像服务器。可工作于DNS解析或HTTP重定向两种方式，通过Cache服务器，或异地的镜像站点 完成内容的传送与同步更新。DNS方式用户位置判断准确率大于85%，HTTP方式准确率为99%以上；一般情况，各Cache服务器群的用户访问流入数据量与Cache服务器到原始网站取内容的数据量之比在2：1到3：1之间，即分担50%到70%的到原始网站重复访问数据量（主要是图片，流媒体文件等内容）；对于镜像，除数据同步的流量，其余均在本地完成，不访问原始服务器。

镜像站点（Mirror Site）服务器是我们经常可以看到的，它让内容直截了当地进行分布，适用于静态和准动态的数据同步。但是购买和维护新服务器的费用较高，另外还必须在各个地区设置镜像服务器，配备专业技术人员进行管理与维护。大型网站在随时更新各地服务器的同时，对带宽的需求也会显著增加，因此一般的互联网公司不会建立太多的镜像服务器。

高速缓存手段的成本较低，适用于静态内容。Internet的统计表明，超过80%的用户经常访问的是20%的网站的内容，在这个规律下，缓存服务器可以处理大部分客户的静态请求，而原始的WWW服务器只需处理约20%左右的非缓存请求和动态请求，于是大大加快了客户请求的响应时间，并降低了原始WWW服务器的负载。

### CDN的网络架构
CDN网络架构主要由两大部分，分为中心和边缘两部分，中心指CDN网管中心和DNS重定向解析中心，负责全局负载均衡，设备系统安装在管理中心机房，边缘主要指异地节点，CDN分发的载体，主要由Cache和负载均衡器等组成。

当用户访问加入CDN服务的网站时，域名解析请求将最终交给全局负载均衡DNS进行处理。全局负载均衡DNS通过一组预先定义好的策略，将当时最接近用户的节点地址提供给用户，使用户能够得到快速的服务。同时，它还与分布在世界各地的所有CDNC节点保持通信，搜集各节点的通信状态，确保不将用户的请求分配到不可用的CDN节点上，实际上是通过DNS做全局负载均衡。

对于普通的Internet用户来讲，每个CDN节点就相当于一个放置在它周围的WEB。通过全局负载均衡DNS的控制，用户的请求被透明地指向离他最近的节点，节点中CDN服务器会像网站的原始服务器一样，响应用户的请求。由于它离用户更近，因而响应时间必然更快。

**每个CDN节点由两部分组成：负载均衡设备和高速缓存服务器**

负载均衡设备负责每个节点中各个Cache的负载均衡，保证节点的工作效率；同时，负载均衡设备还负责收集节点与周围环境的信息，保持与全局负载DNS的通信，实现整个系统的负载均衡。

高速缓存服务器（Cache）负责存储客户网站的大量信息，就像一个靠近用户的网站服务器一样响应本地用户的访问请求。

CDN的管理系统是整个系统能够正常运转的保证。它不仅能对系统中的各个子系统和设备进行实时监控，对各种故障产生相应的告警，还可以实时监测到系统中总的流量和各节点的流量，并保存在系统的数据库中，使网管人员能够方便地进行进一步分析。通过完善的网管系统，用户可以对系统配置进行修改。

理论上，最简单的CDN网络有一个负责全局负载均衡的DNS和各节点一台Cache，即可运行。DNS支持根据用户源IP地址解析不同的IP，实现就近访问。为了保证高可用性等，需要监视各节点的流量、健康状况等。一个节点的单台Cache承载数量不够时，才需要多台Cache，多台Cache同时工作，才需要负载均衡器，使Cache群协同工作。

## CDN的核心功能
CDN 的核心点有两个，一个是缓存，一个是回源。

这两个概念都非常好理解。对标到上面描述的过程，“缓存”就是说我们把资源 copy 一份到 CDN 服务器上这个过程，“回源”就是说 CDN 发现自己没有这个资源（一般是缓存的数据过期了），转头向根服务器（或者它的上层服务器）去要这个资源的过程。

## CDN 与前端性能优化
CDN 往往被用来存放静态资源。上文中我们举例所提到的“根服务器”本质上是业务服务器，它的核心任务在于生成动态页面或返回非纯静态页面，这两种过程都是需要计算的。业务服务器仿佛一个车间，车间里运转的机器轰鸣着为我们产出所需的资源；相比之下，CDN 服务器则像一个仓库，它只充当资源的“栖息地”和“搬运工”。

所谓“静态资源”，就是像 JS、CSS、图片等不需要业务服务器进行计算即得的资源。而“动态资源”，顾名思义是需要后端实时动态生成的资源，较为常见的就是 JSP、ASP 或者依赖服务端渲染得到的 HTML 页面。

什么是“非纯静态资源”呢？它是指需要服务器在页面之外作额外计算的 HTML 页面。具体来说，当我打开某一网站之前，该网站需要通过权限认证等一系列手段确认我的身份、进而决定是否要把 HTML 页面呈现给我。这种情况下 HTML 确实是静态的，但它和业务服务器的操作耦合，我们把它丢到CDN 上显然是不合适的。

### CDN 的实际应用
**静态资源本身具有访问频率高、承接流量大的特点，因此静态资源加载速度始终是前端性能的一个非常关键的指标。**CDN 是静态资源提速的重要手段，在许多一线的互联网公司，“静态资源走 CDN”并不是一个建议，而是一个规定。

### CDN 优化细节
如何让 CDN 的效用最大化？这又是需要前后端程序员一起思考的庞大命题。它涉及到 CDN 服务器本身的性能优化、CDN 节点的地址选取等。先看一下**CDN 的域名选取。**

一般业务服务器的域名和CDN服务器的域名是不同的，为什么呢：
> Cookie 是紧跟域名的。同一个域名下的所有请求，都会携带 Cookie。大家试想，如果我们此刻仅仅是请求一张图片或者一个 CSS 文件，我们也要携带一个 Cookie 跑来跑去（关键是 Cookie 里存储的信息我现在并不需要），这是一件多么劳民伤财的事情。Cookie 虽然小，请求却可以有很多，随着请求的叠加，这样的不必要的 Cookie 带来的开销将是无法想象的……

同一个域名下的请求会不分青红皂白地携带 Cookie，而静态资源往往并不需要 Cookie 携带什么认证信息。把静态资源和主页面置于不同的域名下，完美地避免了不必要的 Cookie 的出现！

看起来是一个不起眼的小细节，但带来的效用却是惊人的。以电商网站静态资源的流量之庞大，如果没把这个多余的 Cookie 拿下来，不仅用户体验会大打折扣，每年因性能浪费带来的经济开销也将是一个非常恐怖的数字。

## 小结


**参考资料**
[CDN是什么？使用CDN有什么优势？](https://www.zhihu.com/question/36514327)
**[深度剖析：CDN内容分发网络技术原理](https://my.oschina.net/pooz/blog/95654)**

![](http://static.zhyjor.com/wexin.png)
