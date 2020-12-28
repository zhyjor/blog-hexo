---
title: 【译】React Refs中使用TypeScript
tags:
  - react
  - 前端
categories: react
top: false
copyright: true
date: 2020-04-18 11:25:58
---
先放上[原文链接](https://medium.com/@martin_hotell/react-refs-with-typescript-a32d56c4d315)

今年4、5月的杭州天气总是让人摸不着头脑，可能也是今年疫情的原因，似乎并没有太多春天的感觉；虽然温度是慢慢的升上来了，但感觉没有春天的那种万物复苏，到处鲜花盛开的感觉；不知道是今年疫情的原因，还是视线被俗事一叶障目，总之一切都不太像想象中的样子。闲话少叙吧，搬运一篇Martin Hochel的文章，开始吧
<!--more-->
![](http://static.zhyjor.com/blog/2020-04-18-034713.jpg)
> 文章使用以下版本

```json
{
  "@types/react": "16.4.7",
  "@types/react-dom": "16.0.6",
  "typescript": "3.0.1",
  "react": "16.4.2",
  "react-dom": "16.4.2"
}
```
 [源码地址](https://github.com/Hotell/blogposts/tree/master/2018-08/react-ts-refs)
 
 经常会收到询问typescript中如何合适的定义react refs的类型的问题，我没有找到有人写过关于这个问题的资料，就写了这篇文章帮助那些新接触react和typescript的人。
 
 > 免职声明：
 这篇译文完全是凭自己兴趣翻译，详情请参考原文和[React Ref的官方文档](https://reactjs.org/docs/refs-and-the-dom.html)
 
## 什么是Refs
 > Refs provide a way to access DOM nodes or React elements created in the render method.
 Refs提供了一种在React中访问Dom节点的方式
 
## 创建Refs

```js
 class MyComponent extends Component {
  private myRef = createRef()
  render() {
    return <div ref={this.myRef} />
  }
}
```
组件这样定义会收到一个编译报错
```
[ts]
Type 'RefObject<{}>' is not assignable to type 'RefObject<HTMLDivElement>'.
```
为什么会出现这个报错呢，ts在jsx文件中有着非常优秀的类型推断，我们在一个`<div>`上增加了ref，ts就推断出需要使用HTMLDivElement类型进行接收，我们可以通过下面的写法解决这个问题。我们先看一下对React.createRef的定义：
```js
// react.d.ts
function createRef<T>(): RefObject<T>

// react.d.ts
interface RefObject<T> {
  // immutable
  readonly current: T | null
}
```
返回的`RefObject<T>`是泛型；由此我们就可以知道怎么解决上述验证报错的问题了：
![](http://static.zhyjor.com/blog/2020-04-18-151348.jpg)

## 使用Refs
我们可以直接通过定义在ref上的current属性来访问这个node，如下
```js
const node = this.myRef.current
```
但是呢，这个node可能是null，所以我们在使用这个值来进行一些操作的时候，使用下面的代码是不行的，会收到ts的报错：
```js
class MyComponent extends Component {
  private myRef = React.createRef<HTMLDivElement>()
  focus() {
    const node = this.myRef.current
    node.focus()
  }
}

[ts] Object is possibly 'null'.
const node: HTMLDivElement | null
```

我们先看一下React文档是怎么定义current的：
> React will assign the current property with the DOM element when the component mounts, and assign it back to null when it unmounts. ref updates happen before componentDidMount or componentDidUpdate lifecycle hooks.
> 当组件挂载componentDidMount时，React会将dom节点赋值给current，而当componentDidUpdate时，current的值被修改为null；

这就是ts想通过编译错误想提醒你的信息，你需要进行一些安全措施，使用`if`进行非空判断时必要的，以保证程序不会出现运行时错误；
![](http://static.zhyjor.com/blog/2020-04-18-153750.jpg)

这样我们就得到了HTMLDivElement DOM api的自动提醒，还是很香的
![](http://static.zhyjor.com/blog/2020-04-18-0_gzeeS5C5h2tBDbv4.gif)

### 给自定义Class组件添加Ref
和上面的栗子类似，我们如果想在挂载自定义组件的时候就获取焦点，我们可以通过ref访问到自定义组件的实例，调用组件的focus方法，就可以实现：
```js
import React, { createRef, Component } from 'react'
class AutoFocusTextInput extends Component {
  // create ref with explicit generic parameter 
  // this time instance of MyComponent
  private myCmp = createRef<MyComponent>()
  componentDidMount() {
    // @FIXME
    // non null assertion used, extract this logic to method!
    this.textInput.current!.focus()
  }
  render() {
    return <MyComponent ref={this.textInput} />
  }
}
```
⚠️
* 这种方式仅仅适用于声明为class的自定义组件
* 我们可以访问所有的实例方法

![](http://static.zhyjor.com/blog/2020-04-23-114502.jpg)

是不是很优雅🔥

### Refs和函数组件
> 因为函数组件没有实例，你可能不会在函数组件上使用ref属性；但是当你在函数组件内部的时候，还是可以通过ref来访问Dom节点或class组件的

![](http://static.zhyjor.com/blog/2020-04-23-120025.jpg)

## Forwarding Refs
> Ref forwarding是一种将ref钩子自动传递给组件的子孙组件的技术

### 传递refs到DOM components
定义一个FancyButton组件，渲染一个原生的button到页面上
![](http://static.zhyjor.com/blog/2020-04-23-122405.jpg)

> Ref forwarding是组件一个可选的的特性。它可以接受上层组件传递下来的ref，然后传递给自己的子组件。

在下面的例子中，我们给组件加上Forwarding Refs，这样在必要的时候我们就可以通过ref直接访问这个组件内的button节点，就像我们直接使用button节点一样
![](http://static.zhyjor.com/blog/2020-04-23-122952.jpg)

这里到底是什么实现的呢？
* 我们创建并export一个Ref类型给我们组件的调用方
* 使用forwardRef，我们获取到ref，并传递给子组件，这是一个包含两个参数的普通函数

```js
// react.d.ts
function forwardRef<T, P = {}>(
  Component: RefForwardingComponent<T, P>
): ComponentType<P & ClassAttributes<T>>

// 这里的T，P
1:T是DOM的类型
2:P是传递的Props
3:返回值的定义是混合了props值和ref类型的组件的定义
```

这样我们就可以类型安全的调用了：
![](http://static.zhyjor.com/blog/2020-04-23-0_OWdwypfLrHqpjoq2.gif)

### 高阶组件中使用Forwarding refs
[官方文档](https://reactjs.org/docs/forwarding-refs.html#forwarding-refs-in-higher-order-components)关于高阶组件使用Forwarding refs的方式还是比较复杂的;简答来说，我们只要用forwardRef API包一层你的组件就好了
```js
return forwardRef((props, ref) => {
  return <LogProps {...props} forwardedRef={ref} />
})
```
下面是class组件方式实现的FancyButton
![](http://static.zhyjor.com/blog/2020-04-24-020526.jpg)
这是我们想要如何使用这个组件
![](http://static.zhyjor.com/blog/2020-04-24-020706.jpg)

最后，我们通过ref forwarding实现这个高阶组件
![](http://static.zhyjor.com/blog/2020-04-24-023935.jpg)

使用ref forwarding的高阶组件需要我们明确参数类型
```js
const EnhancedFancyButton = withPropsLogger<
  FancyButton, 
  FancyButtonProps
>(FancyButton)
```
这样我们就可以类型安全的使用了
![](http://static.zhyjor.com/blog/2020-04-24-0_Rkp7RYK65NVE8-YB.gif)

以上！
最后的惯例，贴上[我的博客](https://github.com/zhyjor/homepage-index)，欢迎关注

**参考资料**
[React Refs with TypeScript](https://medium.com/@martin_hotell/react-refs-with-typescript-a32d56c4d315)
[Adding TypeScript](https://create-react-app.dev/docs/adding-typescript/)
[何时使用 Refs(官方文档)](http://doc.codingdict.com/react-cn-doc/docs/refs-and-the-dom/)

![](https://static.zhyjor.com/wexin.png)