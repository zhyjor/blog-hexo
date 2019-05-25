---
title: nginx实践之三：https的部署
tags:
  - nginx实践
  - linux
categories: nginx
top: false
copyright: true
date: 2018-05-23 14:55:46
---
为了部署测试一下pwa应用也是折腾了够久的了，pwa要求使用https，就用nginx整了一下，记录一下
<!--more-->
## 申请并下载证书
在百度云或者阿里云上购买证书，当然如果个人测试用的免费版的足够了，因为我的域名是在百度云买的，为了方便就在[百度云](https://console.bce.baidu.com/cas/)上购买证书了

![](http://static.zhyjor.com/201805231511_394.png)

在百度云的域名，申请证书很快的，基本几分钟就可以了，在证书列表点击查看证书，然后点击证书下载

![](http://static.zhyjor.com/201805231514_441.png)

## 证书部署
将证书解压上传到服务器中，本地解压如下，解压密码就是上一步下载时填写的。

![](http://static.zhyjor.com/201805231515_86.png)

因为我们是使用nginx部署的，因此直接使用文件上传到`/etc/nginx`即可。
## nginx配置
[点击测试](https://www.zhyjor.com/index.html)
最终的部署可以直接看代码：
```
server {
	    listen 443;
        server_name 39.108.208.20;
        ssl on;
	    listen 7003;
	    ssl_certificate   zhyjor.com.cer;
        ssl_certificate_key  zhyjor.com.key;
        ssl_session_timeout 5m;
        ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_prefer_server_ciphers on;
	    location / {
			root /home/data/;
        }
	    location /dist/ {
			root /home/data/vue/;
			try_files $uri $uri/ /index.html last;
            	index index.html;
        }

        location /webpack/ {
            root /home/data/vue/book/;
            try_files $uri $uri/ /index.html last;
                    index index.html;
        }
	}
```
## 总结
配置起来其实也没有那么复杂，而且这里仅仅配置了静态网页，还有多服务器，多域名等多种情况还没进行测试，后续可以继续完整。而且我的服务器是aliyun国内的，需要备案，但是似乎aliyun只封了80端口，**而https的默认443端口并没有限制**，当然这仅仅是漏洞，据说流量大了会被断网的，这里不做更深的说明了。

好了，接下来可以嗨皮的进行pwa的测试了。

**参考资料**
[]()

![](http://static.zhyjor.com/wexin.png)
