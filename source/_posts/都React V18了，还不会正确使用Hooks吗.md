---
title: 都React V18了，还不会正确使用Hooks吗
tags:
  - React
  - js
categories: React
top: false
copyright: true
date: 2022-12-01 14:13:21
---
杭州下雪了，想去西湖看雪了，雪后的杭州更有水墨画里的感觉了，一下雪杭州就成了临安

今天主要想说一下react hooks，react hooks是react v16.8 之后引入的API，现在react都已经到18了，hooks怎么还能不会用呢。hooks引入的目的是给函数式组件增加数据状态管理的能力，同时增加代码的可复用能力。但是同时hooks也是一个潘多拉魔盒，因为函数式组件不再只是单纯的一个纯函数了，可以在内部处理副作用了，使用不好就会经常遇到各种各样的问题，而且错误的使用方式也会引起re-render，引起一些性能上的问题

本文主要介绍hooks的常见的几个问题与最优实践，同时介绍一下随着react版本迭代的API的变化

闲言少叙，直接进入正文
<!--more-->
首先，在使用之前，笔者还是想强调一下

**请配置上`eslint-plugin-react-hooks`**
**请配置上`eslint-plugin-react-hooks`**
**请配置上`eslint-plugin-react-hooks`**

hooks的的使用确实很爽，但是和纯函数相比，还是有挺多反直觉的写法的，比如不能在判断语句中使用hooks。这就很容易有问题，我们需要使用工具来规避这些问题，来提醒我们有些写法是错误的。当然hooks的有其自己的合理性问题，我们暂时不做讨论，这个插件提醒可以保证让我们的写法是符合当前规范的，不至于出现低级问题
## 异步调用的闭包问题
统计1秒内按钮点击的次数，先看代码：
```js
export default function Demo() {
  const [number, setNumber] = React.useState(0);
  const click = () =>
    setTimeout(() => {
      setNumber(number + 1);
    }, 1000);
  return <button onClick={click}> 点击 {number} 次</button>;
}
```
当多次点击的时候的时候，显示的点击次数错误。点击click方法内的闭包回调函数在组件render的时候捕获了number变量，为了解决这个问题可以使用函数方法来更新数据
```js
const click = () =>
    setTimeout(() => {
      setNumber(number => number + 1);
    }, 1000);
```
在调用状态更新函数的时候，会将准确的数据回调给当前的更新函数

### 更近一步
同样的，假如我们统计开屏3秒内的点击次数，在计时结束后，将点击次数发送给server端的时候，就会遇到另一个问题
```js
export default function Demo() {
  const [number, setNumber] = React.useState(0);
  useEffect(() => {
    const timer = setTimeout(() => {
      // do fetch
      console.log(number);
    }, 1000);
    return () => {
      clearTimeout(timer);
    };
    // 依赖这里会有个警告
  }, []);

  return <button onClick={() => setNumber((c) => c + 1)}>点击{number}次</button>;
}

```
首先我们会遇到一个`eslint-plugin-react-hooks`警告
```js
React Hook useEffect has a missing dependency: 'number'. Either include it or remove the dependency array. (react-hooks/exhaustive-deps)
```
而且执行结果也是由于闭包的原因不能正常提交，熟悉useEffect到都知道，这个原因是使用useEffect的时候，依赖需要添加到依赖数组内，这样才能更新数据到useEffect内，但是在这个例子中，添加了依赖后，每次点击都会引起计时器重新执行，引起倒计时失效，就和需求有冲突了，那这种情况下怎么解决呢？

这个问题其实可以简单归累为：**不想让useEffect重新执行的依赖怎么使用的问题**，这个场景下就只能使用useRef来实现了
```js
export default function Demo() {
  const [number, setNumber] = React.useState(0);
  const numberRef = useRef(number);
  numberRef.current = number;
  useEffect(() => {
    const timer = setTimeout(() => {
      // do fetch
      console.log(numberRef.current);
    }, 1000);
    return () => {
      clearTimeout(timer);
    };
  }, []);

  return (
    <button onClick={() => setNumber((c) => c + 1)}>点击{number}次</button>
  );
}

```
通过useRef可以来保证访问到的number一直是最新的，解决了闭包的问题，同时useEffect未直接依赖number，当number变化的时候不会引起重新执行

### 小结
虽然和hooks的写法有关，本质上还是闭包问题，比如forEach内写的定时器也会有同样的问题；但是对于异步场景下的写法，**不想引起useEffect重新执行的变量，就可以用useRef做一层代理**，这种用法只能说是对react hooks设计的
一种妥协

## 用useCallback肯定能提升性能吗
useCallback的作用是缓存函数，避免重复生成新函数，引起组件重新渲染，比如：
```js
const Children = (props) => <button onClick={props.doFetch}>提交</button>;

export default function Demo() {
  const doFetch = useCallback(() => {
    // fetch();
  }, []);

  return <Children doFetch={doFetch} />;
}
```
这是一个很常见的写法，但是需要明确在class组件的时候我们通常使用`shouldComponentUpdate`来拦截更新，通过比较父组件传入的props的变化，来觉得是否re-render子组件，上面的🌰中，`<Children />`只是一个普通组件，只对传入的函数包裹一层useCallback是不能起到优化作用的，需要通过包裹一层`React.memo`才可以，React.memo会对对传入的props进行一次浅比较，避免非必要的更新，如下
```js
const Children = React.memo((props) => <button onClick={props.doFetch}>提交</button>);
```
另外需要补充的是，假如有一些特别复杂的对象属性需要传入的话，可以考虑通过useMemo进行一层包裹，避免一些不必要的re-render。当然，使用useMemo也是有一定的性能成本的，假如只是简单计算的话，直接计算就可以了，可能这样的成本还小一些。

### 小结
只需要记得**使用useCallback的时候，对应的子组件一定要使用React.memo包裹就可以了**，否则使用useCallback就没有任何的意义。

另外对于useCallback，笔者个人的理解是有些破坏代码的可读性了，使用的时候需要按照场景具体评估一下，是否真的需要无脑使用，平衡好代码可维护性和性能

## hooks怎么优雅的使用refs
其实这个问题有些伪命题的感觉，当我们使用在父组件中通过ref操作子组件的方法时，已经就是不优雅的了。官方文档这样说：
> 在常规的 React 数据流中，props 是父组件与子组件交互的唯一方式。要修改子元素，你需要用新的 props 去重新渲染子元素

只能说尽量避免直接使用ref吧，尽量避免打乱react的单向数据流。那回到我们的问题，使用hooks的时候如何使用更优雅的使用ref呢

## 什么场景下需要封装自定义hooks
自定义hooks是基于react hooks api的自定义扩展，可以将一段通用性逻辑封装起来，达到复用的效果。封装的自定义hooks一般内部使用多个react hooks，用于解决一些复杂且通用的逻辑。接下来看几个🌰，然后可以对比一下自己的场景，也并不是所有能用自定义hooks的地方，就需要用自定义hooks的。



**参考资料**

![](http://static.zhyjor.com/wexin.png)
