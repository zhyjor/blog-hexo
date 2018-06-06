---
title: vue源码解读之三：响应式原理以及实现一个基础的vue双向绑定
tags:
  - vue源码解读
  - vue
categories: vue
top: false
copyright: true
date: 2018-03-08 14:50:57
---

<!--more-->
在我们一个个了解之前，首选我们需要了解一下响应式数据原理，也就是我们常说的：订阅-发布 模式。
## vue响应式原理
这个是官网的结构图
![](http://oankigr4l.bkt.clouddn.com/201805181642_452.png)
再大概看看下图，简单画出一个响应式结构图，先从 Observer 开始谈起
![](http://oankigr4l.bkt.clouddn.com/201806061457_878.png)

### observe

先看一下响应式这块的源码结构：

![](http://oankigr4l.bkt.clouddn.com/201806061517_638.png)

源码内容如下：
```js
// core/observer/index
/**
 * Observer class that are attached to each observed
 * object. Once attached, the observer converts target
 * object's property keys into getter/setters that
 * collect dependencies and dispatches updates.
 */
export class Observer {
  value: any;
  dep: Dep;
  vmCount: number; // number of vms that has this object as root $data

  constructor (value: any) {
    this.value = value
    this.dep = new Dep()
    this.vmCount = 0
    def(value, '__ob__', this)
    if (Array.isArray(value)) {
      const augment = hasProto
        ? protoAugment
        : copyAugment
      augment(value, arrayMethods, arrayKeys)
      this.observeArray(value)
    } else {
      this.walk(value)
    }
  }

  /**
   * Walk through each property and convert them into
   * getter/setters. This method should only be called when
   * value type is Object.
   */
  walk (obj: Object) {
    const keys = Object.keys(obj)
    for (let i = 0; i < keys.length; i++) {
      defineReactive(obj, keys[i], obj[keys[i]])
    }
  }

  /**
   * Observe a list of Array items.
   */
  observeArray (items: Array<any>) {
    for (let i = 0, l = items.length; i < l; i++) {
      observe(items[i])
    }
  }
}
```
当我们调用new Observer(value)的时候，会去执行this.walk(value)这个方法，其功能主要是遍历value的属性，通过**`Object.defineProperty`**方法来定义响应式数据。那么是如何实现响应通知的呢？来看一下他的具体代码：
```js
/**
 * Define a reactive property on an Object.
 */
export function defineReactive (
  obj: Object,
  key: string,
  val: any,
  customSetter?: ?Function,
  shallow?: boolean
) {
  // 这是订阅器，初始化，这里其实需要了解一下为什么需要这个订阅器，
  // 多处依赖的问题
  const dep = new Dep()

  const property = Object.getOwnPropertyDescriptor(obj, key)
  if (property && property.configurable === false) {
    return
  }

  // cater for pre-defined getter/setters
  const getter = property && property.get
  const setter = property && property.set

  let childOb = !shallow && observe(val)
  Object.defineProperty(obj, key, {
    enumerable: true,
    configurable: true,
    get: function reactiveGetter () {
      const value = getter ? getter.call(obj) : val
      if (Dep.target) {
        // 依赖收集
        dep.depend()
        if (childOb) {
          childOb.dep.depend()
          if (Array.isArray(value)) {
            dependArray(value)
          }
        }
      }
      return value
    },
    set: function reactiveSetter (newVal) {
      const value = getter ? getter.call(obj) : val
      /* eslint-disable no-self-compare */
      if (newVal === value || (newVal !== newVal && value !== value)) {
        return
      }
      /* eslint-enable no-self-compare */
      if (process.env.NODE_ENV !== 'production' && customSetter) {
        customSetter()
      }
      if (setter) {
        setter.call(obj, newVal)
      } else {
        val = newVal
      }
      childOb = !shallow && observe(newVal)
      // 通知
      dep.notify()
    }
  })
}
```
这里其实就是我们**依赖收集的订阅器**，主要做了两件事
* dep.depend()
* dep.notify()

接下来详细看一下Dep class的实现。

### Dep
通过响应式原理图，我们可以知道，**Dom上通过指令或者大括号绑定的数据，会为数据添加观察者watcher**,当实例化Watcher的时候，会触发属性的getter方法，此时会调用dep.depend()。可以看一下Dep的源码：
```js
// core/observer/dep
/**
 * A dep is an observable that can have multiple
 * directives subscribing to it.
 */
export default class Dep {
  static target: ?Watcher;
  id: number;
  subs: Array<Watcher>;

  constructor () {
    this.id = uid++
    this.subs = []
  }

  addSub (sub: Watcher) {
    this.subs.push(sub)
  }

  removeSub (sub: Watcher) {
    remove(this.subs, sub)
  }

  depend () {
    if (Dep.target) {
      Dep.target.addDep(this)
    }
  }

  notify () {
    // stabilize the subscriber list first
    const subs = this.subs.slice()
    for (let i = 0, l = subs.length; i < l; i++) {
      subs[i].update()
    }
  }
}

// the current target watcher being evaluated.
// this is globally unique because there could be only one
// watcher being evaluated at any time.
Dep.target = null
const targetStack = []

export function pushTarget (_target: Watcher) {
  if (Dep.target) targetStack.push(Dep.target)
  Dep.target = _target
}

export function popTarget () {
  Dep.target = targetStack.pop()
}

```
这里可能会有点疑问：什么是Dep.target，这个其实是在watcher初始化的时候给其赋值的，如下;一直传递到依赖收集的位置
```js
// core/observer/watcher
 /**
   * Evaluate the getter, and re-collect dependencies.
   */
  get () {
    pushTarget(this)
  ...
}
```

### Watcher
其中pushTarget 方法就是为Dep.target绑定此watcher实例，所以Dep.target.addDep(this)也就是执行此实例中的addDep方法.
```js
// core/observer/watcher

addDep (dep: Dep) {
  ...
  dep.addSub(this)
}
```
这样我们就给dep实例添加了一个watcher实例，接着当我们更新data的时候，会触发他的set方法，执行dep.notify()方法。
```js
// core/observer/watcher

notify () {
  // stabilize the subscriber list first
  const subs = this.subs.slice()
  for (let i = 0, l = subs.length; i < l; i++) {
    subs[i].update()
  }
}
```
这里遍历dep中收集到的watcher实例，集中进行update()，进行数据更新操作。这就是响应式原理。
另外当数据的getter触发后，会收集依赖，但是不是所有的触发方式都会收集依赖，只有通过watcher触发的getter触发的getter才会收集依赖：`if (Dep.target) { dep.depend() }`,而所谓的被收集的依赖就是当前的watcher，DOM中的数据必须通过watcher来绑定，只通过watcher来读取。

## 双向绑定的简单实现
当然说了这么多最好还是上手实践，现在实现一个简单的vue：[lite-vue]()，虽然是简单的实践，各种功能还是必须要有的。
* 实现$options参数处理
* 实现observer数据劫持
* 实现dep订阅器
* 实现watcher观察者
* 实现基础的compile编译

### $options参数处理
首先，明确的是我们需要实现一个对象，该对象接受一个object类型的参数来提供初始化，按照Vue的思想，首先需要构建实例上的$options参数，这里我们简化一下：
```js
class Vue {
  constructor (options) {
    const vm = this
    vm.$options = options
    ...
  }
}
```
### observer数据劫持
数据劫持，前面已经说过了，我们需要为我们的定义的data参数进行observer:
```js
class Vue {
  constructor (options) {
    const vm = this
    vm.$options = options
    let data = vm._data = vm.$options.data
    observer(vm._data)
    ...
  }
}
```
observer的主要功能是对传入的数据进行过滤，判断是否需要进行数据劫持：
```js
function observer(value) {
  // 如果不是对象的话就直接return掉
  if (!value || typeof value !== 'object') {
    return
  }
  return new Observer(value)
}
```
那么接下来就是去实现Observer类了，这里，为了更加简洁，我们暂时只考虑传入的value是一个普通的对象：
```js
class Observer {
  constructor (value) {
    this.walk(value)
  }

  walk (obj) {
    Object.keys(obj).forEach((key) => {
      // 如果是对象，则递归调用walk，保证每个属性都可以被defineReactive
      if (typeof obj[key] === 'object') {
        this.walk(obj[key])
      }
      defineReactive(obj, key, obj[key])
    })
  }
}

let defineReactive = (obj, key, value) => {
  ...
  Object.defineProperty(obj, key, {
    set (newVal) {
      if (newVal === value) {
        return
      }
      value = newVal
      // 当设置的属性是个对象，也需要继续进行observe
      observe(newVal)
      ...
    },
    get () {
      ...
      return value
    }
  })
}
```
到这里，我们的数据劫持，基本上完成了，可以来调试一下：
```js
let app = new Vue({
  el: '#app',
  data: {
    msg: 'hello wue',
    deep: {
      a: 1,
      b: 2
    }
  }
})
```
![](http://oankigr4l.bkt.clouddn.com/201806061557_490.png)
到这里，我们访问属性是通过this._data.xxx 这样不是很优雅，所以，我们需要设置一层代理，也就是重新进行一次数据访问拦截。当我们访问this.xxx就可以了：
```js
proxy (target, sourceKey, key) {
  Object.defineProperty(target, key, {
    configurable: true,
    get: function proxyGetter () {
      return target[sourceKey][key]
    },
    set: function proxySetter (newVal) {
      target[sourceKey][key] = newVal
    }
  })
}

export default class Vue {
  constructor (options) {
    let vm = this
    ...
    for (let key in vm._data) {
      proxy(vm, '_data', key)
    }
    ...
  }
}
```
### 实现Dep订阅器 和 Watcher 订阅者
订阅-发布模式，就像买房的中介一样。我们（watcher）去买房，不可能天天去房地产开发商那边去问有没有房源，我们更多的是找一个中介（dep），然后把我们的需求和联系方式告诉中介（dep.depend()），中介一旦有满足需求的房源，便会打电话来通知我们dep.notify() 根据上面的描述，我们大概清楚了，我们需要一个订阅器Dep，同时，Dep需要有收集需求和联系方式的功能，也需要有打电话通知的功能：
```js
export default class Dep {
  constructor () {
    // 消息盒子，联系人
    this.sub = []
  }
  addDepend () {
    Dep.target.addDep(this)
  }
  addSub (sub) {
    this.sub.push(sub)
  }
  // 通知
  notify () {
    for (let sub of this.sub) {
      sub.update()
    }
  }
}
```
紧接着，我们也需要一个Watcher，其中包含接受通知的功能，以及建立与中介dep的关联:
```js
export default class Watcher {
  constructor (vm, expression, cb) {
    this.vm = vm
    this.cb = cb
    this.expression = expression
    this.value = this.getVal()
  }
  getVal () {
    pushTarget(this) // 建立关联

    // 这里取值，会触发value的get方法，所以接下来我们需要在get方法里面将联系人的联系方式给中介
    let val = this.vm
    this.expression.split('.').forEach((key) => {
      val = val[key]
    })

    popTarget() // 释放关联
    return val
  }

  // 联系人把自己的联系方式给中介
  addDep (dep) {
    dep.addSub(this)
  }

  // 接收到消息后，开始准备活动。。。
  update () {
    let val = this.vm
    this.expression.split('.').forEach((key) => {
      val = val[key]
    })
    this.cb.call(this.vm, val, this.value)
  }
}
```
说到这里，我们知道了，还有2步没有去做：
* 收集联系方式
* 通知 那我们什么时候去收集联系方式呢，答案很简单：那就是我们主动询问中介的时候，中介会向我们要我们的联系方式：

```js
...
get () {
  // 如果建立了关联，那么开始添加联系方式
  if (Dep.target) {
    dep.addDepend()
  }
  return value
}
...
```
那什么时候通知顾客呢？很简单：当有房产更新的时候：
```js
set () {
  dep.notify()
}
```
到这里，我们以一个例子，简单的描述了这之间的过程。现在我们已经实现了一个简单的发布-订阅方式了。

### 实现基础的compile编译
options中的el 参数，为我们指定了我们需要编译哪些内容，而我们要做的仅仅是解析出通过v-model、v-text、{{}}等等标识和指令。然后获取绑定数据的值，替换掉标识的内容，并进行数据的变化监听watcher。 当再有值发生变化时，可以及时通知其修改对应dom元素。说到这里，我们开干：
```js
export default class compiler {
  constructor (el, vm) {
    vm.$el = document.querySelector(el)
    this.replace(vm.$el, vm)
  }
  replace (frag, vm) {
    Array.from(frag.childNodes).forEach(node => {
      let txt = node.textContent;
      // 正则匹配{{}}
      let reg = /\{\{(.*?)\}\}/g;
      // 如果是文本节点，且包含{{}}
      if (node.nodeType === 3 && reg.test(txt)) {
        let arr = RegExp.$1.split('.');
        let val = vm;
        arr.forEach(key => {
          val = val[key];
        });
        node.textContent = txt.replace(reg, val).trim();
        vm.$watch(RegExp.$1, function (newVal) {
          node.textContent = txt.replace(reg, newVal).trim();
        })
      }
      // 如果是元素节点
      if (node.nodeType === 1) {
        let nodeAttr = node.attributes;
        Array.from(nodeAttr).forEach(attr => {
          let name = attr.name;
          let exp = attr.value;
          // 如果是通过 v- 指令绑定的元素，则设置节点的value为绑定的相应的值
          if (name.includes('v-')){
            node.value = vm[exp];
          }
          // 监听变化
          vm.$watch(exp, function(newVal) {
            node.value = newVal;
          });

          node.addEventListener('input', e => {
            let newVal = e.target.value;
            let arr = exp.split('.')
            let val = vm;
            // 考虑到 v-model="deep.a" 这种情况
            arr.forEach((key, i)=> {
              if (i === arr.length - 1) {
                val[key] = newVal
                return
              }
              val = val[key];
            });
          });
        });
      }

      // 如果还有子节点，继续递归replace
      if (node.childNodes && node.childNodes.length) {
        this.replace(node, vm);
      }
    })
  }
}
```
到这里，我们便实现了一个简单的双向数据绑定：
**数据 ————> Dom**
* 通过compile解析指令和数据，为其添加watcher
* 当watcher触发对应的get方法时，为其进行依赖收集，把对应的watcher进行收集
* 当数据发生变化的时候，触发set方法，使其通知watcher进行视图更新。

**Dom ————> 数据**
* 通过compile解析指令和数据
* 监听Dom input等更新动作，当触发dom更新时，在对应回调函数中更新实例vm中的数据值

### 后续
顺便，我们实现以下钩子函数功能：
```js
export function callHook (vm, hook) {
  const handlers = vm.$options[hook]
  if (handlers) {
    handlers.call(vm)
  }
}
```

**参考资料**
[非常不错·不好意思！耽误你的十分钟，让MVVM原理还给你](https://juejin.im/post/5abdd6f6f265da23793c4458)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)