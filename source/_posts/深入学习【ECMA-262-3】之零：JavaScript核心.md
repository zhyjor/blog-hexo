---
title: 深入学习【ECMA-262-3】之零：JavaScript核心
tags:
  - ECMA262
  - js
categories: js
top: false
copyright: true
date: 2017-03-03 16:03:40
---
JavaScript是一门很灵活的语言，灵活有时候就意味着混乱，尤其是在没有理清很多基础知识的情况下。作为和静态编译语言完全不同的一种语言，它面向对象又没有类的概念，有一个基于prototype的继承，以及神出鬼没的this等等。我们需要理解这些js设计的核心，才能更好的使用它。

本系列主要是对俄国人Dmitry Soshnikov写的一个系列博客教程[《ECMA-262-3 in detail》](http://dmitrysoshnikov.com/tag/ecma-262-3/)的理解，从ECMA规范的角度来解析js更加之深入和彻底，而且涵盖了js进阶的所有话题。
<!--more-->
[原文：JavaScript. The Core.](http://dmitrysoshnikov.com/ecmascript/javascript-the-core/)

我们首先来看一下对象[Object]的概念，这也是ECMASript中最基本的概念。

## 对象Object
ECMAScript是一门高度抽象的面向对象(object-oriented)语言，用以处理Objects对象. 当然，也有基本类型，但是必要时，也需要转换成object对象来用。
> An object is a collection of properties and has a single prototype object. The prototype may be either an object or the null value.
> Object是一个属性的集合，并且都拥有一个单独的原型对象[prototype object]. 这个原型对象[prototype object]可以是一个object或者null值。

让我们来举一个基本Object的例子，首先我们要清楚，一个Object的prototype是一个内部的`[[prototype]]`属性的引用。

不过一般来说，我们会使用`__<内部属性名>__` 下划线来代替双括号，例如`__proto__`(这是某些脚本引擎比如SpiderMonkey的对于原型概念的具体实现，尽管并非标准)。

```js
var foo = {
  x: 10,
  y: 20
};
```
上述代码foo对象有两个显式的属性`[explicit own properties]`和一个自带隐式的 `__proto__` 属性`[implicit __proto__ property]`，指向foo的原型。

![](http://oankigr4l.bkt.clouddn.com/201807031720_970.png)

为什么需要原型呢？让我们先看一下原型链。

## 原型链（Prototype chain）

### 什么是原型链

原型对象也是普通的对象，它也有可能拥有自己的原型。假如原型对象的原型不为`null`的话，即可以称之为原型链。
> A prototype chain is a finite chain of objects which is used to implemented inheritance and shared properties.
> 原型链是一个由对象组成的有限长度的对象链，用于实现继承和共享属性。

### 为什么需要原型链

想象一个这种情况，2个对象，大部分内容都一样，只有一小部分不一样，很明显，在一个好的设计模式中，我们会需要重用那部分相同的，而不是在每个对象中重复定义那些相同的方法或者属性。在基于类[class-based]的系统中，这些重用部分被称为类的继承 – 相同的部分放入class A，然后class B和class C从A继承，并且可以声明拥有各自的独特的东西。这是面向对象编程的常见的实践方式。

ECMAScript没有类的概念，但是重用[reuse]这个理念没什么不同（某些方面，甚至比class更加灵活），可以由prototype chain原型链来实现。这种继承被称为delegation based inheritance，基于继承的委托，或者更通俗一些，叫原型继承。

类似于类”A”，”B”，”C”，在ECMAScript中尼创建对象类”a”，”b”，”c”，相应地， 对象“a” 拥有对象“b”和”c”的共同部分。同时对象“b”和”c”只包含它们自己的附加属性或方法。

```js
var a = {
  x: 10,
  calculate: function (z) {
    return this.x + this.y + z
  }
};
 
var b = {
  y: 20,
  __proto__: a
};
 
var c = {
  y: 30,
  __proto__: a
};
 
// 调用继承过来的方法
b.calculate(30); // 60
c.calculate(40); // 80
```
这样看上去是不是很简单啦。b和c可以使用a中定义的calculate方法，这就是有原型链来实现的。

### 原理
原理很简单:如果在对象b中找不到calculate方法(也就是对象b中没有这个calculate属性), 那么就会沿着原型链开始找。如果这个calculate方法在b的prototype中没有找到，那么就会沿着原型链找到a的prototype，一直遍历完整个原型链。记住，**一旦找到，就返回第一个找到的属性或者方法。**因此，第一个找到的属性成为继承属性。如果遍历完整个原型链，仍然没有找到，那么就会返回undefined。

注意一点，this这个值在一个继承机制中，仍然是指向它原本属于的对象，而不是从原型链上找到它时，它所属于的对象。例如，以上的例子，this.y是从b和c中获取的，而不是a。当然，你也发现了this.x是从a取的，因为是通过原型链机制找到的。

如果一个对象的prototype没有显示的声明过或定义过，那么`__proto__`的默认值就是object.prototype, 而object.prototype也会有一个`__proto__`, 这个就是原型链的终点了，被设置为`null`。

下面的图示就是表示了上述a,b,c的继承关系
![](http://oankigr4l.bkt.clouddn.com/201807031736_252.png)

ES5提供了一个替代的原型继承方案，可以通过Object.create函数实现：
```js
var b = Object.create(a, {y: {value: 20}});
var c = Object.create(a, {y: {value: 30}});
```

ES6标准化了`__prto__`，可以用来初始化对象。

原型链通常将会在这样的情况下使用：对象拥有 相同或相似的状态结构`(same or similar state structure)` （即相同的属性集合）与 不同的状态值`(different state values)`。在这种情况下，我们可以使用 构造函数(Constructor) 在 特定模式(specified pattern) 下创建对象。


## 构造函数（Constructor）
除了创建对象，构造函数(constructor) 还做了另一件有用的事情—自动为创建的新对象设置了原型对象(prototype object) 。原型对象存放于 ConstructorFunction.prototype 属性中。

例如，我们重写之前例子，使用构造函数创建对象“b”和“c”，那么对象”a”则扮演了“Foo.prototype”这个角色：

```js
// 构造函数
function Foo(y) {
  // 构造函数将会以特定模式创建对象：被创建的对象都会有"y"属性
  this.y = y;
}
 
// "Foo.prototype"存放了新建对象的原型引用
// 所以我们可以将之用于定义继承和共享属性或方法
// 所以，和上例一样，我们有了如下代码：
 
// 继承属性"x"
Foo.prototype.x = 10;
 
// 继承方法"calculate"
Foo.prototype.calculate = function (z) {
  return this.x + this.y + z;
};
 
// 使用foo模式创建 "b" and "c"
var b = new Foo(20);
var c = new Foo(30);
 
// 调用继承的方法
b.calculate(30); // 60
c.calculate(40); // 80
 
// 让我们看看是否使用了预期的属性
 
console.log(
 
  b.__proto__ === Foo.prototype, // true
  c.__proto__ === Foo.prototype, // true
 
  // "Foo.prototype"自动创建了一个特殊的属性"constructor"
  // 指向a的构造函数本身
  // 实例"b"和"c"可以通过授权找到它并用以检测自己的构造函数
 
  b.constructor === Foo, // true
  c.constructor === Foo, // true
  Foo.prototype.constructor === Foo // true
 
  b.calculate === b.__proto__.calculate, // true
  b.__proto__.calculate === Foo.prototype.calculate // true
 
);
```
上述代码可表示为如下的关系：
![](http://oankigr4l.bkt.clouddn.com/201807031815_204.png)
上述图示可以看出，每一个object都有一个prototype. 构造函数Foo也拥有自己的`__proto__`, 也就是Function.prototype, 而Function.prototype的`__proto__`指向了Object.prototype. 重申一遍，Foo.prototype只是一个显式的属性，也就是b和c的`__proto__`属性。

这个问题完整和详细的解释在接下来还会有详细的解释。分两个部分：面向对象编程.一般理论(OOP. The general theory)，描述了不同的面向对象的范式与风格(OOP paradigms and stylistics)，以及与ECMAScript的比较, 面向对象编程.ECMAScript实现(OOP. ECMAScript implementation), 专门讲述了ECMAScript中的面向对象编程。

## 执行上下文栈（Execution Context Stack）

在ECMASscript中的代码有三种类型：global, function和eval。

每一种代码的执行都需要依赖自身的上下文。当然global的上下文可能涵盖了很多的function和eval的实例。函数的每一次调用，都会进入函数执行中的上下文,并且来计算函数中变量等的值。eval函数的每一次执行，也会进入eval执行中的上下文，判断应该从何处获取变量的值。

注意，一个function可能产生无限的上下文环境，因为一个函数的调用（甚至递归）都产生了一个新的上下文环境。

```js
function foo(bar) {}

// 调用相同的function，每次都会产生3个不同的上下文
//（包含不同的状态，例如参数bar的值）

foo(10);
foo(20);
foo(30);
```
一个执行上下文可以激活另一个上下文，就好比一个函数调用了另一个函数(或者全局的上下文调用了一个全局函数)，然后一层一层调用下去。逻辑上来说，这种实现方式是栈，我们可以称之为上下文堆栈。

激活其它上下文的某个上下文被称为 调用者(caller) 。被激活的上下文被称为被调用者(callee) 。被调用者同时也可能是调用者(比如一个在全局上下文中被调用的函数调用某些自身的内部方法)。

当一个caller激活了一个callee，那么这个caller就会暂停它自身的执行，然后将控制权交给这个callee. 于是这个callee被放入堆栈，称为进行中的上下文[running/active execution context]. 当这个callee的上下文结束之后，会把控制权再次交给它的caller，然后caller会在刚才暂停的地方继续执行。在这个caller结束之后，会继续触发其他的上下文。一个callee可以用返回（return）或者抛出异常（exception）来结束自身的上下文。

如下图，所有的ECMAScript的程序执行都可以看做是一个执行上下文堆栈[execution context (EC) stack]。堆栈的顶部就是处于激活状态的上下文。

---

当一段程序开始时，会先进入全局执行上下文环境[global execution context], 这个也是堆栈中最底部的元素。此全局程序会开始初始化，初始化生成必要的对象[objects]和函数[functions]. 在此全局上下文执行的过程中，它可能会激活一些方法（当然是已经初始化过的），然后进入他们的上下文环境，然后将新的元素压入堆栈。在这些初始化都结束之后，这个系统会等待一些事件（例如用户的鼠标点击等），会触发一些方法，然后进入一个新的上下文环境。

有一个函数上下文“EC1″和一个全局上下文“Global EC”，下图展现了从“Global EC”进入和退出“EC1″时栈的变化:

---

ECMAScript运行时系统就是这样管理代码的执行。

关于ECMAScript执行上下文栈的内容请查阅本系列教程的执行上下文(Execution context)。

如上所述，栈中每一个执行上下文可以表示为一个对象。让我们看看上下文对象的结构以及执行其代码所需的 状态(state) 。

## 执行上下文（Execution Context）
一个执行的上下文可以抽象的理解为object。每一个执行的上下文都有一系列的属性（我们称为上下文状态），他们用来追踪关联代码的执行进度。这个图示就是一个context的结构。

---

除了这3个所需要的属性(变量对象(variable object)，this指针(this value)，作用域链(scope chain) )，执行上下文根据具体实现还可以具有任意额外属性。接着，让我们仔细来看看这三个属性。


## 变量对象(Variable Object)

> A variable object is a scope of data related with the execution context. 
It’s a special object associated with the context and which stores variables and function declarations are being defined within the context.

> 变量对象(variable object) 是与执行上下文相关的 数据作用域(scope of data) 。
它是与上下文关联的特殊对象，用于存储被定义在上下文中的 变量(variables) 和 函数声明(function declarations) 。

注意：函数表达式[function expression]（而不是函数声明[function declarations）是不包含在VO[variable object]里面的。

变量对象（Variable Object）是一个抽象的概念，不同的上下文中，它表示使用不同的object。例如，在global全局上下文中，变量对象也是全局对象自身[global object]。（这就是我们可以通过全局对象的属性来指向全局变量的原因）。

让我们看看下面例子中的全局执行上下文情况：

```js
var foo = 10;

function bar() {} // // 函数声明
(function baz() {}); // 函数表达式

console.log(
  this.foo == foo, // true
  window.bar == bar // true
);

console.log(baz); // 引用错误，baz没有被定义
```
局上下文中的变量对象(VO)会有如下属性：

---

如上所示，函数“baz”如果作为函数表达式则不被不被包含于变量对象。这就是在函数外部尝试访问产生引用错误(ReferenceError) 的原因。请注意，ECMAScript和其他语言相比(比如C/C++)，仅有函数能够创建新的作用域。在函数内部定义的变量与内部函数，在外部非直接可见并且不污染全局对象。使用 eval 的时候，我们同样会使用一个新的(eval创建)执行上下文。eval会使用全局变量对象或调用者的变量对象(eval的调用来源)。

那函数以及自身的变量对象又是怎样的呢?在一个函数上下文中，变量对象被表示为活动对象(activation object)。

## 活动对象(activation object)
当函数被调用者激活，这个特殊的活动对象(activation object) 就被创建了。它包含普通参数(formal parameters) 与特殊参数(arguments)对象(具有索引属性的参数映射表)。活动对象在函数上下文中作为变量对象使用。

即：函数的变量对象保持不变，但除去存储变量与函数声明之外，还包含以及特殊对象arguments 。

考虑下面的情况：
```js
function foo(x, y) {
  var z = 30;
  function bar() {} // 函数声明
  (function baz() {}); // 函数表达式
}

foo(10, 20);
```
“foo”函数上下文的下一个激活对象(AO)如下图所示：

---

同样道理，function expression不在AO的行列。

对于这个AO的详细内容可以通过本系列教程找到。

我们接下去要讲到的是第三个主要对象。众所周知，在ECMAScript中，我们会用到内部函数[inner functions]，在这些内部函数中，我们可能会引用它的父函数变量，或者全局的变量。我们把这些变量对象成为上下文作用域对象[scope object of the context]. 类似于上面讨论的原型链[prototype chain]，我们在这里称为作用域链[scope chain]。

## 作用域链(Scope Chains)
> A scope chain is a list of objects that are searched for identifiers appear in the code of the context.
作用域链是一个 对象列表(list of objects) ，用以检索上下文代码中出现的 标识符(identifiers) 。

作用域链的原理和原型链很类似，如果这个变量在自己的作用域中没有，那么它会寻找父级的，直到最顶层。

标示符[Identifiers]可以理解为变量名称、函数声明和普通参数。例如，当一个函数在自身函数体内需要引用一个变量，但是这个变量并没有在函数内部声明（或者也不是某个参数名），那么这个变量就可以称为自由变量[free variable]。那么我们搜寻这些自由变量就需要用到作用域链。

在一般情况下，一个作用域链包括父级变量对象（variable object）（作用域链的顶部）、函数自身变量VO和活动对象（activation object）。不过，有些情况下也会包含其它的对象，例如在执行期间，动态加入作用域链中的—例如with或者catch语句。[译注：with-objects指的是with语句，产生的临时作用域对象；catch-clauses指的是catch从句，如catch(e)，这会产生异常对象，导致作用域变更]。

当查找标识符的时候，会从作用域链的活动对象部分开始查找，然后(如果标识符没有在活动对象中找到)查找作用域链的顶部，循环往复，就像作用域链那样。

```js
var x = 10;
 
(function foo() {
  var y = 20;
  (function bar() {
    var z = 30;
    // "x"和"y"是自由变量
    // 会在作用域链的下一个对象中找到（函数”bar”的互动对象之后）
    console.log(x + y + z);
  })();
})();
```


**参考资料**
[博客园的翻译](http://www.cnblogs.com/justinw/archive/2010/04/16/1713086.html)
[汤姆大叔的博客(10-20)](http://www.cnblogs.com/TomXu/archive/2011/12/15/2288411.html)
[冴羽写博客的地方](https://github.com/mqyqingfeng/Blog)
[ECMA-262-3 in detail](http://dmitrysoshnikov.com/tag/ecma-262-3/)
[JavaScript内部原理实践——真的懂JavaScript吗？（转）](http://www.bubuko.com/infodetail-1753692.html)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)