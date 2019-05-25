---
title: 动效开发之一：SVG动画
tags:
  - 动效开发
  - 前端
categories: 前端动画
copyright: true
date: 2018-03-16 22:45:19
---
SVG（scalable vector graphics）指可伸缩矢量图形，是使用 XML 来描述二维图形和绘图程序的语言。用来定义用于网络的基于矢量的图形，使用xml定义图形，在图像放大或者改变尺寸的时候，图形质量不会有所损失。是万维网联盟的标准，与诸如dom和xsl之类的w3c标准的一个整体。

<!--more-->

### SVG的优势
* SVG 可被非常多的工具读取和修改（比如记事本）
* SVG 与 JPEG 和 GIF 图像比起来，尺寸更小，且可压缩性更强。
* SVG 是可伸缩的
* 可在任何的分辨率下被高质量地打印
* 图像质量不下降的情况下被放大
* 图像中的文本是可选的，同时也是可搜索的（很适合制作地图）
* 可以与java技术一起运行
* 开放的标准
* 是纯粹的xml

### 在html中使用svg的方法
可以通过三个标签`<embed>,<object>,<iframe>`

### 预定义的形状及用法
#### 矩形`<react>`
* fill:填充色
* stroke:边框
* x： 定义矩形的左侧位置
* y： 定义矩形的顶端位置
* opacity： 定义颜色透明度（合法的范围是：0 - 1）
* rx 和 ry 属性可使矩形产生圆角。

```
<rect x="20" y="20" rx="20" ry="20" width="250" height="250"
style="fill:blue;stroke:pink;stroke-width:5;
fill-opacity:0.1;stroke-opacity:0.9;opacity:0.5""/>
```

#### 圆形`<circle>`
* cx、cy： 定义圆心的 x 和 y 坐标，如果省略 cx 和 cy，圆的中心会被设置为 (0, 0)
* r： 属性定义圆的半径


```
<circle cx="100" cy="50" r="40" stroke="black"
stroke-width="2" fill="red"/>
```

#### 椭圆`<ellipse>`
椭圆类似圆，不同之处在于椭圆有不同的 x 和 y 半径，而圆的 x 和 y 半径是相同的。
* cx、cy:圆心的坐标
* rx:水平半径
* ry:垂直半径

```
<ellipse cx="300" cy="150" rx="200" ry="80"
style="fill:rgb(200,100,50);
stroke:rgb(0,0,100);stroke-width:2"/>
```
#### 线条`<line>`

* x1,y1：在x轴、y轴定义线条的开始
* x2,y2: 在x轴、y轴定义线条的结束

```
<line x1="0" y1="0" x2="300" y2="300"
style="stroke:rgb(99,99,99);stroke-width:2"/>
```

#### 多边形`<polygon>`
用来创建含有不少于三个边的图形,设置好点后，线条会自动闭合
* points 属性定义多边形每个角的 x 和 y 坐标

```
<polygon points="220,100 300,210 170,250"
style="fill:#cccccc;
stroke:#000000;stroke-width:1"/>
```

#### 折线`<polyline>`
创建仅包含直线的形状

```
<polyline points="0,0 0,20 20,20 20,40 40,40 40,60"
style="fill:white;stroke:red;stroke-width:2"/>

```

#### 路径`<path>`

* M:moveto，移动到
* L:lineto，划线到
* H:horizontal lineto，画水平线到
* V:vertical lineto，画垂线到
* C:curveto(弧线)，三次贝塞尔曲线到
* S:smooth curveto，光滑三次贝塞尔曲线到
* Q:quadratic belzier curveto，二次贝塞尔曲线到
* T:smooth quadtatic belzier curvero，光滑二次贝塞尔曲线到
* A:elliptical Arc，椭圆弧线到
* Z:closepath，关闭路径

以上代码所有命令均允许小写字母，大写表示绝对定位，小写表示相对定位。
```
<path d="M250 150 L150 350 L350 350 Z" />
```
上面的例子定义了一条路径，它开始于位置 250 150，到达位置 150 350，然后从那里开始到 350 350，最后在 250 150 关闭路径。

**由于绘制路径的复杂性，因此强烈建议您使用 SVG 编辑器来创建复杂的图形。**


### SVG滤镜（filter）
`<filter>`标签用来定义滤镜，滤镜必须含有id属性来标识滤镜。图形元素通过`filter=url(#id)`来引用滤镜。
#### 可用滤镜
* feBlend
* feColorMatrix
* feComponentTransfer
* feComposite
* feConvolveMatrix
* feDiffuseLighting
* feDisplacementMap
* feFlood
* feGaussianBlur
* feImage
* feMerge
* feMorphology
* feOffset
* feSpecularLighting
* feTile
* feTurbulence
* feDistantLight
* fePointLight
* feSpotLight


以在每个 SVG 元素上使用多个滤镜！

### SVG渐变（gradient）

**参考资料**
[SVG教程(超级详细)](https://segmentfault.com/a/1190000012071386)

![](http://static.zhyjor.com/wexin.png)
