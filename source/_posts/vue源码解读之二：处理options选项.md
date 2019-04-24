---
title: vue源码解读之二：处理options选项
tags:
  - vue源码解读
  - vue
categories: vue
top: false
copyright: true
date: 2018-03-08 10:57:41
---
上篇文章我们主要从代码主线上对vue框架进行了大致的代码解读，当我们引入了vue的时候，框架在vue下面挂载了一系列的全局变量和方法，当我们实例化一个vue对象的时候，经历了什么，本篇让我们细细道来。
<!--more-->
依旧是打开我源码文件
```
// core/instance/index
import { initMixin } from './init'
import { stateMixin } from './state'
import { renderMixin } from './render'
import { eventsMixin } from './events'
import { lifecycleMixin } from './lifecycle'
import { warn } from '../util/index'

function Vue (options) {
  if (process.env.NODE_ENV !== 'production' &&
    !(this instanceof Vue)
  ) {
    warn('Vue is a constructor and should be called with the `new` keyword')
  }
  this._init(options)
}

initMixin(Vue)
stateMixin(Vue)
eventsMixin(Vue)
lifecycleMixin(Vue)
renderMixin(Vue)

export default Vue
```
## initMixin(Vue)
首先执行initMixin(Vue)方法，依然我们来猜测一下，他的功能应该是要混入一些功能。
```js
// core/instance/init.js
...
export function initMixin (Vue: Class<Component>) {
  Vue.prototype._init = function (options?: Object) {
    const vm: Component = this
    // a uid
    vm._uid = uid++

    let startTag, endTag
    /* istanbul ignore if */
    if (process.env.NODE_ENV !== 'production' && config.performance && mark) {
      startTag = `vue-perf-start:${vm._uid}`
      endTag = `vue-perf-end:${vm._uid}`
      mark(startTag)
    }

    // 如果是Vue的实例，则不需要被observe
    // a flag to avoid this being observed
    vm._isVue = true
    // merge options
    // 第一步： options参数的处理
    if (options && options._isComponent) {
      // optimize internal component instantiation
      // since dynamic options merging is pretty slow, and none of the
      // internal component options needs special treatment.
      initInternalComponent(vm, options)
    } else {
      vm.$options = mergeOptions(
        resolveConstructorOptions(vm.constructor),
        options || {},
        vm
      )
    }
    // 第二步： renderProxy
    /* istanbul ignore else */
    if (process.env.NODE_ENV !== 'production') {
      initProxy(vm)
    } else {
      vm._renderProxy = vm
    }
    // expose real self
    vm._self = vm
    // 第三步： vm的生命周期相关变量初始化
    initLifecycle(vm)
    // 第四步： vm的事件监听初始化
    initEvents(vm)
    initRender(vm)
    callHook(vm, 'beforeCreate')
    initInjections(vm) // resolve injections before data/props

    // 第五步： vm的状态初始化，prop/data/computed/method/watch都在这里完成初始化，因此也是Vue实例create的关键。
    initState(vm)
    initProvide(vm) // resolve provide after data/props
    callHook(vm, 'created')

    /* istanbul ignore if */
    if (process.env.NODE_ENV !== 'production' && config.performance && mark) {
      vm._name = formatComponentName(vm, false)
      mark(endTag)
      measure(`vue ${vm._name} init`, startTag, endTag)
    }
    
// 第六步：render & mount
    if (vm.$options.el) {
      vm.$mount(vm.$options.el)
    }
  }
}
...
```
一眼看过去，其实也就知道了，主要是为我们的Vue原型上定义一个方法_init。然后当我们执行new Vue(options) 的时候，会调用这个方法。而这个_init方法的实现，便是我们需要关注的地方。

### mergeOptions
前面定义vm实例都挺好理解的，主要我们来看一下mergeOptions这个方法，其实我们的Vue实例，会在代码运行后增加很多新的东西进去。我们把我们传入的这个对象叫options，实例中我们可以通过vm.$options访问到。
```js
// core/instance/init.js
...
export function initMixin (Vue: Class<Component>) {
  Vue.prototype._init = function (options?: Object) {
    const vm: Component = this
   ...
    // merge options
    // 第一步： options参数的处理
    if (options && options._isComponent) {
      // optimize internal component instantiation
      // since dynamic options merging is pretty slow, and none of the
      // internal component options needs special treatment.
      initInternalComponent(vm, options)
    } else {
      vm.$options = mergeOptions(
        resolveConstructorOptions(vm.constructor),
        options || {},
        vm
      )
    }
...
  }
}
...
```
mergeOptions主要分成两块，就是resolveConstructorOptions(vm.constructor)和options，mergeOptions这个函数的功能就是要把这两个合在一起。options是我们通过new Vue(options)实例化传入的，所以，我们主要需要调研的是resolveConstructorOptions这个函数的功能。通过函数的命名，我们大致能推测出他的功能应该是解析构造函数的options，通过我们出入的参数vm.constructor，应该也可以看出来这一点。好了，我们直接看他的代码实现：
```js
export function resolveConstructorOptions (Ctor: Class<Component>) {
  let options = Ctor.options
  if (Ctor.super) {
    const superOptions = resolveConstructorOptions(Ctor.super)
    const cachedSuperOptions = Ctor.superOptions
    if (superOptions !== cachedSuperOptions) {
      // super option changed,
      // need to resolve new options.
      Ctor.superOptions = superOptions
      // check if there are any late-modified/attached options (#4976)
      const modifiedOptions = resolveModifiedOptions(Ctor)
      // update base extend options
      if (modifiedOptions) {
        extend(Ctor.extendOptions, modifiedOptions)
      }
      options = Ctor.options = mergeOptions(superOptions, Ctor.extendOptions)
      if (options.name) {
        options.components[options.name] = Ctor
      }
    }
  }
  return options
}
```
乍看resolveConstructorOptions时，可能我们不太清楚Ctor类里面每个属性到底代表了什么，没关系，我们找到实现Vue 子类功能的 Vue.extend 方法：
```js
// core/global-api/extend
Vue.extend = function (extendOptions: Object): Function {
  ...
  const Sub = function VueComponent (options) {
    this._init(options)
  }
  Sub.prototype = Object.create(Super.prototype)
  Sub.prototype.constructor = Sub
  Sub.cid = cid++
  Sub.options = mergeOptions(
    Super.options,
    extendOptions
  )
  Sub['super'] = Super

  // For props and computed properties, we define the proxy getters on
  // the Vue instances at extension time, on the extended prototype. This
  // avoids Object.defineProperty calls for each instance created.
  if (Sub.options.props) {
    initProps(Sub)
  }
  if (Sub.options.computed) {
    initComputed(Sub)
  }

  // allow further extension/mixin/plugin usage
  Sub.extend = Super.extend
  Sub.mixin = Super.mixin
  Sub.use = Super.use

  // create asset registers, so extended classes
  // can have their private assets too.
  ASSET_TYPES.forEach(function (type) {
    Sub[type] = Super[type]
  })
  // enable recursive self-lookup
  if (name) {
    Sub.options.components[name] = Sub
  }

  // keep a reference to the super options at extension time.
  // later at instantiation we can check if Super's options have
  // been updated.
  Sub.superOptions = Super.options
  Sub.extendOptions = extendOptions
  Sub.sealedOptions = extend({}, Sub.options)

  // cache constructor
  cachedCtors[SuperId] = Sub
  return Sub
}
```
我们可以看到，该函数，实现了一个JS的经典继承方法，最后返回了一个继承自Super 的子类Sub。我们主要注意这里的代码：
```js
Sub.options = mergeOptions(
    Super.options,
    extendOptions
  )
  Sub['super'] = Super
  Sub.superOptions = Super.options
  Sub.extendOptions = extendOptions
  Sub.sealedOptions = extend({}, Sub.options)
```
看到这里，上面的resolveConstructorOptions功能函数我们就大致明白什么意思了：
* Ctor.super 来判断该类是否是Vue的子类

* if (superOptions !== cachedSuperOptions) 来判断父类中的options 有没有发生变化，主要考虑到下面这种情况：
```js
Vue.extend(options)
Vue.mixin(options)
```
* 返回获merge自己的options与父类的options属性

接下来就重点看mergeOptions的实现了：
```js
// core/util/options
/**
 * Merge two option objects into a new one.
 * Core utility used in both instantiation and inheritance.
 */
export function mergeOptions (
  parent: Object,
  child: Object,
  vm?: Component
): Object {
  if (process.env.NODE_ENV !== 'production') {
    checkComponents(child)
  }

  if (typeof child === 'function') {
    child = child.options
  }

  // 统一props格式
  normalizeProps(child, vm)

  normalizeInject(child, vm)
  // 统一directives格式
  normalizeDirectives(child)
  // 如果存在child.extends
  // ...
  // 如果存在child.mixins
  // ...
  const extendsFrom = child.extends
  if (extendsFrom) {
    parent = mergeOptions(parent, extendsFrom, vm)
  }
  if (child.mixins) {
    for (let i = 0, l = child.mixins.length; i < l; i++) {
      parent = mergeOptions(parent, child.mixins[i], vm)
    }
  }
  // 针对不同的键值，采用不同的merge策略
  const options = {}
  let key
  for (key in parent) {
    mergeField(key)
  }
  for (key in child) {
    if (!hasOwn(parent, key)) {
      mergeField(key)
    }
  }
  function mergeField (key) {
    const strat = strats[key] || defaultStrat
    options[key] = strat(parent[key], child[key], vm, key)
  }
  return options
}
```
上面采取了对不同的field采取不同的策略，Vue提供了一个strats对象，其本身就是一个hook,如果strats有提供特殊的逻辑，就走strats,否则走默认merge逻辑。
```js
// core/util/options
const strats = config.optionMergeStrategies
strats.el  = strats.propsData = ...
strats.data = ...
strats.watch  ...
....

const defaultStrat = function (parentVal: any, childVal: any): any {
  return childVal === undefined
    ? parentVal
    : childVal
}
```
用这种hook的方式就能很好的区分对待公共处理逻辑与特殊处理逻辑，我们以data为例去看看它们做了什么特殊处理：
```js
// core/util/options
strats.data = function (
  parentVal: any,
  childVal: any,
  vm?: Component
): ?Function {
  /**
  * Vue.extend 方法里面是这么合并属性的：
  * Sub.options = mergeOptions(
  *   Super.options,
  *   extendOptions
  * )
  * 在Vue的组件继承树上的merge是不存在vm的
  */
  if (!vm) {
    // 如果子属性不是个函数，那么返回父属性的值
    if (childVal && typeof childVal !== 'function') {
      process.env.NODE_ENV !== 'production' && warn(
        'The "data" option should be a function ' +
        'that returns a per-instance value in component ' +
        'definitions.',
        vm
      )

      return parentVal
    }
    return mergeDataOrFn.call(this, parentVal, childVal)
  }

  return mergeDataOrFn(parentVal, childVal, vm)
}


/**
* 接下来看看mergeDataOrFn操作，如果options.data是个函数，主要是执行函数后，再进行data的merge
*/
export function mergeDataOrFn (
  parentVal: any,
  childVal: any,
  vm?: Component
): ?Function {
  if (!vm) {
    // in a Vue.extend merge, both should be functions
    if (!childVal) {
      return parentVal
    }
    if (!parentVal) {
      return childVal
    }
    // when parentVal & childVal are both present,
    // we need to return a function that returns the
    // merged result of both functions... no need to
    // check if parentVal is a function here because
    // it has to be a function to pass previous merges.
    return function mergedDataFn () {
      return mergeData(
        typeof childVal === 'function' ? childVal.call(this) : childVal,
        typeof parentVal === 'function' ? parentVal.call(this) : parentVal
      )
    }
  } else if (parentVal || childVal) {
    return function mergedInstanceDataFn () {
      // instance merge
      const instanceData = typeof childVal === 'function'
        ? childVal.call(vm)
        : childVal
      const defaultData = typeof parentVal === 'function'
        ? parentVal.call(vm)
        : parentVal
      if (instanceData) {
        return mergeData(instanceData, defaultData)
      } else {
        return defaultData
      }
    }
  }
}
```
这里告诉我们，options.data经过merge之后，实际上是一个function,在真正调用function才会进行真正的merge,其它的merge都会根据自身特点而又不同的操作，这里就不贴代码了。
**走到这一步，我们终于把业务逻辑以及组件的一些特性全都放到了vm.$options中了，后续的操作我们都可以从vm.$options拿到可用的信息。框架基本上都是对输入宽松，对输出严格，vue也是如此，不管使用者添加了什么代码，最后都规范的收入vm.$options中。**

## renderProxy
这一步比较简单，主要是定义了vm._renderProxy,这是后期为render做准备的，作用是在render中将this指向vm._renderProxy。一般而言，vm._renderProxy是等于vm的，但在开发环境，Vue动用了Proxy这个新API，有关Proxy，大家可以读读深入浅出ES6（十二）：代理 Proxies, 这里不再展开。

**参考资料**
[]()

![](http://static.zhyjor.com/wexin.png)
