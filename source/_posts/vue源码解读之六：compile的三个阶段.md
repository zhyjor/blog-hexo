---
title: vue源码解读之六：compile的三个阶段
tags:
  - vue源码解读
  - vue
categories: vue
top: false
copyright: true
date: 2018-03-20 10:43:58
---
template模板通过compile编译，最终得到render function，这里不是响应式式核心的内容，但是可以了解其大概的流程。compile主要分了parse、optimize、generate三个阶段。
<!--more-->
借一张图表示一下编译的三个阶段如下：
![](http://oankigr4l.bkt.clouddn.com/201806071047_559.png)

## parse函数生成AST
compile 函数（src/compiler/index.js）就是将 template 编译成 render function 的字符串形式。
```js
// src/compiler/index.js

// 1.parse
  const ast = parse(template.trim(), options)
```
接下来就详细讲解这个函数：

```js
// src/compiler/index

// `createCompilerCreator` allows creating compilers that use alternative
// parser/optimizer/codegen, e.g the SSR optimizing compiler.
// Here we just export a default compiler using the default parts.
export const createCompiler = createCompilerCreator(function baseCompile (
  template: string,
  options: CompilerOptions
): CompiledResult {
  // 1.parse
  const ast = parse(template.trim(), options)
  // 2.optimize
  optimize(ast, options)
  // 3.generate
  const code = generate(ast, options)
  return {
    ast,
    render: code.render,
    staticRenderFns: code.staticRenderFns
  }
})
```
createCompiler 函数主要通过3个步骤：parse、optimize、generate来生成一个包含ast、render、staticRenderFns的对象。

### parse函数

#### AST
在说parse函数之前，我们先来了解一个概念：AST(Abstract Syntax Tree)抽象语法树:
> AST 的全称是 Abstract Syntax Tree（抽象语法树），是源代码的抽象语法结构的树状表现形式，计算机学科中编译原理的概念。Vue 源码中借鉴 jQuery 作者 John Resig 的 HTML Parser 对模板进行解析，得到的就是 AST 代码。

接着我们看一下Vue中对AST数据的定义：
```js
// 为什么在flow文件夹下
// vue/flow/compiler

declare type ASTNode = ASTElement | ASTText | ASTExpression;

declare type ASTElement = {
  type: 1;
  tag: string;
  attrsList: Array<{ name: string; value: string }>;
  attrsMap: { [key: string]: string | null };
  parent: ASTElement | void;
  children: Array<ASTNode>;
  ...
}

declare type ASTExpression = {
  type: 2;
  expression: string;
  text: string;
  static?: boolean;
  // 2.4 ssr optimization
  // 2.4+ 增加了对ssr的标识
  ssrOptimizability?: number;
};

declare type ASTText = {
  type: 3;
  text: string;
  static?: boolean;
  isComment?: boolean;
  // 2.4 ssr optimization
  // 2.4+ 增加了对ssr的标识
  ssrOptimizability?: number;
};
```
可以看到 ASTNode 有三种形式：ASTElement，ASTExpression，ASTText。通过属性type来进行标识。 

#### 函数功能

下面我们正式进入parse函数功能：
```js
// src/compiler/parser/index

function parse(template) {
    ...
    const stack = [];
    let currentParent;    //当前父节点
    let root;            //最终返回出去的AST树根节点
    ...
    parseHTML(template, {
        start: function start(tag, attrs, unary) {
           ......
        },
        end: function end() {
          ......
        },
        chars: function chars(text) {
           ......
        }
    })
    return root
}
```
我们省略了parse的相关内容，只看一下大体的功能，其主要的功能函数应该是parseHTML方法。接受了2个参数，一个使我们的模板template，另一个是包含start、end、chars的方法。 

#### 相关正则表达式
在看parseHTML之前，我们需要先了解一下下面这几个正则：
```js
// src/compiler/parser/html-parser.js

// 该正则式可匹配到 <div id="index"> 的 id="index" 属性部分
const attribute = /^\s*([^\s"'<>\/=]+)(?:\s*(=)\s*(?:"([^"]*)"+|'([^']*)'+|([^\s"'=<>`]+)))?/
const ncname = '[a-zA-Z_][\\w\\-\\.]*'
const qnameCapture = `((?:${ncname}\\:)?${ncname})`
// 匹配起始标签
const startTagOpen = new RegExp(`^<${qnameCapture}`)
const startTagClose = /^\s*(\/?)>/
// 匹配结束标签
const endTag = new RegExp(`^<\\/${qnameCapture}[^>]*>`)
// 匹配DOCTYPE、注释等特殊标签
const doctype = /^<!DOCTYPE [^>]+>/i
const comment = /^<!\--/
const conditionalComment = /^<!\[/
```
Vue 通过上面几个正则表达式去匹配开始结束标签、标签名、属性等等。

#### parseHtml函数
有了上面这些基础，我们再来看看parseHtml的内部实行：
```js
// src/compiler/parser/html-parser.js

export function parseHTML (html, options) {
  const stack = []
  const expectHTML = options.expectHTML
  const isUnaryTag = options.isUnaryTag || no
  const canBeLeftOpenTag = options.canBeLeftOpenTag || no
  let index = 0
  let last, lastTag
  while (html) {
    // 保留 html 副本
    last = html
    // 如果没有lastTag，并确保我们不是在一个纯文本内容元素中：script、style、textarea
    if (!lastTag || !isPlainTextElement(lastTag)) {
      let textEnd = html.indexOf('<')
      if (textEnd === 0) {
        // Comment:
        if (comment.test(html)) {
          ...
        }
        if (conditionalComment.test(html)) {
          ...
        }
        // Doctype:
        const doctypeMatch = html.match(doctype)
        if (doctypeMatch) {
          ...
        }
        // End tag:
        const endTagMatch = html.match(endTag)
        if (endTagMatch) {
          ...
        }
        // Start tag:
        const startTagMatch = parseStartTag()
        if (startTagMatch) {
          ...
        }
      }
      let text, rest, next
      if (textEnd >= 0) {
        ...
      }
      if (textEnd < 0) {
        text = html
        html = ''
      }
      // 绘制文本内容，使用 options.char 方法。
      if (options.chars && text) {
        options.chars(text)
      }
    } else {
      ...
    }
    ...
  }
```
上面只看一下代码的大概意思：
* 首先通过while (html)去循环判断html内容是否存在。
* 再判断文本内容是否在script/style标签中
* 上述条件都满足的话，开始解析html字符串

假设我们传递这样一个html字符串`<div id="demo">{{msg}}</div>`。我们来看其中一段关于Start tag解析的方法：
```js
// src/compiler/parser/html-parser.js

const startTagMatch = parseStartTag()
if (startTagMatch) {
  handleStartTag(startTagMatch)
  if (shouldIgnoreFirstNewline(lastTag, html)) {
    advance(1)
  }
  continue
}
```
这里面有parseStartTag 和 handleStartTag两个方法值得关注一下：
```js
// src/compiler/parser/html-parser.js

function parseStartTag () {
  //判断html中是否存在开始标签
  const start = html.match(startTagOpen)
  if (start) {
    // 定义 match 结构
    const match = {
      tagName: start[1], // 标签名
      attrs: [], // 属性名
      start: index // 起点位置
    }

    /**
     * 通过传入变量n来截取字符串，这也是Vue解析的重要方法，通过不断地蚕食掉html字符串，一步步完成对他的解析过程
     */
    advance(start[0].length)
    let end, attr

    // 如果还没有到结束标签的位置
    // 存入属性
    while (!(end = html.match(startTagClose)) && (attr = html.match(attribute))) {
      advance(attr[0].length)
      match.attrs.push(attr)
    }
    // 返回处理后的标签match结构
    if (end) {
      match.unarySlash = end[1]
      advance(end[0].length)
      match.end = index
      return match
    }
  }
}
```

经过上面一步的解析，我们得到了一个起始标签match的数据结构：

![](http://oankigr4l.bkt.clouddn.com/201806071115_814.png)

再看一下handleStartTag函数
```js
// src/compiler/parser/html-parser.js

function handleStartTag (match) {
  // match 是上面调用方法的时候传递过来的数据结构
  const tagName = match.tagName
  const unarySlash = match.unarySlash
  ...
  const unary = isUnaryTag(tagName) || !!unarySlash

  // 备份属性数组的长度
  const l = match.attrs.length
  // 构建长度为1的空数组
  const attrs = new Array(l)
  for (let i = 0; i < l; i++) {
    const args = match.attrs[i]
    ...
    // 取定义属性的值
    const value = args[3] || args[4] || args[5] || ''

    // 改变attr的格式为 [{name: 'id', value: 'demo'}]
    attrs[i] = {
      name: args[1],
      value: decodeAttr(
        value,
        options.shouldDecodeNewlines
      )
    }
  }

  // stack中记录当前解析的标签
  // 如果不是自闭和标签
  // 这里的stack这个变量在parseHTML中定义，作用是为了存放标签名 为了和结束标签进行匹配的作用。
  if (!unary) {
    stack.push({ tag: tagName, lowerCasedTag: tagName.toLowerCase(), attrs: attrs })
    lastTag = tagName
  }
  // parse 函数传入的 start 方法
  options.start(tagName, attrs, unary, match.start, match.end)
}
```
到这里似乎一切明朗了许多，parseHTML主要用来蚕食html字符串，解析出字符串中的tagName，attrs，match等元素，传回parseHTML函数中的start方法：
```js
// src/compiler/parser/index.js

start (tag, attrs, unary) {
  ...
  // 创建基础的 ASTElement
  let element: ASTElement = createASTElement(tag, attrs, currentParent)
  if (ns) {
    element.ns = ns
  }
  ...

  if (!inVPre) {
    // 判断有没有 v-pre 指令的元素。如果有的话 element.pre = true
    // 官网有介绍：<span v-pre>{{ this will not be compiled }}</span>
    // 跳过这个元素和它的子元素的编译过程。可以用来显示原始 Mustache 标签。跳过大量没有指令的节点会加快编译。
    processPre(element)
    if (element.pre) {
      inVPre = true
    }
  }
  if (platformIsPreTag(element.tag)) {
    inPre = true
  }
  if (inVPre) {
    // 处理原始属性
    processRawAttrs(element)
  } else if (!element.processed) {
    // structural directives
    // v-for v-if v-once
    processFor(element)
    processIf(element)
    processOnce(element)
    // element-scope stuff
    processElement(element, options)
  }

  // 检查根节点约束
  function checkRootConstraints (el) {
    if (process.env.NODE_ENV !== 'production') {
      if (el.tag === 'slot' || el.tag === 'template') {
        warnOnce(
          `Cannot use <${el.tag}> as component root element because it may ` +
          'contain multiple nodes.'
        )
      }
      if (el.attrsMap.hasOwnProperty('v-for')) {
        warnOnce(
          'Cannot use v-for on stateful component root element because ' +
          'it renders multiple elements.'
        )
      }
    }
  }

  // tree management
  if (!root) {
    // 如果不存在根节点
    root = element
    checkRootConstraints(root)
  } else if (!stack.length) {
    // 允许有 v-if, v-else-if 和 v-else 的根元素
    ...
  if (currentParent && !element.forbidden) {
    if (element.elseif || element.else) {
      processIfConditions(element, currentParent)
    } else if (element.slotScope) { // scoped slot
      currentParent.plain = false
      const name = element.slotTarget || '"default"'
      ;(currentParent.scopedSlots || (currentParent.scopedSlots = {}))[name] = element
    } else {
      // 将元素插入 children 数组中
      currentParent.children.push(element)
      element.parent = currentParent
    }
  }
  if (!unary) {
    currentParent = element
    stack.push(element)
  } else {
    endPre(element)
  }
  // apply post-transforms
  for (let i = 0; i < postTransforms.length; i++) {
    postTransforms[i](element, options)
  }
}
```
其实start方法就是处理 element 元素的过程。确定命名空间；创建AST元素 element；执行预处理；定义root；处理各类 v- 标签的逻辑；最后更新 root、currentParent、stack 的结果。 最终通过 createASTElement 方法定义了一个新的 AST 对象:
```js
// src/compiler/parser/index.js

export function createASTElement (
  tag: string,
  attrs: Array<Attr>,
  parent: ASTElement | void
): ASTElement {
  return {
    type: 1,
    tag,
    attrsList: attrs,
    attrsMap: makeAttrsMap(attrs),
    parent,
    children: []
  }
}
```

#### 小结
下面我们来屡一下parse整体的过程：
* 通过parseHtml来一步步解析传入html字符串的标签、元素、文本、注释..
* parseHtml解析过程中，调用传入的start，end，chars方法来生成AST语法树

我们看一下最终生成的AST语法树对象： 

![](http://oankigr4l.bkt.clouddn.com/201806071125_530.png)

## optimize标记节点
上一节主要关注了compile的parse部分，我们完成了一个字符串模板解析成一个AST语法树的过程，接下来这一步是优化的关键，我们需要通过optimize方法，将AST节点进行静态节点标记。为后面 patch 过程中对比新旧 VNode 树形结构做优化。被标记为 static 的节点在后面的 diff 算法中会被直接忽略，不做详细的比较。
```js
// src/compiler/index.js

 // 2.optimize
  optimize(ast, options)
```

### optimize功能
我们去简单分析一下optimize功能
```js
// src/compiler/optimizer.js

export function optimize (root: ?ASTElement, options: CompilerOptions) {
  if (!root) return
  // staticKeys 是那些认为不会被更改的ast的属性
  isStaticKey = genStaticKeysCached(options.staticKeys || '')
  isPlatformReservedTag = options.isReservedTag || no
  // first pass: mark all non-static nodes.
  // 第一步 标记 AST 所有静态节点
  markStatic(root)
  // second pass: mark static roots.
  // 第二步 标记 AST 所有父节点（即子树根节点）
  markStaticRoots(root, false)
}
```

#### isStatic
首先标记所有静态节点：
```js
// src/compiler/optimizer.js

function isStatic (node: ASTNode): boolean {
  if (node.type === 2) { // 表达式
    return false
  }
  if (node.type === 3) { // 文本节点
    return true
  }
  // 处理特殊标记
  return !!(node.pre || ( // v-pre标记的
    !node.hasBindings && // no dynamic bindings
    !node.if && !node.for && // not v-if or v-for or v-else
    !isBuiltInTag(node.tag) && // not a built-in
    isPlatformReservedTag(node.tag) && // not a component
    !isDirectChildOfTemplateFor(node) &&
    Object.keys(node).every(isStaticKey)
  ))
}
```
ASTNode 的 type 字段用于标识节点的类型，可查看上一篇的 AST 节点定义：type 为 1 表示元素，type 为 2 表示插值表达式，type 为 3 表示普通文本。可以看到，在标记 ASTElement 时会依次检查所有子元素节点的静态标记，从而得出该元素是否为 static。

#### markStaticRoots 
上面 markStatic 函数使用的是树形数据结构的深度优先遍历算法，使用递归实现。 接下来继续标记静态树：
```js
// src/compiler/optimizer.js

function markStaticRoots (node) {
   if (node.type === 1) {
       // 用以标记在v-for内的静态节点。这个属性用以告诉renderStatic(_m)对这个节点生成新的key，避免patch error
       if (node.static || node.once) {
         node.staticInFor = isInFor
       }
       // For a node to qualify as a static root, it should have children that
       // are not just static text. Otherwise the cost of hoisting out will
       // outweigh the benefits and it's better off to just always render it fresh.
       // 一个节点如果想要成为静态根，它的子节点不能单纯只是静态文本。否则，把它单独提取出来还不如重渲染时总是更新它性能高。
       if (node.static && node.children.length && !(
               node.children.length === 1 &&
               node.children[0].type === 3
           )) {

           node.staticRoot = true
           return
       } else {
           node.staticRoot = false
       }

       for (let i = 0; i < node.children.length; i++) {
           markStaticRoots(node.children[i])
       }
   }
}
```
markStaticRoots 函数里并没有什么特别的地方，仅仅是对静态节点又做了一层筛选。

### 小结
optimizer旨在为语法树的节点标上static和staticRoot属性。 遍历第一轮，标记static属性：
* 判断node是否为static(有诸多条件)
* 标记node的children是否为static，若存在non static子节点，父节点更改为static = false

遍历第二轮，标记staticRoot
* 标记static或节点为staticRoot，这个节点type === 1(一般是含有tag属性的节点)
* 具有v-once指令的节点同样被标记staticRoot
* 为了避免过度优化，只有static text为子节点的节点不被标记为staticRoot
* 标记节点children的staticRoot

## generate生成渲染函数过程
### generate 函数
generate 函数（src/compiler/codegen/index.js）主要功能就是根据 AST 结构拼接生成 render function 的字符串。
```js
// src/compiler/codegen/index.js

export function generate (
  ast: ASTElement | void,
  options: CompilerOptions
): CodegenResult {
  const state = new CodegenState(options)
  const code = ast ? genElement(ast, state) : '_c("div")'
  return {
    // 最外层包一个 with(this) 之后返回
    render: `with(this){return ${code}}`,
    // 这个数组中的函数与 VDOM 中的 diff 算法优化相关
    // 我们会在编译阶段给后面不会发生变化的 VNode 节点打上 staticRoot 为 true 的标
    // 那些被标记为 staticRoot 节点的 VNode 就会单独生成 staticRenderFns
    staticRenderFns: state.staticRenderFns
  }
}
```

其中 genElement 函数（src/compiler/codegen/index.js）是会根据 AST 的属性调用不同的方法生成字符串返回。也就是拼接字符串了：
```js

// src/compiler/codegen/index.js

export function genElement (el: ASTElement, state: CodegenState): string {
  if (el.staticRoot && !el.staticProcessed) {
    return genStatic(el, state)
  } else if (el.once && !el.onceProcessed) {
    return genOnce(el, state)
  } else if (el.for && !el.forProcessed) {
    return genFor(el, state)
  } else if (el.if && !el.ifProcessed) {
    return genIf(el, state)
  } else if (el.tag === 'template' && !el.slotTarget) {
    return genChildren(el, state) || 'void 0'
  } else if (el.tag === 'slot') {
    return genSlot(el, state)
  } else {
    // component or element
    let code
    if (el.component) {
      code = genComponent(el.component, el, state)
    } else {
      const data = el.plain ? undefined : genData(el, state)

      const children = el.inlineTemplate ? null : genChildren(el, state, true)
      code = `_c('${el.tag}'${
        data ? `,${data}` : '' // data
      }${
        children ? `,${children}` : '' // children
      })`
    }
    // module transforms
    for (let i = 0; i < state.transforms.length; i++) {
      code = state.transforms[i](el, code)
    }
    return code
  }
}
```
以上就是 compile 函数中三个核心步骤的介绍，compile 之后我们得到了 render function 的字符串形式，后面通过 new Function 得到真正的渲染函数。DOM 初始化过程最后一步是根据渲染函数生成 Vnode，根据此 Vnode 生成真实 DOM，插入 DOM 树中，并将该 Vnode 记录为 preVnode。

## 总结
经历过这些过程以后，我们已经把 template 顺利转成了 render function 了，接下来我们将介绍 patch 的过程，来看一下具体 VNode 节点如何进行差异的比对。

**参考资料**
[Vue源码浅析（三）-render函数](http://blog.cgsdream.org/2016/11/23/vue-source-analysis-3/)
[Vue2.0 源码阅读：模板渲染](https://zhouweicsu.github.io/blog/2017/04/21/vue-2-0-template/)
[]()

![](http://oankigr4l.bkt.clouddn.com/wexin.png)