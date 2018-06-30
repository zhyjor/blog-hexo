---
title: sass基础之三：嵌套
tags:
  - sass基础
  - sass
  - css
categories: css
copyright: true
date: 2017-03-22 17:32:34
---
sass的嵌套（Nesting）包括两种：一种是选择器的嵌套；另一种是属性的嵌套。我们一般说起或用到的都是选择器的嵌套。
<!--more-->
### 选择器嵌套
所谓选择器嵌套指的是在一个选择器中嵌套另一个选择器来实现继承，从而增强了sass文件的结构性和可读性。

在选择器嵌套中，可以使用 **&表示父元素选择器**
```
//sass style
//-------------------------------
#top_nav{
  line-height: 40px;
  text-transform: capitalize;
  background-color:#333;
  a{
    display: block;
    padding: 0 10px;
    color: #fff;

    &:hover{
      color:#ddd;
    }
  }
}

//css style
//-------------------------------
#top_nav{
  line-height: 40px;
  text-transform: capitalize;
  background-color:#333;
}  
#top_nav a{
  display: block;
  padding: 0 10px;
  color: #fff;
}
#top_nav a:hover{
  color:#ddd;
}
```
### 属性嵌套
所谓属性嵌套指的是有些属性拥有同一个开始单词，如border-width，border-color都是以border开头。对于这些相同的部分可以使用嵌套来实现（这种实现方式的好坏还待商榷）
```
//sass style
//-------------------------------
.fakeshadow {
  border: {
    style: solid;
    left: {
      width: 4px;
      color: #888;
    }
    right: {
      width: 2px;
      color: #ccc;
    }
  }
}

//css style
//-------------------------------
.fakeshadow {
  border-style: solid;
  border-left-width: 4px;
  border-left-color: #888;
  border-right-width: 2px;
  border-right-color: #ccc; 
}
```

### @at-root
sass3.3.0中新增的功能，用来跳出选择器嵌套的。默认嵌套会继承所有的上级选择器，但是有了这个就可以跳出所有的上级选择器

#### 普通跳出嵌套

只跳出选择器嵌套
```
//sass style
//-------------------------------
//没有跳出
.parent-1 {
  color:#f00;
  .child {
    width:100px;
  }
}

//单个选择器跳出
.parent-2 {
  color:#f00;
  @at-root .child {
    width:200px;
  }
}

//css style
//-------------------------------
.parent-1 {
  color: #f00;
}
.parent-1 .child {
  width: 100px;
}

.parent-2 {
  color: #f00;
}
.child {
  width: 200px;
}

```

#### @at-root (without: ...)和 @at-root (with: ...)
默认的@at-root只能跳出选择器嵌套，不能跳出@media或者@support，如果要跳出这两种，这需要使用`@at-root (without: media)， @at-root (without: support)`。这个without的可选的值有四个：
* without： all，表示所有
* without: rule，表示常规css，**rule是默认值**
* without: media，表示media
* without: support，@support现在使用还不广泛

```
//sass style
//-------------------------------
//跳出父级元素嵌套
@media print {
    .parent1{
      color:#f00;
      @at-root .child1 {
        width:200px;
      }
    }
}

//跳出media嵌套，父级有效
@media print {
  .parent2{
    color:#f00;

    @at-root (without: media) {
      .child2 {
        width:200px;
      } 
    }
  }
}

//跳出media和父级
@media print {
  .parent3{
    color:#f00;

    @at-root (without: all) {
      .child3 {
        width:200px;
      } 
    }
  }
}

//sass style
//-------------------------------
@media print {
  .parent1 {
    color: #f00;
  }
  .child1 {
    width: 200px;
  }
}

@media print {
  .parent2 {
    color: #f00;
  }
}
.parent2 .child2 {
  width: 200px;
}

@media print {
  .parent3 {
    color: #f00;
  }
}
.child3 {
  width: 200px;
}
```

#### @at-root与 &配合使用
```
//sass style
//-------------------------------
.child{
    @at-root .parent &{
        color:#f00;
    }
}

//css style
//-------------------------------
.parent .child {
  color: #f00;
}
```

#### 应用于@keyframe
该用法最可以将动画关键帧放在选择器内部，使得结构看起来更清晰。
```
//sass style
//-------------------------------
.demo {
    ...
    animation: motion 3s infinite;

    @at-root {
        @keyframes motion {
          ...
        }
    }
}

//css style
//-------------------------------   
.demo {
    ...   
    animation: motion 3s infinite;
}
@keyframes motion {
    ...
}
```

**参考资料**
[sass基础](https://www.w3cplus.com/sassguide/syntax.html)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)