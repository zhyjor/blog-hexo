---
title: vue源码解读之一：造物创世
tags:
  - vue
  - vue源码解读
categories: vue
top: false
copyright: true
date: 2018-03-06 09:13:40
---
源码解读，最好从第一个版本开始看起，有时间的话也可以一个提交一个提交的去看，可以很好理解作者的思路历程，而且最初的版本一般更偏重最初的想法，偏重核心。我们反其道而行，先看当前版本。
<!--more-->
当前master分支版本是：[v2.5.0](https://github.com/vuejs/vue/tree/master)

对于vue来说，我们第一眼看到，第一次用到的最直观的就是：
```js
new Vue({
  el: ...,
  data: ...,
  ....
})
```
## index
实例化的过程中究竟发生了什么呢，让我们深入看看。打开源码工程，其核心代码在src/core目录下。下面我们从入口文件index.js开始进入：
```js
// src/core/index.js
// vue的核心方法
import Vue from './instance/index'
// 初始化全局api
import {initGlobalAPI} from './global-api/index'
// 判断是不是服务器渲染，这里应该是一个Boolean变量
import {isServerRendering} from 'core/util/env'
// 全局初始化执行
initGlobalAPI(Vue)
// 为vue的原型定义属性$isServer
Object.defineProperty(Vue.prototype, '$isServer', {
  get: isServerRendering
})
// 为vue原型定义$ssrContext属性
Object.defineProperty(Vue.prototype, '$ssrContext', {
  get () {
    /* istanbul ignore next */
    return this.$vnode && this.$vnode.ssrContext
  }
})

Vue.version = '__VERSION__'

export default Vue

```
## vue功能类
下面我们来一步步验证我们的猜测，首先找到core/instance/index文件，可以清晰的看到：
```js
// core/instance/index

import { initMixin } from './init'
import { stateMixin } from './state'
import { renderMixin } from './render'
import { eventsMixin } from './events'
import { lifecycleMixin } from './lifecycle'
import { warn } from '../util/index'

function Vue (options) {
  // 判断是否是new调用。
  if (process.env.NODE_ENV !== 'production' &&
    !(this instanceof Vue)
  ) {
    warn('Vue is a constructor and should be called with the `new` keyword')
  }
  // 开始初始化
  this._init(options)
}
// 添加Vue._init(options)内部方法，./init.js
initMixin(Vue)
/**
 * ./state.js
 * 添加属性和方法
 * Vue.prototype.$data
 * Vue.prototype.$props
 * Vue.prototype.$watch
 * Vue.prototype.$set
 * Vue.prototype.$delete
 */
stateMixin(Vue)
/**
 * ./event.js
 * 添加实例事件
 * Vue.prototype.$on
 * Vue.prototype.$once
 * Vue.prototype.$off
 * Vue.prototype.$emit
 */
eventsMixin(Vue)
/**
 * ./lifecycle.js
 * 添加实例生命周期方法
 * Vue.prototype._update
 * Vue.prototype.$forceUpdate
 * Vue.prototype.$destroy
 */
lifecycleMixin(Vue)
/**
 * ./render.js
 * 添加实例渲染方法
 * 通过执行installRenderHelpers(Vue.prototype);为实例添加很多helper
 * Vue.prototype.$nextTick
 * Vue.prototype._render
 */
renderMixin(Vue)

export default Vue


```
这里简单定义了一个vue class,然后调用一系列的Mixin方式来初始化一些功能，这里最终导出了一个vue的功能类。

## initGlobalAPI
接下来，我们接着看initGlobalAPI这个东西，其实在[Vue官网](https://cn.vuejs.org/v2/api/#%E5%85%A8%E5%B1%80-API)上，就已经为我们说明了Vue的全局属性：

![](http://oankigr4l.bkt.clouddn.com/201806060940_682.png)

打开源码看看：
```js
// core/global-api/index
/* @flow */
// flow.js吗
import config from '../config'
import {initUse} from './use'
import {initMixin} from './mixin'
import {initExtend} from './extend'
import {initAssetRegisters} from './assets'
import {set, del} from '../observer/index'
import {ASSET_TYPES} from 'shared/constants'
import builtInComponents from '../components/index'

import {
  warn,
  extend,
  nextTick,
  mergeOptions,
  defineReactive
} from '../util/index'

export function initGlobalAPI (Vue: GlobalAPI) {
  // config
  // 重写config,创建了一个configDef对象，最终目的是为了Object.defineProperty(Vue, 'config', configDef)
  const configDef = {}
  configDef.get = () => config
  if (process.env.NODE_ENV !== 'production') {
    configDef.set = () => {
      warn(
        'Do not replace the Vue.config object, set individual fields instead.'
      )
    }
  }
  Object.defineProperty(Vue, 'config', configDef)
  // 具体Vue.congfig的具体内容就要看../config文件了

  // exposed util methods.
  // NOTE: these are not considered part of the public API - avoid relying on
  // them unless you are aware of the risk.
  //  这些工具方法不视作全局API的一部分，除非你已经意识到某些风险，否则不要去依赖他们
  // 添加一些方法，但是该方法并不是公共API的一部分。源码中引入了flow.js

  Vue.util = {
    warn,// 查看'../util/debug'
    extend,//查看'../sharde/util'
    mergeOptions,//查看'../util/options'
    defineReactive//查看'../observe/index'，这个是定义响应式是的核心方法吧
  }

  Vue.set = set//查看'../observe/index'
  Vue.delete = del//查看'../observe/index'
  Vue.nextTick = nextTick//查看'../util/next-click'.在callbacks中注册回调函数

  // 创建一个纯净的options对象，添加components、directives、filters属性
  Vue.options = Object.create(null)
  ASSET_TYPES.forEach(type => {
    Vue.options[type + 's'] = Object.create(null)
  })

  // this is used to identify the "base" constructor to extend all plain-object
  // components with in Weex's multi-instance scenarios.
  Vue.options._base = Vue

  // ../components/keep-alive.js  拷贝组件对象。该部分最重要的一部分。
  extend(Vue.options.components, builtInComponents)
// Vue.options = {
  //   components : {
  //     KeepAlive : {
  //       name : 'keep-alive',
  //       abstract : true,
  //       created : function created(){},
  //       destoryed : function destoryed(){},
  //       props : {
  //         exclude : [String, RegExp, Array],
  //         includen : [String, RegExp, Array],
  //         max : [String, Number]
  //       },
  //       render : function render(){},
  //       watch : {
  //         exclude : function exclude(){},
  //         includen : function includen(){},
  //       }
  //     },
  //     directives : {},
  //     filters : {},
  //     _base : Vue
  //   }
  // }

  // 添加Vue.use方法，使用插件，内部维护一个插件列表_installedPlugins，如果插件有install方法就执行自己的install方法，否则如果plugin是一个function就执行这个方法，传参(this, args)
  initUse(Vue)
  // ./mixin.js 添加Vue.mixin方法，this.options = mergeOptions(this.options, mixin)，
  initMixin(Vue)
  // ./extend.js 添加Vue.cid（每一个够着函数实例都有一个cid，方便缓存），Vue.extend(options)方法
  initExtend(Vue)
  // ./assets.js 创建收集方法Vue[type] = function (id: string, definition: Function | Object)，其中type ： component / directive / filter
  initAssetRegisters(Vue)
}

```
Vue.util对象的部分解释：
* Vue.util.warn 
warn(msg, vm) 警告方法代码在util/debug.js，
通过var trac = generateComponentTrace(vm)方法vm=vm.$parent递归收集到msg出处。
然后判断是否存在console对象，如果有 console.error([Vue warn]: ${msg}${trace})。
如果config.warnHandle存在config.warnHandler.call(null, msg, vm, trace)
* Vue.util.extend
extend (to: Object, _from: ?Object):Object Object类型浅拷贝方法代码在shared/util.js
* Vue.util.mergeOptions

   合并，vue实例化和实现继承的核心方法，代码在shared/options.js
    mergeOptions (
     parent: Object,
     child: Object,
     vm?: Component
   ) 
   先通过normalizeProps、normalizeInject、normalizeDirectives以Object-base标准化，然后依据strats合并策略进行合并。
   strats是对data、props、watch、methods等实例化参数的合并策略。除此之外还有defaultStrat默认策略。
   后期暴露的mixin和Vue.extend()就是从这里出来的。
* Vue.util.defineReactive

   大家都知道的数据劫持核心方法，代码在shared/util.js
    defineReactive (
     obj: Object,
     key: string,
     val: any,
     customSetter?: ?Function,
     shallow?: boolean
   ) 

**参考资料**
[Vue2 源码漫游（一）](https://segmentfault.com/a/1190000011945068)
[入口开始，解读Vue源码（一）—— 造物创世](https://github.com/muwoo/blogs/blob/master/src/Vue/1.md)
[Vue技术内幕·内容更详细](http://hcysun.me/vue-design/art/)
[Vue源码的最后一站](https://zhuanlan.zhihu.com/p/37853734)
[Vue2.1.7源码学习](http://hcysun.me/2017/03/03/Vue%E6%BA%90%E7%A0%81%E5%AD%A6%E4%B9%A0/)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)