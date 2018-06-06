---
title: vue源码解读之四：initMixin做了什么
tags:
  - vue源码解读
  - vue
categories: vue
top: false
copyright: true
date: 2018-03-16 15:42:01
---
为了更好的理解这一部分代码，上篇文章我们介绍了响应式式原理。本篇文章解读initMixin在执行完options合并后的操作，从之前看到的源码内容，我们知道接下来主要会进行一下几个操作过程。
```js
initLifecycle(vm)
initEvents(vm)
initRender(vm)
callHook(vm, 'beforeCreate')
initInjections(vm)
initState(vm)
initProvide(vm)
callHook(vm, 'created')
```
<!--more-->
## initLifecycle
vm的生命周期相关变量初始化
```js
// core/instance/lifecycle

export function initLifecycle (vm: Component) {
  const options = vm.$options
  /**
   * 这里判断是否存在父示例，如果存在，则通过 while 循环，建立所有组建的父子关系
   */
  let parent = options.parent
  if (parent && !options.abstract) {
    while (parent.$options.abstract && parent.$parent) {
      parent = parent.$parent
    }
    parent.$children.push(vm)
  }
  /**
   * 为组件实例挂载相应属性，并初始化
   */
  vm.$parent = parent
  vm.$root = parent ? parent.$root : vm

  vm.$children = []
  vm.$refs = {}

  vm._watcher = null
  vm._inactive = null
  vm._directInactive = false
  vm._isMounted = false
  vm._isDestroyed = false
  vm._isBeingDestroyed = false
}
```
## initEvents
vm的事件监听初始化
```js
// core/instance/events

export function initEvents (vm: Component) {
  /**
   * 创建事件对象，用于存储事件
   */
  vm._events = Object.create(null)
  /**
   * 这里应该是系统事件标识位
   */
  vm._hasHookEvent = false
  // init parent attached events
  // _parentListeners其实是父组件模板中写的v-on
  // 所以下面这段就是将父组件模板中注册的事件放到当前组件实例的listeners里面
  const listeners = vm.$options._parentListeners
  if (listeners) {
    updateComponentListeners(vm, listeners)
  }
}
```

## initRender
initRender函数主要是为我们的组件实例，初始化一些渲染属性，比如$slots和$createElement等。
```js
// core/instance/render

export function initRender (vm: Component) {
  vm._vnode = null // the root of the child tree
  const options = vm.$options
  const parentVnode = vm.$vnode = options._parentVnode // the placeholder node in parent tree
  const renderContext = parentVnode && parentVnode.context

  // 处理组件slot，返回slot插槽对象
  vm.$slots = resolveSlots(options._renderChildren, renderContext)
  vm.$scopedSlots = emptyObject
  // bind the createElement fn to this instance
  // so that we get proper render context inside it.
  // args order: tag, data, children, normalizationType, alwaysNormalize
  // internal version is used by render functions compiled from templates
  vm._c = (a, b, c, d) => createElement(vm, a, b, c, d, false)
  // normalization is always applied for the public version, used in
  // user-written render functions.
  vm.$createElement = (a, b, c, d) => createElement(vm, a, b, c, d, true)

  /**
   * 定义v2.4中新增的$attrs及$listeners属性，需要为其绑定响应式数据更新
   */
  // $attrs & $listeners are exposed for easier HOC creation.
  // they need to be reactive so that HOCs using them are always updated
  const parentData = parentVnode && parentVnode.data

  /* istanbul ignore else */
  if (process.env.NODE_ENV !== 'production') {
    defineReactive(vm, '$attrs', parentData && parentData.attrs || emptyObject, () => {
      !isUpdatingChildComponent && warn(`$attrs is readonly.`, vm)
    }, true)
    defineReactive(vm, '$listeners', options._parentListeners || emptyObject, () => {
      !isUpdatingChildComponent && warn(`$listeners is readonly.`, vm)
    }, true)
  } else {
    defineReactive(vm, '$attrs', parentData && parentData.attrs || emptyObject, null, true)
    defineReactive(vm, '$listeners', options._parentListeners || emptyObject, null, true)
  }
}
```
## callHook
这里是调用钩子函数的方法，也就是触发之前我们options中定义的相应的生命周期函数。进行到此处变开始调用了beforeCreate钩子函数
```js
// core/instance/lifecycle

export function callHook (vm: Component, hook: string) {
  const handlers = vm.$options[hook]
  if (handlers) {
    for (let i = 0, j = handlers.length; i < j; i++) {
      try {
        handlers[i].call(vm)
      } catch (e) {
        handleError(e, vm, `${hook} hook`)
      }
    }
  }
  if (vm._hasHookEvent) {
    vm.$emit('hook:' + hook)
  }
}
```

## initInjections 和 initProvide
vm的事件监听初始化,vm的状态初始化，prop/data/computed/method/watch都在这里完成初始化，因此也是Vue实例create的关键。可以先来看一下官网的描述：
> 提示：provide 和 inject 绑定并不是可响应的。这是刻意为之的。然而，如果你传入了一个可监听的对象，那么其对象的属性还是可响应的。 然后我们来看一下initInjections 和 initProvide的执行顺序：

```js
initInjections(vm) // resolve injections before data/props
initState(vm)
initProvide(vm) // resolve provide after data/props
```
也就是说我们先初始化initInjections

```js
// core/instance/inject

export function initInjections (vm: Component) {

  // 因为并没有vm._provided此时 result返回的是个 null，也就没有进行defineReactive
  const result = resolveInject(vm.$options.inject, vm)
  if (result) {
    observerState.shouldConvert = false
    Object.keys(result).forEach(key => {
      /* istanbul ignore else */
      if (process.env.NODE_ENV !== 'production') {
        defineReactive(vm, key, result[key], () => {
          warn(
            `Avoid mutating an injected value directly since the changes will be ` +
            `overwritten whenever the provided component re-renders. ` +
            `injection being mutated: "${key}"`,
            vm
          )
        })
      } else {
        defineReactive(vm, key, result[key])
      }
    })
    observerState.shouldConvert = true
  }
}
```
接着定义我们的initProvide
```js
// core/instance/inject

export function initProvide (vm: Component) {
  const provide = vm.$options.provide
  if (provide) {
    vm._provided = typeof provide === 'function'
      ? provide.call(vm)
      : provide
  }
}
```

## initState
```js
// core/instance/state

export function initState (vm: Component) {
  vm._watchers = []
  const opts = vm.$options
  if (opts.props) initProps(vm, opts.props)
  if (opts.methods) initMethods(vm, opts.methods)
  if (opts.data) {
    initData(vm)
  } else {
    observe(vm._data = {}, true /* asRootData */)
  }
  if (opts.computed) initComputed(vm, opts.computed)
  if (opts.watch && opts.watch !== nativeWatch) {
    initWatch(vm, opts.watch)
  }
}
```
这里的主要工作主要是定义的数据进行defineReactive，可以简单看一下initData的过程：
```js
// core/instance/state

function initData (vm: Component) {
  let data = vm.$options.data
  data = vm._data = typeof data === 'function'
    ? getData(data, vm)
    : data || {}
  if (!isPlainObject(data)) {
    data = {}
    process.env.NODE_ENV !== 'production' && warn(
      'data functions should return an object:\n' +
      'https://vuejs.org/v2/guide/components.html#data-Must-Be-a-Function',
      vm
    )
  }
  // 代理数据，当访问this.xxx的时候，代理到this.data.xxx
  ...
  proxy(vm, `_data`, key)
  ...
  // observe data
  observe(data, true /* asRootData */)
}
```
**参考资料**
[]()

![](http://oankigr4l.bkt.clouddn.com/wexin.png)