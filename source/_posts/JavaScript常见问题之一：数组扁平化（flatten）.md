---
title: JavaScript常见问题之一：数组扁平化（flatten）
tags:
  - JavaScript常见问题
  - js
categories: js
top: false
copyright: true
date: 2018-02-12 10:23:33
---
数组的扁平化，就是将一个嵌套多层的数组 array (嵌套可以是任何层数)转换为只有一层的数组。
```
var arr = [1, [2, [3, 4]]];
console.log(flatten(arr)) // [1, 2, 3, 4]
```
<!--more-->

### 四种方式如下

```js
// 数组扁平化
/**
 * 方法一：reduce()函数法
 * 这个方法利用了reduce最终返回一个值的特性
 *
 * @param arr
 */
const flatten = (arr) =>
    // reduce函数，接收一个函数作为累加器，数组中的每个值从低位开始缩减
    // 最终返回一个值
    // 最终计算为一个值。可以作为一个高阶函数，用于函数的compose
    // array.reduce(function(total, currentValue, currentIndex, arr), initialValue)
    // total：初始值，必须
    // currentValue: 必须当前元素
    // currentIndex: 可选，当前元素的索引
    // arr: 可选，当前元素所属的数组对象
    // initialValue:可选，当前元素所属的数组对象
    arr.reduce((a, b) =>
            a.concat(Array.isArray(b) ? flatten(b) : b)
        , [])

/**
 * 方法二：递归的方式，循环，判断是否是嵌套数组
 * @param arr
 * @returns {Array}
 */
const flatten_recursion = (arr) => {
    var result = []
    for (var i = 0, len = arr.length; i < len; i++) {
        if (Array.isArray(arr[i])) {
            result = result.concat(flatten_recursion(arr[i]))
        } else {
            result.push(arr[i])
        }
    }
    return result
}

/**
 * 方法三：利用toString方法，这个方法略残暴，无法区分数字与非数字全变为字符串了
 * @param arr
 */
const flatten_toString = (arr) =>
    // array的map方法，会返回一个新数组数组中的元素为原始数组调用函数处理后的值
    arr.toString().split(',').map(function (item) {
        // +号为了变成数字，假如原来的数组里包含数字和字符串就会有问题
        return +item
    })

/**
 * 方法四：利用es6的数组解构
 * @param arr
 * @returns {*}
 */
const flatten_deconstruction = (arr) => {
    // some()方法用来检测数组中的元素是否满足指定条件
    // 该方法会依次执行数组中的每个元素，若有一个元素满足条件就返回true，不再执行
    // 若没有满足条件的函数就返回false
    // 不会改变原始数组
    while (arr.some(item => Array.isArray(item))) {
        arr = [].concat(...arr)
    }
    return arr
}


var arr = [1, 2, 3, 4, [1, [1, [32, 3], 23], 2]]
console.log(flatten_deconstruction(arr))
```
**参考资料**
[【干货】js 数组详细操作方法及解析合集](https://juejin.im/post/5b0903b26fb9a07a9d70c7e0)
[译文 如何在 JavaScript 中更好地使用数组](https://juejin.im/post/5b8d0a74f265da431d0e7ec0)
[Array/Reduce](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Array/Reduce)

![](http://static.zhyjor.com/wexin.png)
