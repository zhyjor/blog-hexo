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



**参考资料**
[博客园的翻译](http://www.cnblogs.com/justinw/archive/2010/04/16/1713086.html)
[汤姆大叔的博客(10-20)](http://www.cnblogs.com/TomXu/archive/2011/12/15/2288411.html)
[冴羽写博客的地方](https://github.com/mqyqingfeng/Blog)
[ECMA-262-3 in detail](http://dmitrysoshnikov.com/tag/ecma-262-3/)
[JavaScript内部原理实践——真的懂JavaScript吗？（转）](http://www.bubuko.com/infodetail-1753692.html)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)