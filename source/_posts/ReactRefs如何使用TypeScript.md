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

今年4月的杭州天气总是让人摸不着头脑，可能也是今年疫情的原因，似乎并没有太多春天的感觉；虽然温度是慢慢的升上来了，但感觉没有春天的那种万物复苏，到处鲜花盛开的感觉；不知道是今年疫情的原因，还是视线被俗事一叶障目，想保持初心还是需要一些的。闲话少叙，搬运一篇Martin Hochel的文章，开始吧
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
 
 经常会收到询问如何合适的定义react refs的类型的问题，我没有找到有人写过关于这个问题的资料，就写了这篇文章帮助那些新接触react和typescript的人。
 
 > 免职声明：
 这篇译文完全是凭自己兴趣翻译，详情请参考原文和[React Ref的官方文档](https://reactjs.org/docs/refs-and-the-dom.html)
 
### 什么是Refs
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

## 访问Refs
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

**参考资料**
[React Refs with TypeScript](https://medium.com/@martin_hotell/react-refs-with-typescript-a32d56c4d315)

![](http://static.zhyjor.com/wexin.png)