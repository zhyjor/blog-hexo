---
title: JavaScript常见问题之四：变量类型的判断方式
tags:
  - JavaScript常见问题
  - js
categories: js
top: false
copyright: true
date: 2018-03-08 17:39:04
---
typeof和instanceof以及Object.prototype.toString.call()是我们判断数据类型的时候比较常见的用法，搞明白其实现的原理对使用中避一些坑很有用。

<!--more-->

## typeof

### typeof的特点

typeof一般用来判断一个变量的类型，我们可以利用typeof来判断number、string、object、boolean、function、undefined、symbol这七种类型。在被判断的主体不是object类型的数据的时候（function算object吗），可以清晰的告诉我们这是哪一类的类型，当时当判断object的时候就不行了，只能告诉我们这就是一个object，就没有再详细的信息了。而且在判断null时也有大坑，对于typeof判断，null是Object。如下：
```js
let s = new String('abc');
typeof s === 'object'// true
s instanceof String // true
```
要想判断一个数据具体是哪一种 object 的时候，我们需要利用 instanceof 这个操作符来判断。

### 实现原理
我们可以先考虑一个常见但是却可能未深入考虑的问题：js在底层是怎么存储数据的类型信息的呢？

在 javascript 的最初版本中，使用的 32 位系统，为了性能考虑使用低位存储了变量的类型信息：
* 000：对象
* 1：整数
* 010：浮点数
* 100：字符串
* 110：布尔

**有两个值比较特殊：**
* undefined：用(-2^30)来表示
* null：对应机器码的NULL指针，一般全是零

在第一版的JavaScript实现中，判断类型的代码是这样写的：
```js
if (JSVAL_IS_VOID(v)) { // (1)判断是否为 undefined
    type = JSTYPE_VOID;
} else if (JSVAL_IS_OBJECT(v)) { // (2)如果不是 undefined，判断是否为对象
    obj = JSVAL_TO_OBJECT(v);
    if (obj &&
        (ops = obj->map->ops,
            ops == & js_ObjectOps
                ? (clasp = OBJ_GET_CLASS(cx, obj),
                    clasp->call || clasp == & js_FunctionClass) // (3,4)
                : ops->call != 0)) { // (3)如果不是对象，判断是否为数字
        type = JSTYPE_FUNCTION;
    } else {
        type = JSTYPE_OBJECT;
    }
} else if (JSVAL_IS_NUMBER(v)) {
    type = JSTYPE_NUMBER;
} else if (JSVAL_IS_STRING(v)) {
    type = JSTYPE_STRING;
} else if (JSVAL_IS_BOOLEAN(v)) {
    type = JSTYPE_BOOLEAN;
}
```

### feature or bug（typeof null）
> javascript 中的 null：既是对象，又不是对象，史称「薛定谔的对象」。


在上面的判断中,null 就出了一个 bug。先看演示代码：
```js
typeof null === 'object'// true
null instanceof Object === false// true

null instanceof null// TypeError: Right-hand side of 'instanceof' is not an object
```

根据 type tags 信息低位是 000，因此 null 被判断成了一个对象。这就是为什么 typeof null 的返回值是 object。这是一个历史遗留下来的 feature(or bug?)，[The history of “typeof null”](http://2ality.com/2013/10/typeof-null.html)。关于 null 的类型在 MDN 文档中也有简单的描述：[typeof - javascript | MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/typeof#null)。

**从底层来讲，不同对象在底层都表示为二进制。在js中，二进制前三位都是0的话会被判断为object类型，null的二进制全为0自然前三位也是0，所以执行typeof时会返回object。**

在ES6中曾经有关于修复该bug的提议，[提议中称应该将typeof null === 'null'](http://wiki.ecmascript.org/doku.php?id=harmony:typeof_null)，但是该提议被否决了，从此typeof null就不在是一个bug，而是一个feature，不会被修复了。


## toString():判断内置类型最好用的方式
在用 typeof 来判断变量类型的时候，我们需要注意，最好是用 typeof 来判断基本数据类型（包括symbol），避免对 null 的判断。注意这里的内置两个字。

### 使用方式

Object.prototype.toString，我们可以利用这个方法来对一个内置变量的类型来进行比较准确的判断：
```js
Object.prototype.toString.call(1) // "[object Number]"
Object.prototype.toString.call('hi') // "[object String]"
Object.prototype.toString.call({a:'hi'}) // "[object Object]"
Object.prototype.toString.call([1,'a']) // "[object Array]"
Object.prototype.toString.call(true) // "[object Boolean]"
Object.prototype.toString.call(() => {}) // "[object Function]"
Object.prototype.toString.call(null) // "[object Null]"
Object.prototype.toString.call(undefined) // "[object Undefined]"
Object.prototype.toString.call(Symbol(1)) // "[object Symbol]"
```

### 原理

这么好用，我们当然需要明白这其中是什么原理了！这里不详细介绍toString方法，这也是一个很大的点，它和valueof纠缠也是需要弄清楚的。

#### ECMAScript 3
在ES3中,Object.prototype.toString方法的规范如下:
> 15.2.4.2 Object.prototype.toString()

在toString方法被调用时,会执行下面的操作步骤:
* 获取this对象的[[Class]]属性的值.
* 计算出三个字符串"[object ", 第一步的操作结果Result(1), 以及 "]"连接后的新字符串.
* 返回第二步的操作结果Result(2).

[[Class]]是一个内部属性,所有的对象(原生对象和宿主对象)都拥有该属性.在规范中,[[Class]]是这么定义的

|内部属性|描述|
	|-|-|
|[[Class]]|一个字符串值,表明了该对象的类型.|

把Object.prototype.toString方法返回的字符串,去掉前面固定的"[object "和后面固定的"]",就是内部属性[[class]]的值,也就达到了判断对象类型的目的.**jQuery中的工具方法$.type(),就是干这个的.**

规范的原文：
> 所有内置对象的[[Class]]属性的值是由本规范定义的.所有宿主对象的[[Class]]属性的值可以是任意值,甚至可以是内置对象使用过的[[Class]]属性的值.[[Class]]属性的值可以用来判断一个原生对象属于哪种内置类型.需要注意的是,除了通过Object.prototype.toString方法之外,本规范没有提供任何其他方式来让程序访问该属性的值(查看 15.2.4.2).

在ES3中,规范文档并没有总结出[[class]]内部属性一共有几种,不过我们可以自己统计一下,原生对象的[[class]]内部属性的值一共有10种.分别是:"Array", "Boolean", "Date", "Error", "Function", "Math", "Number", "Object", "RegExp", "String".

#### ECMAScript 5
在ES5.1中,除了规范写的更详细一些以外,Object.prototype.toString方法和[[class]]内部属性的定义上也有一些变化,Object.prototype.toString方法的规范如下:
> 15.2.4.2 Object.prototype.toString ( )

在toString方法被调用时,会执行下面的操作步骤:
* 如果this的值为undefined,则返回"[object Undefined]".
* 如果this的值为null,则返回"[object Null]".
* 让O成为调用ToObject(this)的结果.
* 让class成为O的内部属性[[Class]]的值.
* 返回三个字符串"[object ", class, 以及 "]"连接后的新字符串.

**可以看出,比ES3多了1,2,3步.第1,2步属于新规则,比较特殊,因为"Undefined"和"Null"并不属于[[class]]属性的值,需要注意的是,这里和严格模式无关**.大部分函数在严格模式下,this的值才会保持undefined或null,非严格模式下会自动成为全局对象,第3步并不算是新规则,因为在ES3的引擎中,也都会在这一步将三种原始值类型转换成对应的包装对象,只是规范中没写出来.ES5中,[[Class]]属性的解释更加详细:
> 所有内置对象的[[Class]]属性的值是由本规范定义的.所有宿主对象的[[Class]]属性的值可以是除了"Arguments", "Array", "Boolean", "Date", "Error", "Function", "JSON", "Math", "Number", "Object", "RegExp", "String"之外的的任何字符串.[[Class]]内部属性是引擎内部用来判断一个对象属于哪种类型的值的.需要注意的是,除了通过Object.prototype.toString方法之外,本规范没有提供任何其他方式来让程序访问该属性的值(查看 15.2.4.2).

和ES3对比一下,第一个差别就是[[class]]内部属性的值多了两种,成了12种,一种是arguments对象的[[class]]成了"Arguments",而不是以前的"Object",还有就是多个了全局对象JSON,它的[[class]]值为"JSON".第二个差别就是,宿主对象的[[class]]内部属性的值,不能和这12种值冲突,不过在支持ES3的浏览器中,貌似也没有发现哪些宿主对象故意使用那10个值.

#### ECMAScript 6
[[class]]内部属性没有了,取而代之的是另外一个内部属性[[NativeBrand]].[[NativeBrand]]属性是这么定义的:

|内部属性|属性值|描述|
	|-|-|-|
	|[[NativeBrand]]|枚举NativeBrand的一个成员.|该属性的值对应一个标志值(tag value),可以用来区分原生对象的类型.|

[[NativeBrand]]内部属性用来识别某个原生对象是否为符合本规范的某一种特定类型的对象.[[NativeBrand]]内部属性的值为下面这些枚举类型的值中的一个:NativeFunction, NativeArray, StringWrapper, BooleanWrapper, NumberWrapper, NativeMath, NativeDate, NativeRegExp, NativeError, NativeJSON, NativeArguments, NativePrivateName.[[NativeBrand]]内部属性仅用来区分区分特定类型的ECMAScript原生对象.只有在表10中明确指出的对象类型才有[[NativeBrand]]内部属性.

下表是 [[NativeBrand]]内部属性的值：

![](http://static.zhyjor.com/201806101127_870.png)

可见,和[[class]]不同的是,并不是每个对象都拥有[[NativeBrand]].同时,Object.prototype.toString方法的规范也改成了下面这样:

> 15.2.4.2 Object.prototype.toString ( )

在toString方法被调用时,会执行下面的操作步骤:
* 如果this的值为undefined,则返回"[object Undefined]".
* 如果this的值为null,则返回"[object Null]".
* 让O成为调用ToObject(this)的结果.
* 如果O有[[NativeBrand]]内部属性,让tag成为下表中对应的值.
* 否则,
* 让tag成为调用O的[[Get]]内部方法后的结果,参数为@@toStringTag.
* 如果tag是一个abrupt completion,则让tag成为NormalCompletion("???").
* 让tag成为tag.[[value]].
* 如果Type(tag)不是字符串,则让tag成为"???".
* 如果tag的值为"Arguments", "Array", "Boolean", "Date", "Error", "Function", "JSON", "Math", "Number", "Object", "RegExp",或者"String"中的任一个,则让tag成为字符串"~"和tag当前的值连接后的结果.
* 返回三个字符串"[object ", tag, and "]"连接后的新字符串.

下表是[[NativeBrand]] 标志值：
![](http://static.zhyjor.com/201806101129_509.png)

可以看到,在规范上有了很大的变化,不过对于普通用户来说,貌似感觉不到.
也许你发现了,ES6里的新类型Map,Set等,都没有在表29中.它们在执行toString方法的时候返回的是什么?
```js
console.log(Object.prototype.toString.call(Map())) //"[object Map]"
console.log(Object.prototype.toString.call(Set())) //"[object Set]"
```
> 15.14.5.13 Map.prototype.@@toStringTag

@@toStringTag 属性的初始值为字符串"Map".

现在只需要知道的是:[[class]]没了,使用了更复杂的机制.


## instanceof 运算符
在使用 typeof 运算符时采用引用类型存储值会出现一个问题，无论引用的是什么类型的对象，它都返回 "object"。而使用toString方式在面对自定义的对象的时候，也面临这个问题。ECMAScript 引入了另一个 Java 运算符 instanceof 来解决这个问题。
### 简介
instanceof 运算符与 typeof 运算符相似，用于识别正在处理的对象的类型。与 typeof 方法不同的是，instanceof 方法要求开发者明确地确认对象为某特定类型。例如：
```js
let person = function () {
}
let nicole = new person()
nicole instanceof person // true
```

### 常规用法

通常来讲，使用 instanceof 就是判断一个实例是否属于某种类型。 instanceof 可以在继承关系中用来判断一个实例是否属于它的父类型。接着上例：
```js
let person = function () {
}
let programmer = function () {
}
programmer.prototype = new person()
let nicole = new programmer()
nicole instanceof person // true
nicole instanceof programmer // true
```

上面的代码中是判断了一层继承关系中的父类，在多层继承关系中，instanceof 运算符同样适用。其中的原理是是什么呢？

### ECMAScript规范

规范中对instanceof有详细的定义，规范如下：
```js
11.8.6 The instanceof operator 
 The production RelationalExpression: 
     RelationalExpression instanceof ShiftExpression is evaluated as follows: 
 
 1. Evaluate RelationalExpression. 
 2. Call GetValue(Result(1)).// 调用 GetValue 方法得到 Result(1) 的值，设为 Result(2) 
 3. Evaluate ShiftExpression. 
 4. Call GetValue(Result(3)).// 同理，这里设为 Result(4) 
 5. If Result(4) is not an object, throw a TypeError exception.// 如果 Result(4) 不是 object，
                                                                //抛出异常
 /* 如果 Result(4) 没有 [[HasInstance]] 方法，抛出异常。规范中的所有 [[...]] 方法或者属性都是内部的，
在 JavaScript 中不能直接使用。并且规范中说明，只有 Function 对象实现了 [[HasInstance]] 方法。
所以这里可以简单的理解为：如果 Result(4) 不是 Function 对象，抛出异常 */ 
 6. If Result(4) does not have a [[HasInstance]] method, 
   throw a TypeError exception. 
 // 相当于这样调用：Result(4).[[HasInstance]](Result(2)) 
 7. Call the [[HasInstance]] method of Result(4) with parameter Result(2). 
 8. Return Result(7). 
 
 // 相关的 HasInstance 方法定义
 15.3.5.3 [[HasInstance]] (V) 
 Assume F is a Function object.// 这里 F 就是上面的 Result(4)，V 是 Result(2) 
 When the [[HasInstance]] method of F is called with value V, 
     the following steps are taken: 
 1. If V is not an object, return false.// 如果 V 不是 object，直接返回 false 
 2. Call the [[Get]] method of F with property name "prototype".// 用 [[Get]] 方法取 
                                                                // F 的 prototype 属性
 3. Let O be Result(2).//O = F.[[Get]]("prototype") 
 4. If O is not an object, throw a TypeError exception. 
 5. Let V be the value of the [[Prototype]] property of V.//V = V.[[Prototype]] 
 6. If V is null, return false. 
 // 这里是关键，如果 O 和 V 引用的是同一个对象，则返回 true；否则，到 Step 8 返回 Step 5 继续循环
 7. If O and V refer to the same object or if they refer to objects 
   joined to each other (section 13.1.2), return true. 
 8. Go to step 5.
```


### 原理

规范复杂晦涩，翻译成js代码更好理解:
```js
function instance_of(L, R) {//L 表示左表达式，R 表示右表达式
 var O = R.prototype;// 取 R 的显示原型
 L = L.__proto__;// 取 L 的隐式原型
 while (true) { 
   if (L === null) 
     return false; 
   if (O === L)// 这里重点：当 O 严格等于 L 时，返回 true 
     return true; 
   L = L.__proto__; 
 } 
}
```
其实 instanceof 主要的实现原理就是只要右边变量的 prototype 在左边变量的原型链上即可。因此，instanceof 在查找的过程中会遍历左边变量的原型链，直到找到右边变量的 prototype，如果查找失败，则会返回 false，告诉我们左边变量并非是右边变量的实例。


看几行奇怪的代码：
```js
function Foo() {
}

Object instanceof Object // true
Function instanceof Function // true
Function instanceof Object // true

Number instanceof Number//false 
String instanceof String//false 

Foo instanceof Foo // false
Foo instanceof Object // true
Foo instanceof Function // true

```
上面的代码除了instanceof的知识点，还需要对原型继承有详细的了解，这里就不展开说原型了，可以参考另一篇文章来细细理解，**只要对原型有深入的理解，上面的代码就可以很顺畅的理解**。

**Object instanceof Object// true**

```js
// 为了方便表述，首先区分左侧表达式和右侧表达式
ObjectL = Object, ObjectR = Object; 
// 下面根据规范逐步推演
O = ObjectR.prototype = Object.prototype 
L = ObjectL.__proto__ = Function.prototype 
// 第一次判断
O != L 
// 循环查找 L 是否还有 __proto__ 
L = Function.prototype.__proto__ = Object.prototype 
// 第二次判断
O == L 
// 返回 true
```

**Function instanceof Function // true**
```js
// 为了方便表述，首先区分左侧表达式和右侧表达式
FunctionL = Function, FunctionR = Function; 
// 下面根据规范逐步推演
O = FunctionR.prototype = Function.prototype 
L = FunctionL.__proto__ = Function.prototype 
// 第一次判断
O == L 
// 返回 true
```
**Foo instanceof Foo // false**
```js
// 为了方便表述，首先区分左侧表达式和右侧表达式
FooL = Foo, FooR = Foo; 
// 下面根据规范逐步推演
O = FooR.prototype = Foo.prototype 
L = FooL.__proto__ = Function.prototype 
// 第一次判断
O != L 
// 循环再次查找 L 是否还有 __proto__ 
L = Function.prototype.__proto__ = Object.prototype 
// 第二次判断
O != L 
// 再次循环查找 L 是否还有 __proto__ 
L = Object.prototype.__proto__ = null 
// 第三次判断
L == null 
// 返回 false
```

### instanceof 在 Dojo 继承机制中的应用
在 JavaScript 中，是没有多重继承这个概念的，就像 Java 一样。但在 Dojo（dojo是一款javascript框架，提供很多javascript UI） 中使用 declare 声明类时，是允许继承自多个类的。

```js
dojo.declare("Aoo",null,{}); 
dojo.declare("Boo",null,{}); 
dojo.declare("Foo",[Aoo,Boo],{}); 
 
var foo = new Foo(); 
console.log(foo instanceof Aoo);//true 
console.log(foo instanceof Boo);//false 
 
console.log(foo.isInstanceOf(Aoo));//true 
console.log(foo.isInstanceOf(Boo));//true
```

其实对于js，什么样的花式继承都是错觉，这都是原型继承的封装，或者说语法糖。

上面的示例中，Foo 同时继承自 Aoo 和 Boo，但当使用 instanceof 运算符来检查 foo 是否是 Boo 的实例时，返回的是 false。**实际上，在 Dojo 的内部，Foo 仍然只继承自 Aoo，而通过 mixin 机制把 Boo 类中的方法和属性拷贝到 Foo 中**，所以当用 instanceof 运算符来检查是否是 Boo 的实例时，会返回 false。所以 Dojo 为每个类的实例添加了一个新的方法叫 isInstanceOf，用这个方法来检查多重继承。

## 总结
简单来说，我们使用 typeof 来判断基本数据类型是 ok 的，不过需要注意当用 typeof 来判断 null 类型时的问题，如果想要判断一个对象的具体类型可以考虑用 instanceof，但是 instanceof 也可能判断不准确，比如一个数组，他可以被 instanceof 判断为 Object。所以我们要想比较准确的判断对象实例的类型时，可以采取 Object.prototype.toString.call 方法。


**参考资料**
[浅谈 instanceof 和 typeof 的实现原理](https://juejin.im/post/5b0b9b9051882515773ae714)
[JavaScript instanceof 运算符深入剖析](https://www.ibm.com/developerworks/cn/web/1306_jiangjj_jsinstanceof/)
[有哪些明明是 bug，却被说成是 feature 的例子？](https://www.zhihu.com/question/66941121/answer/247939890)
[JavaScript中Object.prototype.toString方法的原理](https://www.jb51.net/article/79941.htm)

![](http://static.zhyjor.com/wexin.png)
