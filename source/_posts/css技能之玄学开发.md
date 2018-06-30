---
title: css技能之玄学开发
tags:
  - css
categories: css
top: false
copyright: true
date: 2018-06-26 14:20:55
---
css很简单，完全不懂的人大概看个一两天，就可以实现基本的页面效果；但是css也复杂，有些异常的效果，很多有经验的开发者也搞不明白该怎么解释。只能骂一句“又出bug了”。对于css来说，名字就是层叠样式表，关键是这个层叠，多个属性造就一个效果，一个异常也可能有多个属性引起的。还有些规范为定义的实现，这些学起来真的就是活脱脱的玄学开发。让我们从一些现象看起，通过现象看本质，希望玄学水平早日达到天人合一的境界。
<!--more-->
## 背景区域非矩形
问题出现在张大神的《css世界》4.2.2章节，大神的解释没看懂。

### 效果

代码及效果图如下：
```html
<div class="box">
    <span class="son">我国我国我国我国我国我国我国我国我国我国我国</span>
</div>
```
样式如下，因为内联元素的padding只影响视觉层不会影响布局层，所以最好在测试的元素上加点对上边界的margin，否则会看不到padding-top的内容。
```css
.box {
    border: 2px dashed #cd0000;
}
.son {
    padding: 50%;
    background-color: gray;
}
```
![](http://oankigr4l.bkt.clouddn.com/201806261508_98.png)

### 疑问点

疑问如下：
* 第一行、第二行看起来有些字被覆盖了
* 第二行怎么没铺满就换行了
* 最后一行怎么就一个字
* 英文怎么不换行

### 解释
其实如下图所示，有些消失的字时被背景覆盖了
![](http://oankigr4l.bkt.clouddn.com/201806261516_379.png)

对于white-space ：normal，文本自动处理换行.假如抵达容器边界内容会转到下一行，

因为有padding，当padding达到边界时，会带着最后一个字（铺满倒数第二行后，多余的字）换行

然后倒数第二行已经不是边界了，所以没有padding-left和right了，所以假如有多余的字，这一行就肯定铺满

最后因为汉字（东亚文字）最小宽度为每个汉字的宽度，可以在任何需要的时候换行，而西方文字最小宽度由特定的连续的英文字符单元决定。所以全部是是字母，就不会换行，因为找不到能换行的点，中间补上空格（普通空格）、短横线、问号以及其他非英文字符等就看到换行了。



## 父子margin合并的玄学问题
这个有个很神奇的现象，在实际开发的时候，给我们带来麻烦的多半就是这里的父子 margin 合并。

### 效果

我们给值元素设置一个margin-top的值，结果发现父元素的北京掉下来了。
代码如下：
```html
<div class="container">
    <h2>我是标题</h2>
</div>
```

```css
 .container {
    max-width: 356px;
    height: 289px;
    background: url(../assets/3.jpg) no-repeat;
}
.container > h2 {
    font-size: 38px;
    margin-top: 100px;
    color: #fff;
}
```
效果图：
![](http://oankigr4l.bkt.clouddn.com/201806261612_12.png)

### 问题解释

问题产生的原因就是这里的父子 margin 合并。这里大家需要理清楚“合并”这个概念。如果我们按照中文释义理解，应该必须有多个对象才能进行合并，否则根本就没有“合”这一说，确实如此。但是，这样理解也有可能会带来这样一个误区，即你要出点儿力，我要出点儿力，才叫“合”，其实不然。放到我们这里，这个父子 margin 合并的案例上就是：父元素没有出一点力，子元素出了全部的力，然后最终的 margin 全部合到了父元素上。也就是虽然是在子元素上设置的 margin-top，但实际上就等同于在父元素上设置了 margin-top，我想这样大家就能理解为何头图会掉下来了吧。

但是有一点需要注意，“等同于”并不是“就是”的意思，我们使用 getComputedStyle 方法获取父元素的 margin-top 值还是 CSS 属性中设置值，并非 margin 合并的表现值。

### 如何解决问题
那该如何阻止这里 margin 合并的发生呢？对于 margin-top 合并，可以进行如下操作（满足一个条件即可）：
* 父元素设置为块状格式化上下文元素；
* 父元素设置 border-top 值；
* 父元素设置 padding-top 值；
* 父元素和第一个子元素之间添加内联元素进行分隔。

对于 margin-bottom 合并，可以进行如下操作（满足一个条件即可）：
* 父元素设置为块状格式化上下文元素；
* 父元素设置 border-bottom 值；
* 父元素设置 padding-bottom 值；
* 父元素和最后一个子元素之间添加内联元素进行分隔；
* 父元素设置 height、 min-height 或 max-height。

所以，上面因为 margin 合并导致头图掉下来的问题可以添加下面的 CSS 代码进行
修复：
```css
.container {
	overflow: hidden;
}
```
其原理就是通过设置 overflow 属性让父级元素块状格式化上下文。

### 扩展
jQuery 中有个$().slideUp()/$().slideDown()方法，如果在使用这个动画效果的时候，发现这内容在动画开始或结束的时候会跳一下，那八九不离十就是布局存在 margin 合并。 跳动之所以产生，就是因为 jQuery 的 slideUp 和 slideDown方法在执行的时候会被对象元素添加 overflow:hidden 设置，而 overflow: hidden 会阻止 margin 合并，于是一瞬间间距变大，产生了跳动。


## 单行文本的高度

### 现象

很多人都有这样一个错误的认知，认为对于单行文本，只要行高设置多少，其占据高度就是多少。比方说，对于下面非常简单的 CSS 和 HTML 代码：
```
.box { line-height: 32px; }
.box > span { font-size: 24px; }
<div class="box">
	<span>文字</span>
</div>

```
.box 元素的高度是多少？
很多人一定认为是 32px：因为没有设置 height 等属性，高度就由 line-height 决定，与 font-size 无关，所以这里明摆着最终高度就是 32px。

**但是事实上，高度并不是 32px，而是要大那么几像素（受不同字体影响，增加高度也不一样）， 比方说 36px如下图：**

![](http://oankigr4l.bkt.clouddn.com/201806271636_756.png)

### 分析

这里，之所以最终.box 元素的高度并不等于 line-height，就是因为行高的朋友属性 vertical-align 在背后默默地下了黑手。

其中有一个很关键的点，那就是 24px 的 font-size 大小是设置在`<span>`元素上的，这就导致了外部`<div>`元素的字体大小和`<span>`元素有较大出入。看不见的东西不利于理解，因此我们不妨使用一个看得见的字符 x占位，同时“文字”后面也添加一个 x，便于看出基线位置，于是就有如下 HTML：
```html
<div class="box">
	x<span>文字 x</span>
</div>
```
此时，我们可以明显看到两处大小完全不同的文字。一处是字母 x 构成了一个“匿名内联盒子”，另一处是“文字 x”所在的`<span>`元素，构成了一个“内联盒子”。由于都受 lineheight:32px影响，因此，这两个“内联盒子”的高度都是 32px。

对字符而言， font-size 越大字符的基线位置越往下，因为文字默认全部都是基线对齐，所以当字号大小不一样的两个文字在一起的时候，彼此就会发生上下位移，如果位移距离足够大，就会超过行高的限制，而导致出现意料之外的高度,如下图：
![](http://oankigr4l.bkt.clouddn.com/201806271642_860.png)

### 解决
知道了问题发生的原因，那问题就很好解决了。我们可以让“幽灵空白节点”和后面`<span>`元素字号一样大，也就是：
```css
.box {
	line-height: 32px;
	font-size: 24px;
}
.box > span { }
```
或者改变垂直对齐方式，如顶部对齐，这样就不会有参差位移了：

```css
.box { line-height: 32px; }
.box > span {
	font-size: 24px;
	vertical-align: top;
}
```

## 图片底部留有间隙(扩展上述问题)
搞清楚了大小字号文字的高度问题，对更为常见的图片底部留有间隙的问题的理解就容易多了。现象是这样的：任意一个块级元素，里面若有图片，则块级元素高度基本上都要比图片的高度高。例如：
### 问题描述
```
<div class="box">
	<img src="1.jpg">
</div>

.box {
	width: 280px;
	outline: 1px solid #aaa;
	text-align: center;
}
.box > img {
	height: 96px;
}
```
结果.box 元素底部平白无故多了 5 像素。

![](http://oankigr4l.bkt.clouddn.com/201806271649_774.png)

### 分析

间隙产生的三大元凶就是“幽灵空白节点”、 line-height 和 vertical-align 属性。为了直观演示原理，我们可以在图片前面辅助一个字符 x 代替“幽灵空白节点”，并想办法通过背景色显示其行高范围，于是，大家就会看到如图所示的现象:

![](http://oankigr4l.bkt.clouddn.com/201806271650_779.png)

当前 line-height 计算值是 20px，而 font-size 只有 14px，因此，字母 x 往下一定有至少 3px 的半行间距（具体大小与字体有关），**而图片作为替换元素其基线是自身的下边缘。**根据定义，默认和基线（也就是这里字母 x 的下边缘）对齐，字母 x 往下的行高产生的多余的间隙就嫁祸到图片下面，让人以为是图片产生的间隙，实际上，是“幽灵空白节点”、line-height 和 vertical-align 属性共同作用的结果。

### 解决
知道了原理，要清除该间隙，就知道如何对症下药了。方法很多，具体如下。
* 图片块状化。可以一口气干掉“幽灵空白节点”、 line-height 和 verticalalign。
* 容器 line-height 足够小。只要半行间距小到字母 x 的下边缘位置或者再往上，自然就没有了撑开底部间隙高度空间了。比方说，容器设置 line-height:0。
* 容器 font-size 足够小。此方法要想生效，需要容器的 line-height 属性值和当前 font-size 相关，如 line-height:1.5 或者 line-height:150%之类；否则只会让下面的间隙变得更大，因为基线位置因字符 x 变小而往上升了。
* 图片设置其他 vertical-align 属性值。间隙的产生原因之一就是基线对齐，所以我们设置 vertical-align 的值为 top、 middle、bottom 中的任意一个都是可以的。


## 内联特性导致的 margin 无效
紧跟上述问题
```
<div class="box">
	<img src="mm1.jpg">
</div>
.box > img {
	height: 96px;
	margin-top: -200px;
}
```
这里的例子也很有代表性。一个容器里面有一个图片，然后这张图片设置 margin-top负值，让图片上偏移。但是，随着我们的负值越来越负，结果达到某一个具体负值的时候，图片不再往上偏移了。比方说，本例 margin-top 设置的是-200px，如果此时把 margin-top设置成-300px，图片会再往上偏移 100px 吗？不会！它会微丝不动， margin-top 变得无效了。要解释这里为何会无效，需要对 vertical-align 和内联盒模型有深入的理解。

### 分析
此时，按照理解， -200px 远远超过图片的高度，图片应该完全跑到容器的外面，但是，图片依然有部分在.box 元素中，而且就算 margin-top 设置成-99999px，图片也不会继续往上移动，完全失效。其原理和上面图片底部留有间隙实际上是一样的，图片的前面有个“幽灵空白节点”，**而在 CSS 世界中，非主动触发位移的内联元素是不可能跑到计算容器外面的，**导致图片的位置被“幽灵空白节点”的 vertical-align:baseline 给限死了。我们不妨把看不见的“幽灵空白节点”使用字符 x 代替,原因就一目了然了。

![](http://oankigr4l.bkt.clouddn.com/201806271700_105.png)

因为字符 x 下边缘和图片下边缘对齐，字符 x 非主动定位，不可能跑到容器外面，所以图片就被限死在此问题， margin-top 失效。

## 空的 inline-block 元素的高度居然不是0
[紧跟上述，再看一个复杂点的问题：](http://demo.cssworld.cn/5/3-6.php)
### 问题描述
text-align:jusitfy 声明可以帮助我们实现兼容的列表两端对齐效果，但是 text-align:jusitfy 两端对齐需要内容超过一行，同时为了让任意个数的列表最后一行也是左对齐排列，我们需要在列表最后辅助和列表宽度一样的空标签元素来占位，类似下面 HTML 代码的`<i>`标签：
```
.box {
	text-align: justify;
}
.justify-fix {
	display: inline-block;
	width: 96px;
}
<div class="box">
	<img src="1.jpg" width="96">
	<img src="1.jpg" width="96">
	<img src="1.jpg" width="96">
	<img src="1.jpg" width="96">
	<i class="justify-fix"></i>
	<i class="justify-fix"></i>
	<i class="justify-fix"></i>
</div>
```
空的 inline-block 元素的高度是 0，按照通常的理解，下面应该是一马平川，结果却有非常大的空隙存在:

![](http://oankigr4l.bkt.clouddn.com/201806271708_269.png)

为了便于大家看个究竟，我把占位`<i>`元素的 outline 属性用虚外框标示一下:
![](http://oankigr4l.bkt.clouddn.com/201806271709_877.png)

按照之前解决问题的方法，我们可以直接给.box 元素来个 line-height:0 解决垂直间隙问题，结果，这样设置之后的效果,图片和图片之间的间隙是没有了，但是图片和最后的占位元素之间依然有几像素的间距.

### 分析

简单现象的背后往往有大的学问，要明白其原因 ， 就需 要说 到 inline-block 元 素 和 基 线baseline 之间的一些纠缠的关系。

vertical-align 属性的默认值 baseline 在文本之类的内联元素那里就是字符 x 的下边缘，对于替换元素则是替换元素的下边缘。但是，如果是 inline-block 元素，则规则要复杂了： **一个 inline-block 元素，如果里面没有内联元素，或者 overflow 不是 visible，则该元素的基线就是其 margin 底边缘；否则其基线就是元素里面最后一行内联元素的基线。**

对于我们上面的问题，上面的规范已经说明了一切。第一个框里面没有内联元素，因此基线就是容器的margin 下边缘，也就是下边框下面的位置；而第二个框里面有字符，纯正的内联元素，因此第二个框就是这些字符的基线，也就是字母 x 的下边缘了。于是，我们就看到了左边框框下边缘和右边框框里面字符 x 底边对齐的好戏。

![](http://oankigr4l.bkt.clouddn.com/201806280950_712.jpg)

因为字符实际占据的高度是由 line-height 决定的，当 line-height 变成 0 的时候，字符占据的高度也是 0，此时，高度的起始位置就变成了字符内容区域的垂直中心位置，于是文字就有一半落在框的外面了。

现在行高 line-height 是 0，则字符x-baseline 行间距就是-1em，也就是高度为 0，由于 CSS 世界中的行间距是上下等分的，因此，此时字符 x-baseline 的对齐点就是当前内容区域（可以看成文字选中背景区域）的垂直中心位置。 x-baseline 使用的是微软雅黑字体，字形下沉明显，因此，内容区域的垂直中心位置大约在字符 x 的上面 1/4 处。而这个位置就是字符 x-baseline 和最后一行图片下边缘交汇的地方。



**理解了 x-baseline 的垂直位置表现，间隙问题就很好理解了。由于前面的`<i class="justify-fix"></i>`是一个 inline-block 的空元素，因此基线就是自身的底部，于是下移了差不多 3/4 个 x 的高度，这个下移的高度就是上面产生的间隙高度。**

### 解决
好了，一旦知道了现象的本质，我们就能轻松对症下药了！要么改变占位`<i>`元素的基线，
要么改造“幽灵空白节点”的基线位置，要么使用其他 vertical-align 对齐方式。

#### 改变基线位置
只要在空的`<i>`元素里面随便放几个字符就可以了。例如，塞一个空格&nbsp：
```
.box {
	text-align: justify;
	line-height: 0;
}
<div class="box">
	<img src="1.jpg" width="96">
	<img src="1.jpg" width="96">
	<img src="1.jpg" width="96">
	<img src="1.jpg" width="96">
	<i class="justify-fix">&nbsp;</i>
	<i class="justify-fix">&nbsp;</i>
	<i class="justify-fix">&nbsp;</i>
</div>
```
为了更分明一些，我们将空格改为字符“xxx”，如下图：
![](http://oankigr4l.bkt.clouddn.com/201806281018_628.png)

因为这个时候前两个`<i>`的元素错位已经没有了，最后一个自然就向上没有间隙了，但是，假如最后一个没有字符，依然会有间隙，如下图：
![](http://oankigr4l.bkt.clouddn.com/201806281025_865.png)

这个时候的解释其实就是，虽然已经换行了，但是对齐点还是要和上一行的元素进行对齐，也就是说要和倒数第二个`<i>`对齐，就变成相同的问题了，即错位对齐了，所以每个`<i>`内都要添加元素才可以。

为什么呢？因为此时`<i>`元素的基线是里面字符的基线，此基线也正好和外面的“幽灵空白节点”的基线位置一致，没有了错位，就没有间隙。

### 改造“幽灵空白节点”的基线位置
可以使用 font-size，当字体足够小时，基线和中线会重合在一起。什么时候字体足够小呢？就是 0。于是，如下 CSS 代码（line-height 如果是相对 font-size 的属性值， line-height:0 也可以省掉）：

```css
.box {
	text-align: justify;
	font-size: 0;
}
```
看上去好像效果类似，都是没有间隙，但是font-size:0 下的各类对齐效果都更彻底。**这时的幽灵节点已经没有高度了，肯定没有间隙了。**

### 修改vertical-align 对齐方式
使用其他 vertical-align 对齐方式就是让`<i>`占位元素vertical-align:top/bottom之类，当前，前提还是先让容器 line-height:0，例如：
```css
.box {
	text-align: justify;
	line-height: 0;
}
.justify-fix {
	vertical-align: top; /* top、 middle 都可以 */
}
```
下图是top对齐的情况，这个时候其实没有了对不齐的基线问题了肯定就不会显示异常了。
![](http://oankigr4l.bkt.clouddn.com/201806281031_465.png)
这个时候还会有疑问，假如接着增加`<i>`的个数，就不会出现对不齐吗，当然不会，下一行都是相对于上一行进行的，也就是说其实换行，对齐依然对的是上一行的元素，**只要对齐位置没问题，就不会出现间隙。**
![](http://oankigr4l.bkt.clouddn.com/201806281035_54.png)

### 总结
归根结底，就是inline-block基线位置问题，基线位置不同，就出现了错位的现象，只要消除了错位，就不会出现间隙。**时时刻刻谨记一个块级元素内出现内联元素的时候，这个时候一定要考虑匿名内联，考虑了匿名内联，就要考虑匿名内联的空白幽灵高度，然后还有考虑空白幽灵节点的对齐是基线对齐**

**参考资料**
[css玄学之一二](https://www.colabug.com/2627987.html)
[css玄学之一二·蘑菇街大神](https://echizen.github.io/tech/2018/04-05-read-css-world)
[垂直对齐：vertical-align属性（转）](https://www.cnblogs.com/rixinren2010/archive/2012/03/10/2389301.html)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)