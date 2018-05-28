---
title: 剖析Vuejs运行机制之一：基于依赖收集的响应式原理
tags:
  - 剖析Vuejs运行机制
  - vue
categories: vue
top: false
copyright: true
date: 2018-05-18 16:31:53
---
实现数据双向绑定的方式有很多种，例如knockout的观察者模式,Ember的数据模型,Angularjs的脏检测,为什么最近几年的框架选择了Object.defineProperties 或 Proxy这种基于数据劫持的方式。
说到vue的响应式原理，很多人都知道这是通过`Object.defineProperty`方法将data的属性全部转化为`getter/setter`,当属性被修改或者被访问时通知变化。而具体怎么通知的，又是怎么实现的，这些具体的问题就很难回答了。
<!--more-->

[lite-vue源码（github）](https://github.com/zhyjor/lite-vue.git)

## 前言
> 数据模型仅仅是普通的 JavaScript 对象。而当你修改它们时，视图会进行更新。这使得状态管理非常简单直接。

当你把一个普通的 JavaScript 对象传给 Vue 实例的 data 选项，Vue 将遍历此对象所有的属性，并使用 Object.defineProperty 把这些属性全部转为 getter/setter。Object.defineProperty 是 ES5 中一个无法 shim 的特性，这也就是为什么 Vue 不支持 IE8 以及更低版本浏览器的原因。
![](http://oankigr4l.bkt.clouddn.com/201805181642_452.png)
如上图中：每个组件实例都有相应的 watcher 实例对象，它会在组件渲染的过程中把属性记录为依赖，之后当依赖项的 setter 被调用时，会通知 watcher 重新计算，从而致使它关联的组件得以更新。

## 使普通对象变得可观测
首先，我们定义一个数据对象：
```js
const hero = {
  health: 3000,
  IQ: 150
}
```
我们定义了这个英雄的生命值为3000，IQ为150。但是现在还不知道他是谁，不过这不重要，只需要知道这个英雄将会贯穿我们整篇文章，而我们的目的就是通过这个英雄的属性，知道这个英雄是谁。

现在我们可以通过hero.health和hero.IQ直接读写这个英雄对应的属性值。但是，当这个英雄的属性被读取或修改时，我们并不知情。那么应该如何做才能够让英雄主动告诉我们，他的属性被修改了呢？这时候就需要借助Object.defineProperty的力量了,它是 ES5 的 Object 的一个属性：官方的介绍如下：
> The Object.defineProperty() method defines a new property directly on an object, or modifies an existing property on an object, and returns the object.

Object.defineProperty() 方法会直接在一个对象上定义一个新属性，或者修改一个对象的现有属性， 并返回这个对象。我们只使用这个方法使对象变得“可观测”。**这里需要提醒一下，ES6提供了一个proxy类，为什么不用这个来实现呢？**

所以我们的代码修改为：
```js
let hero = {}
let val = 3000
Object.defineProperty(hero, 'health', {
  get () {
    console.log('我的health属性被读取了！')
    return val
  },
  set (newVal) {
    console.log('我的health属性被修改了！')
    val = newVal
  }
})
```
上述代码只能对一个属性实现可观测，我们需要将整个数据对象实现可观测，也简单，加个遍历就行了。
```js
/**
 * 使一个对象转化成可观测对象
 * @param { Object } obj 对象
 * @param { String } key 对象的key
 * @param { Any } val 对象的某个key的值
 */
function defineReactive (obj, key, val) {
  Object.defineProperty(obj, key, {
    get () {
      // 触发getter
      console.log(`我的${key}属性被读取了！`)
      return val
    },
    set (newVal) {
      // 触发setter
      console.log(`我的${key}属性被修改了！`)
      val = newVal
    }
  })
}

/**
 * 把一个对象的每一项都转化成可观测对象
 * @param { Object } obj 对象
 */
function observable (obj) {
  const keys = Object.keys(obj)
  keys.forEach((key) => {
    defineReactive(obj, key, obj[key])
  })
  return obj
}
```
数据对象不变，可以在控制台进行测试。

## 计算属性
现在，英雄已经变得可观测，任何的读写操作他都会主动告诉我们，但也仅此而已，我们仍然不知道他是谁。如果我们希望在修改英雄的生命值和IQ之后，他能够主动告诉他的其他信息，这应该怎样才能办到呢？假设可以这样：
```js
watcher(hero, 'type', () => {
  return hero.health > 4000 ? '坦克' : '脆皮'
})
```
我们定义了一个watcher作为“监听器”，它监听了hero的type属性。这个type属性的值取决于hero.health，换句话来说，当hero.health发生变化时，hero.type也应该发生变化，前者是后者的依赖。我们可以把这个hero.type称为“计算属性”。

那么，我们应该怎样才能正确构造这个监听器呢？可以看到，在设想当中，监听器接收三个参数，分别是被监听的对象、被监听的属性以及回调函数，回调函数返回一个该被监听属性的值。顺着这个思路，我们尝试着编写一段代码：
```js
/**
 * 当计算属性的值被更新时调用
 * @param { Any } val 计算属性的值
 */
function onComputedUpdate (val) {
  console.log(`我的类型是：${val}`);
}

/**
 * 观测者
 * @param { Object } obj 被观测对象
 * @param { String } key 被观测对象的key
 * @param { Function } cb 回调函数，返回“计算属性”的值
 */
function watcher (obj, key, cb) {
  Object.defineProperty(obj, key, {
    get () {
      const val = cb()
      onComputedUpdate(val)
      return val
    },
    set () {
      console.error('计算属性无法被赋值！')
    }
  })
}
```
现在看起来没毛病，一切都运行良好，是不是就这样结束了呢？别忘了，我们现在是通过手动读取hero.type来获取这个英雄的类型，并不是他主动告诉我们的。如果我们希望让英雄能够在health属性被修改后，第一时间主动发起通知，又该怎么做呢？这就涉及到本文的核心知识点——依赖收集。

## 依赖收集
我们知道，当一个可观测对象的属性被读写时，会触发它的getter/setter方法。换个思路，如果我们可以在可观测对象的getter/setter里面，去执行监听器里面的onComputedUpdate()方法，是不是就能够实现让对象主动发出通知的功能呢？

我们需要将我们观测值的回调在观测值发生变换的时候调用，而且可能有很多位置都在观测某个属性，这里我们需要实现一个发布/订阅模式。


现在我们把这个**调度中心**命名为“依赖收集器”，一起来看看应该怎么写：
```js
const Dep = {
  target: null
}
```
就是这么简单。依赖收集器的target就是用来存放监听器里面的onComputedUpdate()方法的。

定义完依赖收集器，我们回到监听器里，看看应该在什么地方把onComputedUpdate()方法赋值给Dep.target：
```js
function watcher (obj, key, cb) {
  // 定义一个被动触发函数，当这个“被观测对象”的依赖更新时调用
  const onDepUpdated = () => {
    const val = cb()
    onComputedUpdate(val)
  }

  Object.defineProperty(obj, key, {
    get () {
      Dep.target = onDepUpdated
      // 执行cb()的过程中会用到Dep.target，
      // 当cb()执行完了就重置Dep.target为null
      const val = cb()
      Dep.target = null
      return val
    },
    set () {
      console.error('计算属性无法被赋值！')
    }
  })
}
```
我们在监听器内部定义了一个新的onDepUpdated()方法，这个方法很简单，就是把监听器回调函数的值以及onComputedUpdate()给打包到一块，然后赋值给Dep.target。这一步非常关键，通过这样的操作，依赖收集器就获得了监听器的回调值以及onComputedUpdate()方法。作为全局变量，Dep.target理所当然的能够被可观测对象的getter/setter所使用。

重新看一下我们的watcher实例：
```js
watcher(hero, 'type', () => {
  return hero.health > 4000 ? '坦克' : '脆皮'
})
```
在它的回调函数中，调用了英雄的health属性，也就是触发了对应的getter函数。理清楚这一点很重要，因为接下来我们需要回到定义可观测对象的defineReactive()方法当中，对它进行改写：
```js
function defineReactive (obj, key, val) {
  const deps = []
  Object.defineProperty(obj, key, {
    get () {
      if (Dep.target && deps.indexOf(Dep.target) === -1) {
        deps.push(Dep.target)
      }
      return val
    },
    set (newVal) {
      val = newVal
      deps.forEach((dep) => {
        dep()
      })
    }
  })
}
```
可以看到，在这个方法里面我们定义了一个空数组deps，当getter被触发的时候，就会往里面添加一个Dep.target。回到关键知识点Dep.target等于监听器的onComputedUpdate()方法，这个时候可观测对象已经和监听器捆绑到一块。任何时候当可观测对象的setter被触发时，就会调用数组中所保存的Dep.target方法，也就是自动触发监听器内部的onComputedUpdate()方法。

至于为什么这里的deps是一个数组而不是一个变量，是因为可能同一个属性会被多个计算属性所依赖，也就是存在多个Dep.target。定义deps为数组，若当前属性的setter被触发，就可以批量调用多个计算属性的onComputedUpdate()方法了。

## 总结
写到这里基本已经实现了一个简单的响应式系统，这里和vue的实现原理是相同的。总的来说，
* 首先实现了一个可观测的对象，对象的读取，修改都被代理了，我们操作该对象的时候，可以发现任何一个操作会被通知出来。但是仅仅这样还是不够的，**我们需要在对象进行操作后，来修改页面，修改我们需要的计算属性**。
* 所以我们需要实现一个监听器watcher,watcher的作用是观察属性，在属性变化时更新页面，更新计算属性。具体怎么实现呢。可观测对象的属性被读写时，触发了getter/setter方法，所以可以在getter/setter方法里来执行watcher提供的计算属性或者页面更新函数。
* 这时就需要实现一个订阅模式的发布中心，来统一处理所有的watcher

首先在 observer 的过程中会注册 get 方法，该方法用来进行「依赖收集」。在它的闭包中会有一个 Dep 对象，这个对象用来存放 Watcher 对象的实例。其实「依赖收集」的过程就是把 Watcher 实例存放到对应的 Dep 对象中去。get 方法可以让当前的 Watcher 对象（Dep.target）存放到它的 subs 中（addSub）方法，在数据变化时，set 会调用 Dep 对象的 notify 方法通知它内部所有的 Watcher 对象进行视图更新。

**参考资料**
**[(非常好)深入浅出 - vue变化侦测原理](https://juejin.im/post/5aaf1c796fb9a028cb2d6cdd)**
**[Vue 模板编译原理](https://juejin.im/post/5aaa506ff265da239236131b)**
[Vue2 原理浅谈](https://juejin.im/post/59f2845e6fb9a0451a759e85)
[深入浅出 - vue变化侦测原理](https://juejin.im/entry/5a2262ba6fb9a0450b6632a2)

[Understanding Vue.js Reactivity in Depth with Object.defineProperty()](https://www.timo-ernst.net/blog/2017/07/26/understanding-vue-js-reactivity-depth-object-defineproperty/?utm_campaign=Revue%20newsletter&utm_medium=Newsletter&utm_source=Vue.js%20Feed)


![](http://oankigr4l.bkt.clouddn.com/wexin.png)