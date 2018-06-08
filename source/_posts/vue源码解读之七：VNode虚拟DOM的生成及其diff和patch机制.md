---
title: vue源码解读之七：VNode虚拟DOM的生成及其diff和patch机制
tags:
  - vue源码解读
  - vue
categories: vue
top: false
copyright: true
date: 2018-03-23 10:46:05
---
在前面的章节中，我们介绍了compile渲染template，完成了template --> AST --> render function 的过程。接下来让我们看看VNode的生成过程，以及将VNode转换为真实dom的patch过程。

<!--more-->

在我们之前看到的内容中，对model进行操作的时候，会触发对应的Dep中的Watcher对象。Watcher对象会调用对应的update来修改视图。最终的结果是产生新的VNode节点，新的VNode和旧的VNode会进行一个patch过程，对比过程得出差异diff，最终将diff更新到视图上。这就是从虚拟dom到dom的更新过程。

## VNode

### VNode是什么
先看源码
```js
// core/vdom/vnode.js

constructor (
    tag?: string,
    data?: VNodeData,
    children?: ?Array<VNode>,
    text?: string,
    elm?: Node,
    context?: Component,
    componentOptions?: VNodeComponentOptions,
    asyncFactory?: Function
  ) {
    this.tag = tag
    this.data = data
    this.children = children
    this.text = text
    this.elm = elm
    this.ns = undefined
    this.context = context
    this.functionalContext = undefined
    this.functionalOptions = undefined
    this.functionalScopeId = undefined
    this.key = data && data.key
    this.componentOptions = componentOptions
    this.componentInstance = undefined
    this.parent = undefined
    this.raw = false
    this.isStatic = false
    this.isRootInsert = true
    this.isComment = false
    this.isCloned = false
    this.isOnce = false
    this.asyncFactory = asyncFactory
    this.asyncMeta = undefined
    this.isAsyncPlaceholder = false
  }
```
包含了我们常用的一些标记节点的属性，为什么是VNode？其实网上已经有大量的资料可以了解到VNode的优势，比如大量副交互的性能优势，ssr的支持，跨平台Weex的支持...这里不再赘述。我们接下来看一下VNode的基本分类： 

![](http://oankigr4l.bkt.clouddn.com/201806081358_426.png)

比如我们创建一个 emptyVNode:
```js
// core/vdom/vnode.js

export const createEmptyVNode = (text: string = '') => {
  const node = new VNode()
  node.text = text
  node.isComment = true
  return node
}
```
比如一个 textVNode:
```js
// core/vdom/vnode.js

export function createTextVNode (val: string | number) {
  return new VNode(undefined, undefined, undefined, String(val))
}
```

### 生成 VNode
有了之前章节的知识，现在我们需要编译下面这段template

```html
<div id="app">
  <header>
    <h1>I'm a template!</h1>
  </header>
  <p v-if="message">
    {{ message }}
  </p>
  <p v-else>
    No message.
  </p>
</div>
```
得到这样的render function

```js
(function() {
  with(this){
    return _c('div',{   //创建一个 div 元素
      attrs:{"id":"app"}  //div 添加属性 id
      },[
        _m(0),  //静态节点 header，此处对应 staticRenderFns 数组索引为 0 的 render function
        _v(" "), //空的文本节点
        (message) //三元表达式，判断 message 是否存在
         //如果存在，创建 p 元素，元素里面有文本，值为 toString(message)
        ?_c('p',[_v("\n    "+_s(message)+"\n  ")])
        //如果不存在，创建 p 元素，元素里面有文本，值为 No message.
        :_c('p',[_v("\n    No message.\n  ")])
      ]
    )
  }
})
```

得到这样的render function

```js
(function() {
  with(this){
    return _c('div',{   //创建一个 div 元素
      attrs:{"id":"app"}  //div 添加属性 id
      },[
        _m(0),  //静态节点 header，此处对应 staticRenderFns 数组索引为 0 的 render function
        _v(" "), //空的文本节点
        (message) //三元表达式，判断 message 是否存在
         //如果存在，创建 p 元素，元素里面有文本，值为 toString(message)
        ?_c('p',[_v("\n    "+_s(message)+"\n  ")])
        //如果不存在，创建 p 元素，元素里面有文本，值为 No message.
        :_c('p',[_v("\n    No message.\n  ")])
      ]
    )
  }
})
```
要看懂上面的 render function，**只需要了解 _c，_m，_v，_s这几个函数的定义**，具体定义可以查看`flow/component.js`,其中 _c 是 createElement，_m 是 renderStatic，_v 是 createTextVNode，_s 是 toString。 我们在编译的过程中调用了vm._render() 方法，其中_render函数中有这样一句：

```js
// core/instance/render.js

const { render, _parentVnode } = vm.$options
...
vnode = render.call(vm._renderProxy, vm.$createElement)
```
也就是通过调用自身的render方法，传入$createElement方法来生成VNode节点。那么核心便在$createElement的方法上了。
```js
// src/core/vdom/create-elements.js

// wrapper function for providing a more flexible interface
// without getting yelled at by flow
export function createElement (
  context: Component,
  tag: any,
  data: any,
  children: any,
  normalizationType: any,
  alwaysNormalize: boolean
): VNode {
  // 兼容传递参数顺序
  if (Array.isArray(data) || isPrimitive(data)) {
    normalizationType = children
    children = data
    data = undefined
  }
  if (isTrue(alwaysNormalize)) {
    normalizationType = ALWAYS_NORMALIZE
  }
  // 调用_createElement创建虚拟节点
  return _createElement(context, tag, data, children, normalizationType)
}

export function _createElement (
  context: Component,
  tag?: string | Class<Component> | Function | Object,
  data?: VNodeData,
  children?: any,
  normalizationType?: number
): VNode {
  /**
   * 如果存在data.__ob__，说明data是被Observer观察的数据
   * 不能用作虚拟节点的data
   * 需要抛出警告，并返回一个空节点
   *
   * 被监控的data不能被用作vnode渲染的数据的原因是：
   * data在vnode渲染过程中可能会被改变，这样会触发监控，导致不符合预期的操作
   */
  if (isDef(data) && isDef((data: any).__ob__)) {
    process.env.NODE_ENV !== 'production' && warn(
      `Avoid using observed data object as vnode data: ${JSON.stringify(data)}\n` +
      'Always create fresh vnode data objects in each render!',
      context
    )
    return createEmptyVNode()
  }
  // object syntax in v-bind
  // 当通过 :is 动态设置组件时
  if (isDef(data) && isDef(data.is)) {
    tag = data.is
  }
  // 如果这里tag被设置成false或者不存在tag，创建一个空的节点。下面的注释应该是写错了...
  if (!tag) {
    // in case of component :is set to falsy value
    return createEmptyVNode()
  }
  // warn against non-primitive key
  if (process.env.NODE_ENV !== 'production' &&
    isDef(data) && isDef(data.key) && !isPrimitive(data.key)
  ) {
    warn(
      'Avoid using non-primitive value as key, ' +
      'use string/number value instead.',
      context
    )
  }
  // support single function children as default scoped slot
  // 作用域插槽
  if (Array.isArray(children) &&
    typeof children[0] === 'function'
  ) {
    data = data || {}
    data.scopedSlots = { default: children[0] }
    children.length = 0
  }
  // 根据normalizationType的值，选择不同的处理方法
  if (normalizationType === ALWAYS_NORMALIZE) {
    children = normalizeChildren(children)
  } else if (normalizationType === SIMPLE_NORMALIZE) {
    children = simpleNormalizeChildren(children)
  }
  let vnode, ns
  if (typeof tag === 'string') {
    let Ctor
    ns = (context.$vnode && context.$vnode.ns) || config.getTagNamespace(tag)
    // 如果是保留的标签，处理...
    if (config.isReservedTag(tag)) {
      // platform built-in elements
      vnode = new VNode(
        config.parsePlatformTagName(tag), data, children,
        undefined, undefined, context
      )
      // 如果不是保留标签，那么我们将尝试从vm的components上查找是否有这个标签的定义
    } else if (isDef(Ctor = resolveAsset(context.$options, 'components', tag))) {
      // component
      vnode = createComponent(Ctor, data, context, children, tag)
    } else {
      // unknown or unlisted namespaced elements
      // check at runtime because it may get assigned a namespace when its
      // parent normalizes children
      vnode = new VNode(
        tag, data, children,
        undefined, undefined, context
      )
    }
  } else {
    // 当tag不是字符串的时候，我们认为tag是组件的构造类
    // 所以直接创建
    // direct component options / constructor
    vnode = createComponent(tag, data, context, children)
  }
  // 经过上面的处理，如果能正常获得VNode，则返回，否则创建一个空的VNode
  if (isDef(vnode)) {
    if (ns) applyNS(vnode, ns)
    return vnode
  } else {
    return createEmptyVNode()
  }
}
```
经过上面的一系列过程，最终得到了我们的VNode，看起来是这样的: 

![](http://oankigr4l.bkt.clouddn.com/201806081427_834.png)

### 小结
render函数的执行，调用了createElement方法，其内部通过传入的相关参数，根据不同类型，一步步解析出了VNode。那么 VNode如果进行渲染成不同平台所需的内容呢？下篇我们将会继续介绍patch的工作。


## patch函数
通过前文的介绍，我们知道需要将VNode转换成真实的node节点，需要通过patch函数来实现：
```js
// src/core/instance/lifecycle.js

vm.$el = vm.__patch__(prevVnode, vnode)
```

而__patch__在下面代码中定义的:

```js
// src/platforms/web/runtime/index.js

Vue.prototype.__patch__ = inBrowser ? patch : noop
```
### createPatchFunction

这里主要是为了判断当前环境是否是在浏览器环境中，也就是是否存在Window对象。这里也是为了做跨平台的处理，如果是在server render环境，那么patch就是一个空操作。 我们接着去找render的实现：

```js
// src/core/vdom/patch.js

export function createPatchFunction (backend) {
  ...
  return function patch (oldVnode, vnode, hydrating, removeOnly, parentElm, refElm) {
      // 如果vnode不存在但oldVnode存在，则表示要移除旧的node
      // 那么就调用invokeDestroyHook(oldVnode)来进行销毁
      if (isUndef(vnode)) {
        if (isDef(oldVnode)) invokeDestroyHook(oldVnode)
        return
      }

      let isInitialPatch = false
      const insertedVnodeQueue = []
      // 如果oldVnode不存在，vnode存在，则创建新节点
      if (isUndef(oldVnode)) {
        isInitialPatch = true
        createElm(vnode, insertedVnodeQueue, parentElm, refElm)
      } else {
        // nodeType 节点的类型，详细：https://developer.mozilla.org/zh-CN/docs/Web/API/Node/nodeType
        const isRealElement = isDef(oldVnode.nodeType)
        // 如果oldVnode、vnode都存在
        // 如果oldVnode与Vnode是同一节点是就调用patchVnode处理去比较两个节点的差异
        if (!isRealElement && sameVnode(oldVnode, vnode)) {
          patchVnode(oldVnode, vnode, insertedVnodeQueue, removeOnly)
        } else {
          if (isRealElement) {
            // 如果存在真实的节点，存在data-server-rendered属性
            if (oldVnode.nodeType === 1 && oldVnode.hasAttribute(SSR_ATTR)) {
              oldVnode.removeAttribute(SSR_ATTR)
              hydrating = true
            }
            // 需要用hydrate函数将虚拟DOM和真实DOM进行映射
            if (isTrue(hydrating)) {
              if (hydrate(oldVnode, vnode, insertedVnodeQueue)) {
                invokeInsertHook(vnode, insertedVnodeQueue, true)
                return oldVnode
              }
              ...
            }
            // 如果不是server-rendered 或者hydration失败
            // 创建一个空VNode，代替oldVnode
            oldVnode = emptyNodeAt(oldVnode)
          }
          // 将oldVnode设置为对应的虚拟dom，找到oldVnode.elm的父节点
          // 根据vnode创建一个真实dom节点并插入到该父节点中oldVnode.elm的位置
          const oldElm = oldVnode.elm
          const parentElm = nodeOps.parentNode(oldElm)
          createElm(
            vnode,
            insertedVnodeQueue,
            oldElm._leaveCb ? null : parentElm,
            nodeOps.nextSibling(oldElm)
          )

          // 递归更新父级占位节点元素，
          if (isDef(vnode.parent)) {
           ...
          }

          // 销毁旧节点
          if (isDef(parentElm)) {
            removeVnodes(parentElm, [oldVnode], 0, 0)
          } else if (isDef(oldVnode.tag)) {
            invokeDestroyHook(oldVnode)
          }
        }
      }

      invokeInsertHook(vnode, insertedVnodeQueue, isInitialPatch)
      // 返回节点
      return vnode.elm
    }
}

```
这里通过createPatchFunction函数，来创建返回一个patch函数。path接收6个参数：
* oldVnode: 旧的虚拟节点或旧的真实dom节点
* vnode: 新的虚拟节点
* hydrating: 是否要跟真是dom混合
* removeOnly: 特殊flag，用于组件
* parentElm:父节点
* refElm: 新节点将插入到refElm之前 具体解析看代码注释~抛开调用生命周期钩子和销毁就节点不谈，我们发现代码中的关键在于sameVnode、 createElm 和 patchVnode 方法。

### sameVnode
判断2个节点，是否是同一个节点
```js
// src/core/vdom/patch.js

/**
 * 节点 key 必须相同
 * tag、注释、data是否存在、input类型是否相同
 * 如果isAsyncPlaceholder是true，则需要asyncFactory属性相同
 */
function sameVnode (a, b) {
  return (
    a.key === b.key && (
      (
        a.tag === b.tag &&
        a.isComment === b.isComment &&
        isDef(a.data) === isDef(b.data) &&
        sameInputType(a, b)
      ) || (
        isTrue(a.isAsyncPlaceholder) &&
        a.asyncFactory === b.asyncFactory &&
        isUndef(b.asyncFactory.error)
      )
    )
  )
}
```

### createElm
```js
// src/core/vdom/patch.js

function createElm (vnode, insertedVnodeQueue, parentElm, refElm, nested) {
  vnode.isRootInsert = !nested // for transition enter check
  // 用于创建组件，在调用了组件初始化钩子之后，初始化组件，并且重新激活组件。
  // 在重新激活组件中使用 insert 方法操作 DOM
  if (createComponent(vnode, insertedVnodeQueue, parentElm, refElm)) {
    return
  }

  const data = vnode.data
  const children = vnode.children
  const tag = vnode.tag
  if (isDef(tag)) {
    // 错误检测，主要用于判断是否正确注册了component，这个错误还是比较常见
    if (process.env.NODE_ENV !== 'production') {
      if (data && data.pre) {
        inPre++
      }
      if (
        !inPre &&
        !vnode.ns &&
        !(
          config.ignoredElements.length &&
          config.ignoredElements.some(ignore => {
            return isRegExp(ignore)
              ? ignore.test(tag)
              : ignore === tag
          })
        ) &&
        config.isUnknownElement(tag)
      ) {
        warn(
          'Unknown custom element: <' + tag + '> - did you ' +
          'register the component correctly? For recursive components, ' +
          'make sure to provide the "name" option.',
          vnode.context
        )
      }
    }

    // nodeOps 封装的操作dom的合集
    vnode.elm = vnode.ns
      ? nodeOps.createElementNS(vnode.ns, tag)
      : nodeOps.createElement(tag, vnode)
    setScope(vnode) // 用于为 scoped CSS 设置作用域 ID 属性

    // weex处理
    if (__WEEX__) {
      ...
    } else {

      // 用于创建子节点，如果子节点是数组，则遍历执行 createElm 方法.
      // 如果子节点的 text 属性有数据，则使用 nodeOps.appendChild(...) 在真实 DOM 中插入文本内容。
      createChildren(vnode, children, insertedVnodeQueue)
      if (isDef(data)) {
        invokeCreateHooks(vnode, insertedVnodeQueue)
      }
      // insert 用于将元素插入真实 DOM 中
      insert(parentElm, vnode.elm, refElm)
    }
    ...
  } else if (isTrue(vnode.isComment)) { // 注释
    vnode.elm = nodeOps.createComment(vnode.text)
    insert(parentElm, vnode.elm, refElm)
  } else { // 文本
    vnode.elm = nodeOps.createTextNode(vnode.text)
    insert(parentElm, vnode.elm, refElm)
  }
}
```
通过以上的注释，我们可以知道：createElm 方法的最终目的就是创建真实的 DOM 对象

### patchVnode
```js
// src/core/vdom/patch.js

function patchVnode (oldVnode, vnode, insertedVnodeQueue, removeOnly) {
  // 如果新老 vnode 相等
  if (oldVnode === vnode) {
    return
  }

  const elm = vnode.elm = oldVnode.elm
  // 异步占位
  if (isTrue(oldVnode.isAsyncPlaceholder)) {
    if (isDef(vnode.asyncFactory.resolved)) {
      hydrate(oldVnode.elm, vnode, insertedVnodeQueue)
    } else {
      vnode.isAsyncPlaceholder = true
    }
    return
  }

  // 复用新老节点被标记为static，新老节点key相同，新 vnode 是克隆所得；新 vnode 有 v-once 的属性
  // 如果新节点没有被克隆，这意味着渲染函数已经被hot-reload-api重置，我们需要做一个适当的重新渲染。
  if (isTrue(vnode.isStatic) &&
    isTrue(oldVnode.isStatic) &&
    vnode.key === oldVnode.key &&
    (isTrue(vnode.isCloned) || isTrue(vnode.isOnce))
  ) {
    vnode.componentInstance = oldVnode.componentInstance
    return
  }

  let i
  const data = vnode.data
  // 执行 data.hook.prepatch 钩子
  if (isDef(data) && isDef(i = data.hook) && isDef(i = i.prepatch)) {
    i(oldVnode, vnode)
  }

  const oldCh = oldVnode.children
  const ch = vnode.children
  if (isDef(data) && isPatchable(vnode)) {
    // 遍历调用 cbs.update 钩子函数
    for (i = 0; i < cbs.update.length; ++i) cbs.update[i](oldVnode, vnode)
    // 执行 data.hook.update 钩子
    if (isDef(i = data.hook) && isDef(i = i.update)) i(oldVnode, vnode)
  }
  // 旧 vnode 的 text 选项为 undefined
  if (isUndef(vnode.text)) {
    if (isDef(oldCh) && isDef(ch)) {
      // 新老节点的 children 不同，执行 updateChildren 方法。
      if (oldCh !== ch) updateChildren(elm, oldCh, ch, insertedVnodeQueue, removeOnly)
    } else if (isDef(ch)) {
      // 旧 vnode children 不存在 执行 addVnodes 方法
      if (isDef(oldVnode.text)) nodeOps.setTextContent(elm, '')
      addVnodes(elm, null, ch, 0, ch.length - 1, insertedVnodeQueue)
    } else if (isDef(oldCh)) {
      // 新 vnode children 不存在 执行 removeVnodes 方法
      removeVnodes(elm, oldCh, 0, oldCh.length - 1)
    } else if (isDef(oldVnode.text)) {
      // 如果新旧 vnode 都是 undefined，且老节点存在 text，清空文本
      nodeOps.setTextContent(elm, '')
    }
  } else if (oldVnode.text !== vnode.text) {
    // 新老节点文本不同，更新文本内容
    nodeOps.setTextContent(elm, vnode.text)
  }
  if (isDef(data)) {
    // 执行 data.hook.postpatch 钩子，至此 patch 完成
    if (isDef(i = data.hook) && isDef(i = i.postpatch)) i(oldVnode, vnode)
  }
}
```
让我们来画张图屡一下大致的流程： 
![](http://oankigr4l.bkt.clouddn.com/201806081456_806.png)

## 图解diff算法
addVnodes和removeVnodes都比较好理解，一个是增加一个节点元素，一个是删除节点元素。主要来看一下updateChildren方法。
### updateChildren源码
源码如下
```js
// src/core/vdom/patch.js

  function updateChildren (parentElm, oldCh, newCh, insertedVnodeQueue, removeOnly) {
    // 1. 定义初始变量
    let oldStartIdx = 0// 旧列表起点位置
    let newStartIdx = 0// 新列表起点位置
    let oldEndIdx = oldCh.length - 1// 旧列表终点位置
    let oldStartVnode = oldCh[0]// 旧列表起点值
    let oldEndVnode = oldCh[oldEndIdx]// 旧列表终点值
    let newEndIdx = newCh.length - 1// 新列表终点位置
    let newStartVnode = newCh[0]// 新列表起点值
    let newEndVnode = newCh[newEndIdx]// 新列表终点值
    let oldKeyToIdx, idxInOld, vnodeToMove, refElm

    // removeOnly is a special flag used only by <transition-group>
    // to ensure removed elements stay in correct relative positions
    // during leaving transitions
    const canMove = !removeOnly

    // 2. 定义循环
    // 进行循环遍历，遍历条件为 oldStartIdx <= oldEndIdx 和
    // newStartIdx <= newEndIdx，在遍历过程中，oldStartIdx 和 newStartIdx 递增，
    // oldEndIdx 和 newEndIdx 递减。当条件不符合跳出遍历循环
    while (oldStartIdx <= oldEndIdx && newStartIdx <= newEndIdx) {
      // 3. oldStartVnode、oldEndVnode 存在检测
      // 如果oldStartVnode不存在，oldCh起始点向后移动。
      // 如果oldEndVnode不存在，oldCh终止点向前移动。
      if (isUndef(oldStartVnode)) {
        oldStartVnode = oldCh[++oldStartIdx] // Vnode has been moved left
      } else if (isUndef(oldEndVnode)) {
        oldEndVnode = oldCh[--oldEndIdx]
      // 4. oldStartVnode 和 newStartVnode 是 sameVnode
      // 如果oldStartVnode 和 newStartVnode 是sameVnode，则patchVnode，同时彼此向后移动一位
      } else if (sameVnode(oldStartVnode, newStartVnode)) {
        patchVnode(oldStartVnode, newStartVnode, insertedVnodeQueue)
        oldStartVnode = oldCh[++oldStartIdx]
        newStartVnode = newCh[++newStartIdx]
      //  5. oldEndVnode 和 newEndVnode 是 sameVnode
      // 如果oldEndVnode 和 newEndVnode 是sameVnode，则patchVnode，
        // 同时彼此向前移动一位
      } else if (sameVnode(oldEndVnode, newEndVnode)) {
        patchVnode(oldEndVnode, newEndVnode, insertedVnodeQueue)
        oldEndVnode = oldCh[--oldEndIdx]
        newEndVnode = newCh[--newEndIdx]
      //  6. oldStartVnode 和 newEndVnode 是 sameVnode
      //  如果oldStartVnode 和 newEndVnode 是 sameVnode，则先 patchVnode，
        // 然后把oldStartVnode移到oldCh最后的位置即可，
        // 然后oldStartIdx向后移动一位，newEndIdx向前移动一位
      } else if (sameVnode(oldStartVnode, newEndVnode)) { // Vnode moved right
        patchVnode(oldStartVnode, newEndVnode, insertedVnodeQueue)
        canMove && nodeOps.insertBefore(parentElm, oldStartVnode.elm, nodeOps.nextSibling(oldEndVnode.elm))
        oldStartVnode = oldCh[++oldStartIdx]
        newEndVnode = newCh[--newEndIdx]
      //  7. oldEndVnode 和 newStartVnode 是 sameVnode
      //  如果oldEndVnode 和 newStartVnode 是 sameVnode，则先 patchVnode，
        // 然后把oldEndVnode移到oldCh最前的位置即可，
        // 然后newStartIdx向后移动一位，oldEndIdx向前移动一位
      } else if (sameVnode(oldEndVnode, newStartVnode)) { // Vnode moved left
        patchVnode(oldEndVnode, newStartVnode, insertedVnodeQueue)
        canMove && nodeOps.insertBefore(parentElm, oldEndVnode.elm, oldStartVnode.elm)
        oldEndVnode = oldCh[--oldEndIdx]
        newStartVnode = newCh[++newStartIdx]
      //  8. 如果没有相同的 key，执行 createElm 方法创建元素。
      //  如果以上条件都不匹配，则查找oldVnode中与vnode具有相同key的节点，
        // 并将查找的结果赋值给elmToMove。如果找不到相同key的节点，
        // 则表示是新创建的节点
      } else {
        if (isUndef(oldKeyToIdx)) oldKeyToIdx = createKeyToOldIdx(oldCh, oldStartIdx, oldEndIdx)
        idxInOld = isDef(newStartVnode.key)
          ? oldKeyToIdx[newStartVnode.key]
          : findIdxInOld(newStartVnode, oldCh, oldStartIdx, oldEndIdx)
        if (isUndef(idxInOld)) { // New element
          createElm(newStartVnode, insertedVnodeQueue, parentElm, oldStartVnode.elm)
        } else {
          // 9. 如果有相同的 key，就判断这两个节点是否为sameNode
          // 若为同一类型就调用patchVnode，就将对应下标处的oldVnode设置为undefined，
          // 把vnodeToMove插入到oldCh之前，newStartIdx继续向后移动。
          // 如果两个 vnode 不相似，视为新元素，执行 createElm创建。
          vnodeToMove = oldCh[idxInOld]
          /* istanbul ignore if */
          if (process.env.NODE_ENV !== 'production' && !vnodeToMove) {
            warn(
              'It seems there are duplicate keys that is causing an update error. ' +
              'Make sure each v-for item has a unique key.'
            )
          }
          if (sameVnode(vnodeToMove, newStartVnode)) {
            patchVnode(vnodeToMove, newStartVnode, insertedVnodeQueue)
            oldCh[idxInOld] = undefined
            canMove && nodeOps.insertBefore(parentElm, vnodeToMove.elm, oldStartVnode.elm)
          } else {
            // same key but different element. treat as new element
            createElm(newStartVnode, insertedVnodeQueue, parentElm, oldStartVnode.elm)
          }
        }
        newStartVnode = newCh[++newStartIdx]
      }
    }
    // 10. 如果老 vnode 数组的开始索引大于结束索引，说明新 node
    // 数组长度大于老 vnode 数组，执行 addVnodes 方法添加这些新 vnode 到 DOM 中
    if (oldStartIdx > oldEndIdx) {
      refElm = isUndef(newCh[newEndIdx + 1]) ? null : newCh[newEndIdx + 1].elm
      addVnodes(parentElm, refElm, newCh, newStartIdx, newEndIdx, insertedVnodeQueue)
    // 11. 如果老 vnode 数组的开始索引小于结束索引，
      // 说明老 node 数组长度大于新 vnode 数组，
      // 执行 removeVnodes 方法从 DOM 中移除老 vnode 数组中多余的 vnode。
    } else if (newStartIdx > newEndIdx) {
      removeVnodes(parentElm, oldCh, oldStartIdx, oldEndIdx)
    }
  }

```

### 图解updat过程

**定义初始**
![](http://oankigr4l.bkt.clouddn.com/201806081519_555.png)

**如果oldStartVnode 和 newStartVnode 是sameVnode，则patchVnode，同时彼此向后移动一位 **

![](http://oankigr4l.bkt.clouddn.com/201806081545_205.png)

**5555如果oldEndVnode 和 newEndVnode 是sameVnode，则patchVnode，同时彼此向前移动一位 **

![](http://oankigr4l.bkt.clouddn.com/201806081544_856.png)

**如果oldStartVnode 和 newEndVnode 是 sameVnode，则先 patchVnode，然后把oldStartVnode移到oldCh最后的位置即可，然后oldStartIdx向后移动一位，newEndIdx向前移动一位 **


![](http://oankigr4l.bkt.clouddn.com/201806081543_418.png)

**如果oldEndVnode 和 newStartVnode 是 sameVnode，则先 patchVnode，然后把oldEndVnode移到oldCh最前的位置即可，然后newStartIdx向后移动一位，oldEndIdx向前移动一位 **

![](http://oankigr4l.bkt.clouddn.com/201806081527_313.png)

**若为同一类型就调用patchVnode，就将对应下标处的oldVnode设置为undefined，把vnodeToMove插入到oldCh之前，newStartIdx继续向后移动。如果两个 vnode 不相似，视为新元素，执行 createElm创建。 **

![](http://oankigr4l.bkt.clouddn.com/201806081531_194.png)

**如果老 vnode 数组的开始索引大于结束索引，说明新 node 数组长度大于老 vnode 数组，执行 addVnodes 方法添加这些新 vnode 到 DOM 中**

![](http://oankigr4l.bkt.clouddn.com/201806081533_551.png)

**如果老 vnode 数组的开始索引小于结束索引，说明老 node 数组长度大于新 vnode 数组，执行 removeVnodes 方法从 DOM 中移除老 vnode 数组中多余的 vnode。**

![](http://oankigr4l.bkt.clouddn.com/201806081534_869.png)

## 总结

到这里，patch的主要功能也基本讲完了，我们发现，在本篇中，大量出现了一个key字段。经过上面的调研，其实我们已经知道Vue的diff算法中其核心是基于两个简单的假设：

* 两个相同的组件产生类似的DOM结构，不同的组件产生不同的DOM结构
* 同一层级的一组节点，他们可以通过唯一的id进行区分 基于以上这两点假设，使得虚拟DOM的Diff算法的复杂度从O(n^3)降到了O(n)，当页面的数据发生变化时，Diff算法只会比较同一层级的节点：

![](http://oankigr4l.bkt.clouddn.com/201806081537_580.png)

如果节点类型不同，直接干掉前面的节点，再创建并插入新的节点，不会再比较这个节点以后的子节点了。如果节点类型相同，则会重新设置该节点的属性，从而实现节点的更新。当某一层有很多相同的节点时，也就是列表节点时，Diff算法的更新过程默认情况下也是遵循以上原则。 比如一下这个情况：

![](http://oankigr4l.bkt.clouddn.com/201806081538_812.png)

我们希望可以在B和C之间加一个F，Diff算法默认执行起来是这样的：

![](http://oankigr4l.bkt.clouddn.com/201806081538_638.png)

即把C更新成F，D更新成C，E更新成D，最后再插入E，是不是很没有效率？ 所以我们需要使用key来给每个节点做一个唯一标识，Diff算法就可以正确的识别此节点，找到正确的位置区插入新的节点。

![](http://oankigr4l.bkt.clouddn.com/201806081539_973.png)

所以一句话，**key的作用主要是为了高效的更新虚拟DOM**。另外vue中在使用相同标签名元素的过渡切换时，也会使用到key属性，其目的也是为了让vue可以区分它们，否则vue只会替换其内部属性而不会触发过渡效果。

**参考资料**
[Vue2.0 v-for 中 :key 到底有什么用？](https://www.zhihu.com/question/61064119/answer/183717717)
[Vue.js 源码学习六 —— VNode虚拟DOM学习](https://violetjack.github.io/2018/02/22/Vue.js%E6%BA%90%E7%A0%81%E5%AD%A6%E4%B9%A0%E5%85%AD%20%E2%80%94%E2%80%94%20VNode%E8%99%9A%E6%8B%9FDOM%E5%AD%A6%E4%B9%A0/)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)