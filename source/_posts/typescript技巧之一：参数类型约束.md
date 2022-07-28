---
title: typescript技巧之一：参数类型约束
tags:
  - typescript
  - 前端
categories: 前端
top: false
copyright: true
date: 2022-07-28 15:48:01
---
日常开发中我们经常会遇到*标记联合类型*了，一般都是出现在需要辨析联合类型的情况下，比如Redux中，一般就经常使用type来区分不同的action，进而通过判断语句进行类型守护
<!--more-->
比如：
```js
interface Square {
  kind: 'square';
  size: number;
}

interface Rectangle {
  kind: 'rectangle';
  width: number;
  height: number;
}

// 有人仅仅是添加了 `Circle` 类型
// 我们可能希望 TypeScript 能在任何被需要的地方抛出错误
interface Circle {
  kind: 'circle';
  radius: number;
}

type Shape = Square | Rectangle | Circle;

function area(s: Shape) {
  switch (s.kind) {
    case 'square':
      return s.size * s.size;
    case 'rectangle':
      return s.width * s.height;
    case 'circle':
      return Math.PI * s.radius ** 2;
    default:
      const _exhaustiveCheck: never = s;
  }
}
```

**参考资料**
[]()

![](https://static.zhyjor.com/wexin.png)