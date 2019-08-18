---
title: react源码分析之二：核心api
tags:
  - react
  - 源码分析
  - react源码
categories: react
top: false
copyright: true
date: 2019-06-22 17:18:28
---
核心的API，先看看有哪些用的最多的API，这些差不多 都定义在react中。
<!--more-->

## API
### createElement
```js
react/ReactElement.js
createElement(type, config, children)
 -> ReactElement = function(type, key, ref, self, source, owner, props){}
```

### Component
```js
import {Component, PureComponent} from './ReactBaseClasses';
function Component(props, context, updater){}

Component.prototype.setState = function(partialState, callback) {
  invariant(
    typeof partialState === 'object' ||
      typeof partialState === 'function' ||
      partialState == null,
    'setState(...): takes an object of state variables to update or a ' +
      'function which returns an object of state variables.',
  );
  // react-dom中去实现的
  this.updater.enqueueSetState(this, partialState, callback, 'setState');
};

function PureComponent(props, context, updater) {
  this.props = props;
  this.context = context;
  // If a component has string refs, we will assign a different object later.
  this.refs = emptyObject;
  this.updater = updater || ReactNoopUpdateQueue;
}

const pureComponentPrototype = (PureComponent.prototype = new ComponentDummy());
pureComponentPrototype.constructor = PureComponent;
// Avoid an extra prototype jump for these methods.
Object.assign(pureComponentPrototype, Component.prototype);
pureComponentPrototype.isPureReactComponent = true;
```

### ref
三种ref的使用方式
* string ref 不推荐，废弃
* function ref 
* createRef react提供了一个api


```js
// react/createReactRef.js
export function createRef(): RefObject {
  const refObject = {
    current: null,
  };
  if (__DEV__) {
    Object.seal(refObject);
  }
  return refObject;
}
```

### forwardRef
function component是没有实例的,可以用这个API进行传递
```js
// demo
React.forwardRef((props, ref)=>{})
```
源码文件
```js
// react/forwardRef.js
export default function forwardRef<Props, ElementType: React$ElementType>(
  render: (props: Props, ref: React$Ref<ElementType>) => React$Node,
) {
  return {
    $$typeof: REACT_FORWARD_REF_TYPE,
    render,
  };
}
```

### context
* childContextType
* createContext

```js
// react/ReactContext.js
  const context: ReactContext<T> = {
    $$typeof: REACT_CONTEXT_TYPE,
    _calculateChangedBits: calculateChangedBits,
    // As a workaround to support multiple concurrent renderers, we categorize
    // some renderers as primary and others as secondary. We only expect
    // there to be two concurrent renderers at most: React Native (primary) and
    // Fabric (secondary); React DOM (primary) and React ART (secondary).
    // Secondary renderers store their context values on separate fields.
    _currentValue: defaultValue,
    _currentValue2: defaultValue,
    // These are circular
    Provider: (null: any),
    Consumer: (null: any),
  };
```

### ConcurrentMode(16后比较让人振奋)
async-mode与sync-mode的区别

### Suspense
异步组件
```js
export function lazy<T, R>(ctor: () => Thenable<T, R>): LazyComponent<T> {
  return {
    $$typeof: REACT_LAZY_TYPE,
    _ctor: ctor,
    // React uses these fields to store the result.
    _status: -1,
    _result: null,
  };
}
```

### Hooks
useState
useEffect,根据第二个参数来判断是否需要更新，可以模拟出生命周期的效果。
```js
const ReactCurrentOwner = {
  /**
   * @internal
   * @type {ReactComponent}
   */
  current: (null: null | Fiber),
  currentDispatcher: (null: null | Dispatcher),
};
```

### children
props.children
```js
Children: {
    map, // 有返回，可以返回一个展开的数组
    forEach, // 返回原数组
    count,
    toArray,
    only,
  },
```

**参考资料**
[]()

![](http://static.zhyjor.com/wexin.png)