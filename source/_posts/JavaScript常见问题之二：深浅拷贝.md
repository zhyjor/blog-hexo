---
title: JavaScript常见问题之二：深浅拷贝
tags:
  - JavaScript常见问题
  - js
categories: js
top: false
copyright: true
date: 2018-02-22 15:00:41
---
深浅拷贝的定义需要区分好，简单来说就是是否递归地进行数组或对象的复制。
<!--more-->
## 数组的浅拷贝
```js
// 数组的浅拷贝
// 如果是数组，我们可以利用数组的一些方法比如：slice、concat 返
// 回一个新数组的特性来实现拷贝。
var arr = ['old', 1, true, null, undefined]

var new_arr = arr.concat();
// 用 slice 可以这样做：
// arrayObject.slice(start,end) 方法可从已有的数组中返回选定的元素。
// start	必需。规定从何处开始选取。如果是负数，那么它规定从数组尾部
// 开始算起的位置。也就是说，-1 指最后一个元素，-2 指倒数第二个元素，以此类推。

// 可选。规定从何处结束选取。该参数是数组片断结束处的数组下标。如果没有指定该参数，
// 那么切分的数组包含从 start
// 到数组结束的所有元素。如果这个参数是负数，那么它规定的是从数组尾部开始算起的元素。
// 返回一个新的数组，包含从 start 到 end （不包括该元素）的 arrayObject 中的元素。
// 请注意，该方法并不会修改数组，而是返回一个子数组。
//
// 如果想删除数组中的一段元素，应该使用方法 Array.splice()。
// splice() 方法向/从数组中添加/删除项目，然后返回被删除的项目。该方法会改变原始数组。
// arrayObject.splice(index,howmany,item1,.....,itemX)
// index	必需。整数，规定添加/删除项目的位置，使用负数可从数组结尾处规定位置。
// howmany	必需。要删除的项目数量。如果设置为 0，则不会删除项目。
// item1, ..., itemX	可选。向数组添加的新项目。
// 如果从 arrayObject 中删除了元素，则返回的是含有被删除的元素的数组。,
// var new_arr = arr.slice();

new_arr[0] = 'new';

console.log(arr) // ["old", 1, true, null, undefined]
console.log(new_arr) // ["new", 1, true, null, undefined]

// 但是若数组嵌套了对象
var arr = [{old: 'old'}, ['old']];

var new_arr = arr.concat();

arr[0].old = 'new';
arr[1][0] = 'new';
// 我们会发现，无论是新数组还是旧数组都发生了变化，
// 也就是说使用 concat 方法，克隆的并不彻底。
console.log(arr) // [{old: 'new'}, ['new']]
console.log(new_arr) // [{old: 'new'}, ['new']]
// 如果数组元素是基本类型，就会拷贝一份，互不影响，而如果是对象或者数组，就会只拷贝对象和数组的引用，这样我们无论在新旧数组进行了修改，两者都会发生变化。

// 我们把这种复制引用的拷贝方法称之为浅拷贝，与之对应的就是深拷贝，深拷贝就是指完全的拷贝一个对象，即使嵌套了对象，两者也相互分离，修改一个对象的属性，也不会影响另一个。

// 所以我们可以看出使用 concat 和 slice 是一种浅拷贝。
```
## 数组的深拷贝
```js
// 数组的深拷贝
// 那如何深拷贝一个数组呢？这里介绍一个技巧，不仅适用于数组还适用于对象！那就是：
var arr = ['old', 1, true, ['old1', 'old2'], {old: 1}]

var new_arr = JSON.parse(JSON.stringify(arr));

console.log(new_arr);
// 是一个简单粗暴的好方法，就是有一个问题，不能拷贝函数，我们做个试验：
// 而且即使是普通的对象，一些访问器属性也不能使用了。
var arr = [function () {
    console.log(a)
}, {
    b: function () {
        console.log(b)
    }
}]

var new_arr = JSON.parse(JSON.stringify(arr));
// 我们会发现 new_arr 变成了：
// https://github.com/mqyqingfeng/Blog/raw/master/Images/copy/copy1.png
console.log(new_arr);
```
## 浅拷贝的实现
```js
// 浅拷贝的实现
// 以上三个方法 concat、slice、JSON.stringify 都算是技巧类，可以根据实际项目情况选择使用，
// 接下来我们思考下如何实现一个对象或者数组的浅拷贝。
// 想一想，好像很简单，遍历对象，然后把属性和属性值都放在一个新的对象不就好了~
// 嗯，就是这么简单，注意几个小点就可以了：,
var shallowCopy = function (obj) {
    // 只拷贝对象
    if (typeof obj !== 'object') return;
    // 根据obj的类型判断是新建一个数组还是对象
    var newObj = obj instanceof Array ? [] : {};
    // 遍历obj，并且判断是obj的属性才拷贝
    for (var key in obj) {
        if (obj.hasOwnProperty(key)) {
            newObj[key] = obj[key];
        }
    }
    return newObj;
}

```
## 深拷贝的实现
```js
// 深拷贝的实现
// 那如何实现一个深拷贝呢？说起来也好简单，我们在拷贝的时候判断一下属性值的类型，
// 如果是对象，我们递归调用深拷贝函数不就好了~

const deepCopy = (obj) => {
    if (typeof obj !== 'Object') return
    let newObj = obj instanceof Array ? [] : {}
    for (let key in obj) {
        if (obj.hasOwnProperty(key)) {
            newObj[key] = typeof obj[key] === 'Object' ? deepCopy(obj[key]) : obj[key]
        }
    }
    return newObj
}
// 性能问题
// 尽管使用深拷贝会完全的克隆一个新对象，不会产生副作用，但是深拷贝因为使用递归，
// 性能会不如浅拷贝，在开发中，还是要根据实际情况进行选择。
```

**参考资料**
[]()

![](http://static.zhyjor.com/wexin.png)
