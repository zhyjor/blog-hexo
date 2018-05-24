---
title: JavaScript常见问题之三：arguments类数组对象
tags:
  - JavaScript常见问题
  - js
categories: js
top: false
copyright: true
date: 2018-02-24 09:00:44
---
当函数被调用时，传入的参数将保存在arguments类数组对象中，通过arguments可以访问所有该函数被调用时传递给它的参数列表。

<!--more-->

## 基础

arguments对象是所有（非箭头）函数中都可用的局部变量。你可以使用arguments对象在函数中引用函数的参数。此对象包含传递给函数的每个参数的条目，第一个条目的索引从0开始。例如，如果一个函数传递了三个参数，你可以以如下方式引用他们：
```js
arguments[0]
arguments[1]
arguments[2]

// 参数也可以被设置：
arguments[1] = 'new value';
```
arguments对象不是一个 Array 。它类似于Array，但除了length属性和索引元素之外没有任何Array属性。例如，它没有 pop 方法。但是它可以被转换为一个真正的Array：
```js
var args = Array.prototype.slice.call(arguments);
var args = [].slice.call(arguments);

// ES2015
const args = Array.from(arguments);
```
对参数使用slice会阻止某些JavaScript引擎中的优化 (比如 V8 - 更多信息)。如果你关心性能，尝试通过遍历arguments对象来构造一个新的数组。另一种方法是使用被忽视的Array构造函数作为一个函数：

```js
var args = (arguments.length === 1 ? [arguments[0]] : Array.apply(null, arguments));
```

如果调用的参数多于正式声明接受的参数，则可以使用arguments对象。这种技术对于可以传递可变数量的参数的函数很有用。使用 arguments.length来确定传递给函数参数的个数，然后使用arguments对象来处理每个参数。要确定函数签名中（输入）参数的数量，请使用Function.length属性。

### 对参数使用 typeof
typeof参数返回 'object'。
```js
console.log(typeof arguments);    // 'object'
// arguments 对象只能在函数内使用
function test(a){
    console.log(a,Object.prototype.toString.call(arguments));
    console.log(arguments[0],arguments[1]);
    console.log(typeof arguments[0]);
}
test(1);
/*
1 "[object Arguments]"
1 undefined
number
*/
```
可以使用索引确定单个参数的类型。
```js
console.log(typeof arguments[0]); //this will return the typeof individual arguments.
```
### 对参数使用扩展语法
您还可以使用Array.from()方法或扩展运算符将参数转换为真实数组：
```js
var args = Array.from(arguments);
var args = [...arguments];
```

## 属性
**注意:现在在严格模式下，arguments对象已与过往不同。arguments[@@iterator]不再与函数的实际形参之间共享，同时caller属性也被移除。**
### arguments.callee
指向当前执行的函数。
虽然arguments的主要用途是保存函数参数，但这个对象还有一个callee属性，该属性是一个指针，指向拥有这个arguments对象的函数。

使用该属性可以实现一个阶乘函数：
```js
function factorial(num){
  if (num <= 1) {
        return 1;
  } else{
        return num * arguments.callee(num - 1);
  }
}
```
**在严格模式下，不能使用argumengs.callee**
可以修改为普通的迭代：
```js
var factorial = (function f(num){
      if(num <= 1){
           return 1;
      }else{
           return num*f(num-1);
      }
});
```
### arguments.caller
指向调用当前函数的函数。
### arguments.length
指向传递给当前函数的参数数量，arguments.length是由传入的参数个数决定的，而不是由定义函数时的命名参数的个数决定的。
### arguments[@@iterator]
返回一个新的Array迭代器对象，该对象包含参数中每个索引的值。


## 简单使用

### 遍历参数求和
通过arguments可以实现一个add()函数，把传入的参数进行加法运算并把值返回：

```js
function add() {
    var sum =0,
        len = arguments.length;
    for(var i=0; i<len; i++){
        sum += arguments[i];
    }
    return sum;
}
add()                           // 0
add(1)                          // 1
add(1,2,3,4);                   // 10
```

### 定义连接字符串的函数
这个例子定义了一个函数来连接字符串。这个函数唯一正式声明了的参数是一个字符串，该参数指定一个字符作为衔接点来连接字符串。该函数定义如下：
```js
function myConcat(separator) {
  var args = Array.prototype.slice.call(arguments, 1);
  return args.join(separator);
}
// 你可以传递任意数量的参数到该函数，并使用每个参数作为列表中的项创建列表。
// returns "red, orange, blue"
myConcat(", ", "red", "orange", "blue");

// returns "elephant; giraffe; lion; cheetah"
myConcat("; ", "elephant", "giraffe", "lion", "cheetah");

// returns "sage. basil. oregano. pepper. parsley"
myConcat(". ", "sage", "basil", "oregano", "pepper", "parsley");
```
### 定义创建HTML列表的方法
这个例子定义了一个函数通过一个字符串来创建HTML列表。这个函数唯一正式声明了的参数是一个字符。当该参数为 "u" 时，创建一个无序列表 (项目列表)；当该参数为 "o" 时，则创建一个有序列表 (编号列表)。该函数定义如下：
```js
function list(type) {
  var result = "<" + type + "l><li>";
  var args = Array.prototype.slice.call(arguments, 1);
  result += args.join("</li><li>");
  result += "</li></" + type + "l>"; // end list

  return result;
}

// 你可以传递任意数量的参数到该函数，并将每个参数作为一个项添加到指定类型的列表中。例如：

var listHTML = list("u", "One", "Two", "Three");

/* listHTML is:

"<ul><li>One</li><li>Two</li><li>Three</li></ul>"

*/
```

## 剩余参数、默认参数和解构赋值参数
arguments对象可以与剩余参数、默认参数和解构赋值参数结合使用。
```js
function foo(...args) {
  return args;
}
foo(1, 2, 3);  // [1,2,3]
```
在严格模式下，剩余参数、默认参数和解构赋值参数的存在不会改变 arguments对象的行为，但是在非严格模式下就有所不同了。

当非严格模式中的函数没有包含剩余参数、默认参数和解构赋值，那么arguments对象中的值会跟踪参数的值（反之亦然）。看下面的代码：
```js
function func(a) { 
  arguments[0] = 99;   // 更新了arguments[0] 同样更新了a
  console.log(a);
}
func(10); // 99
```
并且
```js
function func(a) { 
  a = 99;              // 更新了a 同样更新了arguments[0] 
  console.log(arguments[0]);
}
func(10); // 99
```
当非严格模式中的函数有包含剩余参数、默认参数和解构赋值，那么arguments对象中的值不会跟踪参数的值（反之亦然）。相反, arguments反映了调用时提供的参数：
```js
function func(a = 55) { 
  arguments[0] = 99; // updating arguments[0] does not also update a
  console.log(a);
}
func(10); // 10
```
并且
```js
function func(a = 55) { 
  a = 99; // updating a does not also update arguments[0]
  console.log(arguments[0]);
}
func(10); // 10
```
并且
```js
function func(a = 55) { 
  console.log(arguments[0]);
}
func(); // undefined
```

## 总结
* 每个函数都有一个arguments属性，表示函数的实参集合，这里的实参是重点，就是执行函数时实际传入的参数的集合。
* arguments不是数组而是一个对象，但它和数组很相似，所以通常称为类数组对象，以后看到类数组其实就表示arguments。
* arguments有length属性，可以用arguments[length]显示调用
* 注意类数组转数组的方法
* 注意callee的严格模式下不能使用
* 注意严格模式下修改参数会有语法错误
* 注意非严格模式下有没有包含剩余参数，默认参数，解构赋值等，对能否修改参数是有影响的，后者不能。



**参考资料**
[]()

![](http://oankigr4l.bkt.clouddn.com/wexin.png)