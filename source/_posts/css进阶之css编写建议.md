---
title: css进阶之css编写建议
tags:
  - css
copyright: true
date: 2018-01-13 15:25:12
categories: css
---
css是一个很矛盾的东西，即复杂又简单，你很容易的使用它做出某些效果，一个效果有很多种的实现方式；实现方式越多，越容易写的不知所云。而且有时候写出来的效果和最初的预想差别很大，但是我们这时候就会说："应该就是这样啊！"本文就是讲这些应该这样的点指出来“到底要怎样”
![](http://img.wxcha.com/file/201704/11/5b66961fe5.jpg)

<!--more-->

#### Margin崩塌
不同于其他很多属性，盒模型中垂直方向上的Margin会在相遇时发生崩塌，也就是说当某个元素的底部Margin与另一个元素的顶部Margin相邻时，只有二者中的较大值会被保留下来。详情可以查看另一篇关于[盒模型](https://zhyjor.github.io/2017/10/25/css%E8%BF%9B%E9%98%B6%E7%B3%BB%E5%88%97%E4%B9%8B%E7%9B%92%E6%A8%A1%E5%9E%8B/)的博客

#### 使用css reset
虽然这些年来随着浏览器的迅速发展与规范的统一，浏览器特性碎片化的情况有所改善，但是在不同的浏览器之间仍然存在着很多的行为差异。而解决这种问题的最好的办法就是使用某个CSS Reset来为所有的元素设置统一的样式，保证你能在相对统一干净的样式表的基础上开始工作。目前流行的Reset库有 normalize.css, minireset以及 ress ，它们都可以修正很多已知的浏览器之间的差异性

#### 关于box-sizing
最好的理解它的方式就是看看它的两种取值，详情可以查看另一篇关于[盒模型](https://zhyjor.github.io/2017/10/25/css%E8%BF%9B%E9%98%B6%E7%B3%BB%E5%88%97%E4%B9%8B%E7%9B%92%E6%A8%A1%E5%9E%8B/)的博客


#### Table borders
通过设置`border-collapse:collapse`

#### 使用Kebab-case命名变量

建议是使用BEM规范，只要遵循一些简单的原则即可以保证基于组件风格的命名一致性。你也可以参考CSS Tricks来获得更多的细节描述。

#### 避免重复代码
大部分元素的CSS属性都是从DOM树根部继承而来，这也是其命名为级联样式表的由来。我们以font属性为例，该属性往往是继承自父属性，因此我们并不需要再单独地为元素设置该属性。我们只需要在html或者body中添加该属性然后使其层次传递下去即可

#### 使用transform添加CSS Animations
不建议直接改变元素的width与height属性或者left/top/bottom/right这些属性来达到动画效果，而应该优先使用transform()属性来提供更平滑的变换效果，并且能使得代码的可读性会更好:
```
.ball {
    left: 50px;
    transition: 0.4s ease-out;
}/* Not Cool*/.ball.slide-out {
    left: 500px;
}/* Cool*/.ball.slide-out {
    transform: translateX(450px);
}
```
Transform的几个属性translate、rotate、scale都具有比较好的浏览器兼容性可以放心使用。


#### 尽可能使用低优先级的选择器
并不是所有的CSS选择器的优先级都一样，很多初学者在使用CSS选择器的时候都是考虑以新的特性去复写全部的继承特性，不过这一点在某个元素多状态时就麻烦了
```
a{
    color: #fff;
    padding: 15px;
}

a#blue-btn {
    background-color: blue;
}

a.active {
    background-color: red;
}
```
我们本来希望将.active类添加到按钮上然后使其显示为红色，不过在上面这个例子中很明显起不了作用，因为button已经以ID选择器设置过了背景色，也就是所谓的Higher Selector Specificity。

**一般来说，选择器的优先级顺序为：ID(#id) > Class(.class) > Type(header)**


#### 避免使用!important
认真的说，千万要避免使用!important，这可能会导致你在未来的开发中无尽的属性重写，你应该选择更合适的CSS选择器。而唯一的可以使用!important属性的场景就是当你想去复写某些行内样式的时候，不过行内样式本身也是需要避免的。

####Em, Rem, 以及 Pixel
* em – 其基本单位即为当前元素的font-size值，经常适用于media-queries中，em是特别适用于响应式开发中。
* rem – 其是相对于html属性的单位，可以保证文本段落真正的响应式尺寸特性。
* px – Pixels 并没有任何的动态扩展性，它们往往用于描述绝对单位，并且可以在设置值与最终的显示效果之间保留一定的一致性。

#### 使用text-transform属性设置文本大写
`text-transform: uppercase;`


#### 使用Autoprefixers来提升浏览器兼容性
* Online tools: Autoprefixer
* Text editor plugins: Sublime Text, Atom
* Libraries: Autoprefixer (PostCSS)



#### 在大型项目中使用预处理器
估计你肯定听说过 Sass, Less, PostCSS, Stylus这些预处理器与对应的语法。Preprocessors可以允许我们将未来的CSS特性应用在当前的代码开发中，譬如变量支持、函数、嵌套式的选择器以及很多其他的特性

#### 在生产环境下使用Minified代码
* Online tools – CSS Minifier (API included), CSS Compressor
* Text editor plugins: Sublime Text, Atom
* Libraries: Minfiy (PHP), CSSO and CSSNano (PostCSS, Grunt, Gulp)

#### 多参阅Caniuse
不同的浏览器在兼容性上差异很大，因此如果我们可以针对我们所需要适配的浏览器，在caniuse上我们可以查询某个特性的浏览器版本适配性，是否需要添加特定的前缀或者在某个平台上是否存在Bug等等。不过光光使用[caniuse](https://caniuse.com/)肯定是不够的，我们还需要使用些额外的服务来进行检测。

#### Validate:校验
对于CSS的校验可能不如HTML校验或者JavaScript校验那么重要，不过在正式发布之前用Lint工具校验一波你的CSS代码还是很有意义的。它会告诉你代码中潜在的错误，提示你一些不符合最佳实践的代码以及给你一些提升代码性能的建议。就像Minifers与Autoprefixers，也有很多可用的工具:
* Online tools: W3 Validator, CSS Lint
* Text editor plugins: Sublime Text, Atom
* Libraries: stylelint (Node.js, PostCSS), css-validator (Node.js)

![](http://img.wxcha.com/file/201704/11/b1e20cad0d.jpg)


**参考资料**
[20个编写现代CSS代码的建议](http://www.codeceo.com/article/20-modern-css-tips.html)

![](http://img.hb.aicdn.com/ec75ffa7051ca66d3a2dc01ec18e374a53e1e71a22e899-GrMUJ9_fw658)