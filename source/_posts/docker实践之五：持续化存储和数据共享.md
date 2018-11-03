---
title: docker实践之五：持续化存储和数据共享
tags:
  - docker
  - docker实践
categories: docker
top: false
copyright: true
date: 2018-11-03 11:43:14
---
持续化存储和数据共享使用普通的container是不行的
<!--more-->
## 持久化方案
**基于本地文件系统的Volume**:可以将主机的目录作为容器的数据卷
**基于plugin的Volume**

### Volume的类型
**受管理的data Volume：**由docker后台自动创建
**绑定挂载的Volume**:挂载时指定

### Data Volume
通过mysql，指定需要持久化的路径VOLUME["/var/lib/mysql"]
```
docker run -v mysql:/var/lib/mysql
```

### Bind Mounting(开发者利器)
运行容器的时候指定关系就行：
```
docker run -v /home/aaa:/root/aaa

docker run -d --name mysql -v mysql-data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=wordpress mysql

docker run -d -e WORDPRESS_DB_HOST=mysql:3306 --link mysql -p 8080:80 wordpress
```

**参考资料**
[]()

![](http://oankigr4l.bkt.clouddn.com/wexin.png)