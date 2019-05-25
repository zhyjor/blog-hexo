---
title: css常见布局之二：响应式栅栏布局
tags:
  - css常见布局
  - css
categories: css
top: false
copyright: true
date: 2018-04-11 09:37:44
---
众所周知，Bootstrap内置了一套响应式、移动设备优先的流式栅格系统，随着显示屏幕或视口的改变，自动改变相应的布局。但是css3依旧没有提供grid布局，没办法，我们需要它，尤其是移动端开发。因此自己实践一个高兼容性的grid通用写法很必要。
<!--more-->

## 多列等高问题
对于内容不一样长度的展示文字展示型块，高度不一致的情况很多见，这里可以使用：

```css
.wrapper{
	padding-bottom:600px;
	margin-bottom:-600px;
}
```

## 根据个数的等比例样式
假如每1~3个item显示在同一行，但是item的个数的不一定，如果真有一个，就占100%,两个就50%,三个就33%，可以使用css轻松解决这个问题。
```css
li {
    width: 100%;
    list-style: none;
    display: inline-block;
}

li:first-child:nth-last-child(2),
li:first-child:nth-last-child(2) ~ li {
    width: 50%;
}

li:first-child:nth-last-child(3),
li:first-child:nth-last-child(3) ~ li {
    width: 30%;
}
```

**参考资料**
[制作简约CSS栅栏布局](https://www.jianshu.com/p/0871bc611a9b)

![](http://static.zhyjor.com/wexin.png)
