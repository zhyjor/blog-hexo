---
title: nginx实践之二：ubuntu16.04下的常见问题与卸载
tags:
  - nginx实践
  - linux
categories: nginx
top: false
copyright: true
date: 2018-05-20 11:50:03
---
常见的使用问题，卸载也是大坑
<!--more-->
## 工具
,注意工具的使用：
```
nginx -t :检查配置文件是否出错

// 失败
nginx: [emerg] a duplicate default server for [::]:80 in /etc/nginx/sites-enabled/www.zhyjor.com:18
nginx: configuration file /etc/nginx/nginx.conf test failed

// 成功
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```


## 常见问题
### Nginx [emerg]: bind() to 0.0.0.0:80 failed (98: Address already in use)

使用命令关闭占用80端口的程序
 
```
sudo fuser -k 80/tcp
```

### nginx 重启报错

```
nginx: [error] open() "/usr/local/var/run/nginx.pid" failed (2: No such file or directory)

```
报错原因：
未找到nginx.pid文件

* $sudo nginx (执行该命令之后，nginx 会在 /usr/local/var/run/ 路径下创建一个名为nginx.pid 的文件 )
* $sudo nginx -s stop (删除pid文件)
所以在stop后，使用reload启动nginx便会报错，此时使用nginx直接启动便可。

### nginx- duplicate default server error

```
[emerg] a duplicate default server for [::]:80 in /etc/nginx/sites-enabled/www.zhyjor.com
```

[解决方案](https://stackoverflow.com/questions/30973774/nginx-duplicate-default-server-error)


## 卸载（大坑）
[Ubuntu安装Nginx和正确卸载Nginx Nginx相关](https://www.cnblogs.com/zhaoyingjie/p/6840616.html)


**参考资料**
[]()

![](http://static.zhyjor.com/wexin.png)
