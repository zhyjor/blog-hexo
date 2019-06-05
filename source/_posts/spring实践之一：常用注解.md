---
title: spring实践之一：常用注解
tags:
  - spring实践
  - spring
categories: spring
top: false
copyright: true
date: 2019-06-05 23:20:34
---
spring构建一个restful服务的常见操作
<!--more-->
## 路径参数
### @PathVariable
```
@RequestMapping(value = "/user/{id:\\d+}", method = RequestMethod.GET)
public User getInfo(@PathVariable(name = "id") String idxxx){
    User user = new User();
    user.setUsername("tom");
    return user;
}
```

### @JsonView
* 使用接口声明多种视图
* 在值对象Get方法上指定视图
* 在Controller上指定视图

```java
public interface UserSimpleView {};
public interface UserDetailsView extends UserSimpleView {};
```
**参考资料**
[]()

![](http://static.zhyjor.com/wexin.png)