---
title: JavaScript基础之一：原型到原型链与继承
tags:
  - JavaScript基础
  - js
copyright: true
date: 2017-02-28 10:29:38
categories: js
---
理解原型，剖析原型链，希望经过这次整理后能够对原型，原型链以及Object等相关知识有个深层次的认识。
<!--more-->
## 问题
带着这些问题，你是不是也有这些疑问呢？
什么是`__proto__`
什么是`prototype`
什么是`constructor`
为什么只有函数对象才有prototype属性，普通对象只有`__proto__`属性
为什么`Function.prototype === Function.__proto__`
为什么说`typeof`比较的是原型，而`instanceof`比较的是`constructor`这个属性

为什么说js就没有类，只有原型链
为什么`Object.prototype.toString()==='[object Object]'//true`，内部怎么实现的

内置构造器的proto与constructor是怎么实现的


// Object的构造函数是Function
`Object.__proto__ === Function.prototype // true`

`Function.__proto__ === Object.__proto__`
`Function.prototype.__proto__ === Object.prototype`
`Object.prototype.__proto__ === null`

// Array.prototype的构造函数是什么呢
`Array.prototype.__proto__ ===Object.prototype`
// Array的构造函数是Function
`Array.__proto__ === Function.prototype`

** 所有的构造器都来自于 Function.prototype，甚至包括根构造器Object及Function自身。所有构造器都继承了`Function.prototype`的属性及方法。如length、call、apply、bind **

再看一张图，读完本文希望可以明白这些关系
![](http://static.zhyjor.com/201806101427_712.png)

## 序
先不用管是否理解，先将一些疑惑解释如下：

### 显式原型和隐式原型
在 JavaScript 原型继承结构里面，规范中用 [[Prototype]] 表示对象隐式的原型，在 JavaScript 中用 __proto__ 表示，并且在 Firefox 和 Chrome 浏览器中是可以访问得到这个属性的，但是 IE 下不行。所有 JavaScript 对象都有 __proto__ 属性，但只有 Object.prototype.__proto__ 为 null，前提是没有在 Firefox 或者 Chrome 下修改过这个属性。这个属性指向它的原型对象。 至于显示的原型，在 JavaScript 里用 prototype 属性表示，这个是 JavaScript 原型继承的基础知识。

* 每个对象（包括函数、函数的prototype对象）都有一个__proto__属性，她指向创建该对象的函数的prototype属性
* 每个函数都有一个prototype对象，而只有prototype对象才有constructor属性，其指向该函数本身，只有函数才有prototype属性
* 函数都是由function Function(){}创建的，所以上图__proto__实际上就是Function.prototype

### 普通对象与函数对象
Javascript中，一切都是对象，对象分为普通对象和函数对象，Object,Function是JS自带的函数对象
```js
// 普通对象
var o1 = {}; 
var o2 =new Object();
var o3 = new f1();

// 函数对象，f1,f2其实在内部也是通过new Function()创建的
function f1(){}; 
var f2 = function(){};
var f3 = new Function('str','console.log(str)');

console.log(typeof Object); //function 
console.log(typeof Function); //function  

console.log(typeof f1); //function 
console.log(typeof f2); //function 
console.log(typeof f3); //function   

console.log(typeof o1); //object 
console.log(typeof o2); //object 
console.log(typeof o3); //object

```
至于typeof的用法我们后续章节会重点说明的。

### 构造函数
如下的例子，看看构造函数的使用姿势
```js
function Person(name, age, job) {
 this.name = name;
 this.age = age;
 this.job = job;
 this.sayName = function() { alert(this.name) } 
}
// 两者都是Person的实例，两个实例都可以通过原型链获取到一个constructor（构造函数属性），该属性是一个指针
// 指向Person
var person1 = new Person('Zaxlct', 28, 'Software Engineer');
var person2 = new Person('Mick', 23, 'Doctor');

// 可以得到如下，构造函数属性是在原型链上获取的
console.log(person1.constructor == Person); //true
console.log(person2.constructor == Person); //true

```

可以得到**实例的构造函数属性（constructor）指向构造函数**

## 原型对象
在js中，没定义一个对象，对象中都会包含一些预定义的属性，其中函数对象都有一个`prototype`属性，这个属性指向函数的原型对象。
```js
function Person() {}
Person.prototype.name = 'Zaxlct';
Person.prototype.age  = 28;
Person.prototype.job  = 'Software Engineer';
Person.prototype.sayName = function() {
  alert(this.name);
}
  
var person1 = new Person();
person1.sayName(); // 'Zaxlct'

var person2 = new Person();
person2.sayName(); // 'Zaxlct'

console.log(person1.sayName == person2.sayName); //true

```
此处我们可以先确定一个结论：
**每个对象都有一个`__proto__`属性，但是只有函数对象才有prototype属性**

### 什么是原型对象
```
Person.prototype = {
   name:  'Zaxlct',
   age: 28,
   job: 'Software Engineer',
   sayName: function() {
     alert(this.name);
   }
}
```
原型对象，其实也是一个普通对象，只不过这个对象是构造函数的prototype属性，除此之外，没有任何特别之处。
上面的例子中，除了添加的四个属性外，还有一个默认的`constructor`属性
> 默认情况下，所有的原型对象都会自动获取一个constructor属性，这个属性是一个指针，指向prototype所在的函数，如上例中Person。

即：`Person.prototype.constructor == Person`

在上面的构造函数小节中，我们知道了**实例的构造函数属性（constructor）指向构造函数，`person1.constructor == Person`**

原型对象其实就是普通对象（但 Function.prototype 除外，它是函数对象，但它很特殊，他没有prototype属性（前面说道函数对象都有prototype属性））。看下面的例子：
```
function Person(){};
 console.log(Person.prototype) //Person{}
 console.log(typeof Person.prototype) //Object
 console.log(typeof Function.prototype) // Function，这个特殊
 console.log(typeof Object.prototype) // Object
 console.log(typeof Function.prototype.prototype) //undefined

```
**Function.prototype 为什么是函数对象呢？后续解决**

### 原型对象的用处
原型对象用于继承
```
var Person = function(name){
    this.name = name; // tip: 当函数执行时这个 this 指的是谁？
  };
  Person.prototype.getName = function(){
    return this.name;  // tip: 当函数执行时这个 this 指的是谁？
  }
  var person1 = new person('Mick');
  person1.getName(); //Mick

// 两次 this 在函数执行时都指向 person1。

```
从这个例子可以看出，通过给 Person.prototype 设置了一个函数对象的属性，那有 Person 的实例（person1）出来的普通对象就继承了这个属性。具体是怎么实现的继承，就要讲到下面的原型链了。

## `__proto__`

JS 在创建对象（不论是普通对象还是函数对象）的时候，都有一个叫做`__proto__`的内置属性，用于指向创建它的构造函数的原型对象。对象 person1 有一个 `__proto__`属性，创建它的构造函数是 Person，构造函数的原型对象是 Person.prototype ，所以：`person1.__proto__ == Person.prototype`

![《JavaScript 高级程序设计》的图 ](https://upload-images.jianshu.io/upload_images/1430985-b650bc438f236877.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/700)

由上图
```
Person.prototype.constructor == Person;
person1.__proto__ == Person.prototype;
person1.constructor == Person;
```
不过，要明确的真正重要的一点就是，**这个连接存在于实例（person1）与构造函数（Person）的原型对象（Person.prototype）之间，而不是存在于实例（person1）与构造函数（Person）之间。**

**也就是说继承的关键是是`Person.prototype`**

注意：因为绝大部分浏览器都支持__proto__属性，所以它才被加入了 ES6 里（ES5 部分浏览器也支持，但还不是标准）。在ES6中有了`getPrototypeof()`方法。

## 构造器
创建对象可以通过字面量，也可以通过构造函数，两者是等价的。
```
var obj = {}
var obj = new Object()
// obj 是构造函数（Object）的一个实例。所以：
obj.constructor === Object
obj.__proto__ === Object.prototype

```
新对象 obj 是使用 new 操作符后跟一个构造函数来创建的。构造函数（Object）本身就是一个函数（就是上面说的函数对象），它和上面的构造函数 Person 本质上是一样的，只不过该函数是出于创建新对象的目的而定义的。

同理，可以创建对象的构造器不仅仅有 Object，也可以是 Array，Date，Function等。
所以我们也可以构造函数来创建 Array、 Date、Function

```
var b = new Array();
b.constructor === Array;
b.__proto__ === Array.prototype;

var c = new Date(); 
c.constructor === Date;
c.__proto__ === Date.prototype;

var d = new Function();
d.constructor === Function;
d.__proto__ === Function.prototype;

```
这些构造器都是函数对象：
![](https://upload-images.jianshu.io/upload_images/1430985-b8373019f5f3bab3.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/700)

## 原型链
原型链我们可以结合以上的知识点来看几个问题：

* `person1.__proto__` 是什么？
* `Person.__proto__` 是什么？
* `Person.prototype.__proto__` 是什么？
* `Object.__proto__` 是什么？
* `Object.prototype__proto__` 是什么？

对应上述：
* 因为 `person1.__proto__ === person1` 的构造函数.prototype
因为 person1的构造函数 === Person
所以 `person1.__proto__ === Person.prototype`

* 因为 `Person.__proto__ === Person`的构造函数.prototype
因为 Person的构造函数 === Function
所以 `Person.__proto__ === Function.prototype`

* Person.prototype 是一个普通对象，我们无需关注它有哪些属性，只要记住它是一个普通对象。
因为一个普通对象的构造函数 === Object
所以 `Person.prototype.__proto__ === Object.prototype`

* Object 也是构造函数，因此同题目2`Object.__proto__ === Function.prototype`

* Object.prototype 对象也有`__proto__`属性，但它比较特殊，为 null 。因为 null 处于原型链的顶端，这个只能记住。`Object.prototype.__proto__ === null`


## 函数对象
**所有函数对象的proto都指向Function.prototype，它是一个空函数（Empty function）**
```js
Number.__proto__ === Function.prototype  // true
Number.constructor == Function //true

Boolean.__proto__ === Function.prototype // true
Boolean.constructor == Function //true

String.__proto__ === Function.prototype  // true
String.constructor == Function //true

// 所有的构造器都来自于Function.prototype，甚至包括根构造器Object及Function自身
Object.__proto__ === Function.prototype  // true
Object.constructor == Function // true

// 所有的构造器都来自于Function.prototype，甚至包括根构造器Object及Function自身
Function.__proto__ === Function.prototype // true
Function.constructor == Function //true

Array.__proto__ === Function.prototype   // true
Array.constructor == Function //true

RegExp.__proto__ === Function.prototype  // true
RegExp.constructor == Function //true

Error.__proto__ === Function.prototype   // true
Error.constructor == Function //true

Date.__proto__ === Function.prototype    // true
Date.constructor == Function //true

```
JavaScript中有内置(build-in)构造器/对象共计12个（ES5中新加了JSON），这里列举了可访问的8个构造器。剩下如Global不能直接访问，Arguments仅在函数调用时由JS引擎创建，Math，JSON是以对象形式存在的，无需new。它们的`__proto__`是Object.prototype。如下

```
Math.__proto__ === Object.prototype  // true
Math.construrctor == Object // true

JSON.__proto__ === Object.prototype  // true
JSON.construrctor == Object //true

```
上面说的函数对象当然包括自定义的。如下
```
// 函数声明
function Person() {}
// 函数表达式
var Perosn = function() {}
console.log(Person.__proto__ === Function.prototype) // true
console.log(Man.__proto__ === Function.prototype)    // true

```
这可以得到结论：**所有的构造器都来自于 Function.prototype，甚至包括根构造器Object及Function自身。所有构造器都继承了Function.prototype的属性及方法。如length、call、apply、bind**

Function.prototype也是唯一一个typeof XXX.prototype为 function的prototype。其它的构造器的prototype都是一个对象，如下：

```
console.log(typeof Function.prototype) // function
console.log(typeof Object.prototype)   // object
console.log(typeof Number.prototype)   // object
console.log(typeof Boolean.prototype)  // object
console.log(typeof String.prototype)   // object
console.log(typeof Array.prototype)    // object
console.log(typeof RegExp.prototype)   // object
console.log(typeof Error.prototype)    // object
console.log(typeof Date.prototype)     // object
console.log(typeof Object.prototype)   // object

```

**上面还提到它是一个空的函数，`console.log(Function.prototype)`**

知道了所有构造器（含内置及自定义）的`__proto__`都是Function.prototype，那`Function.prototype`的`__proto__`是谁呢？

相信都听说过JavaScript中函数也是一等公民，那从哪能体现呢？如下
```
console.log(Function.prototype.__proto__ === Object.prototype) // true
```

这说明所有的构造器也都是一个普通 JS 对象，可以给构造器添加/删除属性等。同时它也继承了Object.prototype上的所有方法：toString、valueOf、hasOwnProperty等。

最后Object.prototype的proto是谁？
`Object.prototype.__proto__ === null // true`
已经到顶了，为null。

## Prototype

在《JavaScript 高级程序设计》第三版 P116中：
> 在 ECMAScript 核心所定义的全部属性中，最耐人寻味的就要数 prototype 属性了。对于 ECMAScript 中的引用类型而言，prototype 是保存着它们所有实例方法的真正所在。换句话所说，诸如 toString()和 valuseOf() 等方法实际上都保存在 prototype 名下，只不过是通过各自对象的实例访问罢了。

我们知道 JS 内置了一些方法供我们使用，比如：
对象可以用 constructor/toString()/valueOf() 等方法;
数组可以用 map()/filter()/reducer() 等方法；
数字可用用 parseInt()/parseFloat()等方法；

**这其中的原因是什么？**

### 当我们创建一个函数时：
`var Person = new Object()`
Person 是 Object 的实例，所以 Person 继承了Object 的原型对象`Object.prototype`上所有的方法：

![](https://upload-images.jianshu.io/upload_images/1430985-99ba7f98c0bd06cd.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/700)

Object 的每个实例都具有以上的属性和方法。
所以我可以用 Person.constructor 也可以用 Person.hasOwnProperty。

### 当我们创建一个数组时：
var num = new Array()
num 是 Array 的实例，所以 num 继承了Array 的原型对象Array.prototype上所有的方法.我们可以用一个 ES5 提供的新方法：Object.getOwnPropertyNames
获取所有（包括不可枚举的属性）的属性名不包括 prototy 中的属性，返回一个数组：
```
var arrayAllKeys = Array.prototype; // [] 空数组
// 只得到 arrayAllKeys 这个对象里所有的属性名(不会去找 arrayAllKeys.prototype 中的属性)
console.log(Object.getOwnPropertyNames(arrayAllKeys)); 
/* 输出：
["length", "constructor", "toString", "toLocaleString", "join", "pop", "push", 
"concat", "reverse", "shift", "unshift", "slice", "splice", "sort", "filter", "forEach", 
"some", "every", "map", "indexOf", "lastIndexOf", "reduce", "reduceRight", 
"entries", "keys", "copyWithin", "find", "findIndex", "fill"]
*/

```
输出的数组里并没有 constructor/hasOwnPrototype等对象的方法,但是随便定义的数组也能用这些方法。因为Array.prototype 虽然没这些方法，但是它有原型对象（`__proto__`）：
```
// 上面我们说了 Object.prototype 就是一个普通对象。
Array.prototype.__proto__ == Object.prototype
```
所以 Array.prototype 继承了对象的所有方法，当你用num.hasOwnPrototype()时，JS 会先查一下它的构造函数 （Array） 的原型对象 Array.prototype 有没有有hasOwnPrototype()方法，没查到的话继续查一下 Array.prototype 的原型对象 `Array.prototype.__proto__`有没有这个方法。

### 当我们创建一个函数时：

```
var f = new Function("x","return x*x;");
//当然你也可以这么创建 f = function(x){ return x*x }
console.log(f.arguments) // arguments 方法从哪里来的？
console.log(f.call(window)) // call 方法从哪里来的？
console.log(Function.prototype) // function() {} （一个空的函数）
console.log(Object.getOwnPropertyNames(Function.prototype)); 
/* 输出
["length", "name", "arguments", "caller", "constructor", "bind", "toString", "call", "apply"]
*/

```

在上述章节中
> 所有函数对象`__proto__`都指向 Function.prototype，它是一个空函数（Empty function）

嗯，我们验证了它就是空函数。不过不要忽略前半句。我们枚举出了它的所有的方法，所以所有的函数对象都能用，比如:

![](https://upload-images.jianshu.io/upload_images/1430985-16bff45efb958d74.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/700)

最后再想想为什么：
```
Function.prototype 是唯一一个typeof XXX.prototype为 “function”的prototype
```
## 复习一下

```
所有函数对象的 __proto__ 都指向 Function.prototype，它是一个空函数（Empty function）
还有
所有对象的 __proto__ 都指向其构造器的 prototype

```

先看看 JS 内置构造器：

```
var obj = {name: 'jack'}
var arr = [1,2,3]
var reg = /hello/g
var date = new Date
var err = new Error('exception')
 
console.log(obj.__proto__ === Object.prototype) // true
console.log(arr.__proto__ === Array.prototype)  // true
console.log(reg.__proto__ === RegExp.prototype) // true
console.log(date.__proto__ === Date.prototype)  // true
console.log(err.__proto__ === Error.prototype)  // true

```

再看看自定义的构造器，这里定义了一个 Person：

```
function Person(name) {
  this.name = name;
}
var p = new Person('jack')
console.log(p.__proto__ === Person.prototype) // true
```
p 是 Person 的实例对象，p 的内部原型总是指向其构造器 Person 的原型对象 prototype。

每个对象都有一个 constructor 属性，可以获取它的构造器，因此以下打印结果也是恒等的：

```
function Person(name) {
    this.name = name
}
var p = new Person('jack')
console.log(p.__proto__ === p.constructor.prototype) // true
```

上面的Person没有给其原型添加属性或方法，这里给其原型添加一个getName方法：
```
function Person(name) {
    this.name = name
}
// 修改原型
Person.prototype.getName = function() {}
var p = new Person('jack')
console.log(p.__proto__ === Person.prototype) // true
console.log(p.__proto__ === p.constructor.prototype) // true

```
可以看到`p.__proto__`与`Person.prototype`，`p.constructor.prototype`都是恒等的，即都指向同一个对象。

如果换一种方式设置原型，结果就有些不同了：
```
function Person(name) {
    this.name = name
}
// 重写原型
Person.prototype = {
    getName: function() {}
}
var p = new Person('jack')
console.log(p.__proto__ === Person.prototype) // true
console.log(p.__proto__ === p.constructor.prototype) // false

```

这里直接重写了 `Person.prototype`（注意：上一个示例是修改原型）。输出结果可以看出`p.__proto__`仍然指向的是`Person.prototype`，而不是`p.constructor.prototype`。

这也很好理解，给`Person.prototype`赋值的是一个对象直接量`{getName: function(){}}`，使用对象直接量方式定义的对象其构造器（constructor）指向的是根构造器`Object`，`Object.prototype`是一个空对象{}，{}自然与`{getName: function(){}}`不等。如下：

```
var p = {}
console.log(Object.prototype) // 为一个空的对象{}
console.log(p.constructor === Object) // 对象直接量方式定义的对象其constructor为Object
console.log(p.constructor.prototype === Object.prototype) // 为true，不解释(๑ˇ3ˇ๑)

```
## 再看原型链

```
function Person(){}
var person1 = new Person();
console.log(person1.__proto__ === Person.prototype); // true
console.log(Person.prototype.__proto__ === Object.prototype) //true
console.log(Object.prototype.__proto__) //null

Person.__proto__ == Function.prototype; //true
console.log(Function.prototype)// function(){} (空函数)

var num = new Array()
console.log(num.__proto__ == Array.prototype) // true
console.log( Array.prototype.__proto__ == Object.prototype) // true
console.log(Array.prototype) // [] (空数组)
console.log(Object.prototype.__proto__) //null

console.log(Array.__proto__ == Function.prototype)// true

```
* `Object.__proto__ === Function.prototype // true`
Object 是函数对象，是通过new Function()创建的，所以`Object.__proto__`指向Function.prototype。（参照第八小节：「所有函数对象的`__proto__`都指向Function.prototype」）

* `Function.__proto__ === Function.prototype // true`
Function 也是对象函数，也是通过new Function()创建，所以`Function.__proto__`指向Function.prototype。

**原因需要确认，后续编辑**

* `Function.prototype.__proto__ === Object.prototype //true`

> Function.prototype是个函数对象，理论上他的`__proto__`应该指向 Function.prototype，就是他自己，自己指向自己，没有意义。
JS一直强调万物皆对象，函数对象也是对象，给他认个祖宗，指向`Object.prototype`。`Object.prototype.__proto__ === null`，保证原型链能够正常结束。

**原因需要确认，后续编辑**

## 总结
* 原型和原型链是JS实现继承的一种模型。
* 原型链的形成是真正是靠`__proto__` 而非prototype

```
var animal = function(){};
 var dog = function(){};

 animal.price = 2000;
 dog.prototype = animal;
 var tidy = new dog();
 console.log(dog.price) //undefined
 console.log(tidy.price) // 2000

```

```
var dog = function(){};
 dog.prototype.price = 2000;
 var tidy = new dog();
 console.log(tidy.price); // 2000
 console.log(dog.price); //undefined


 var dog = function(){};
 var tidy = new dog();
 tidy.price = 2000;
 console.log(dog.price); //undefined

```

> 实例（tidy）和 原型对象（dog.prototype）存在一个连接。不过，要明确的真正重要的一点就是，这个连接存在于实例（tidy）与构造函数的原型对象（dog.prototype）之间，而不是存在于实例（tidy）与构造函数（dog）之间。

**参考资料**
[最详尽的 JS 原型与原型链终极详解](https://www.jianshu.com/p/a4e1e7b6f4f8)
[JavaScript中proto与prototype的关系](http://www.cnblogs.com/snandy/archive/2012/09/01/2664134.html)
[IBM·JavaScript instanceof 运算符深入剖析·JavaScript 原型继承机制](https://www.ibm.com/developerworks/cn/web/1306_jiangjj_jsinstanceof/)
[JavaScript深入之从原型到原型链·冴羽](https://github.com/mqyqingfeng/Blog/issues/2)

![](http://static.zhyjor.com/wexin.png)
