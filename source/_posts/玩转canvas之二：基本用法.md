---
title: 玩转canvas之二：基本用法
tags:
  - 玩转canvas
  - canvas
  - 数据可视化
categories: 数据可视化
top: false
copyright: true
date: 2018-12-01 15:51:27
---
如何使用Canvas，比如怎么绘制图形，怎么做Canvas动画等。
<!--more-->

## Canvas坐标系统
在Canvas中有2D和3D之分，可以通过getContext('2d')让Canvas得到一个2D环境。言外之意，它还有一个3D环境。只不过我们现在只聊Canvas中的2D。这样一来，在Canvas中坐标系统也是有分的。

在Canvas中2D环境中其坐标系统和Web的坐标系统是一致的。坐标原点(0,0)在`<canvas>`画布的的左上角。同样的分为x和y两个轴。x轴向右为正值，y轴向下为正值。同样在canvas中，是没有办法直接看到。但同样，在canvas中使用负坐标不会导致canvas不能使用，只不过会移到canvas画布的外面。

## api
```js
// text	规定在画布上输出的文本。
// x	开始绘制文本的 x 坐标位置（相对于画布）。
// y	开始绘制文本的 y 坐标位置（相对于画布）。
// maxWidth	可选。允许的最大文本宽度，以像素计。
context.fillText(text,x,y,maxWidth);

// 清空给定矩形内的指定像素
x	要清除的矩形左上角的 x 坐标
y	要清除的矩形左上角的 y 坐标
width	要清除的矩形的宽度，以像素计
height	要清除的矩形的高度，以像素计
context.clearRect(x,y,width,height);

// 开始一条路径，或重置当前的路径。
context.beginPath()

// 开始一条路径
ctx.beginPath();
// 移动到位置 0,0。
ctx.moveTo(0,0);
// 创建到达位置 300,150 的一条线
ctx.lineTo(300,150);
// strokeStyle 属性设置或返回用于笔触的颜色、渐变或模式。
context.strokeStyle=color|gradient|pattern;
// stroke() 方法会实际地绘制出通过 moveTo() 和 lineTo() 方法定义的路径。默认颜色是黑色。
ctx.stroke();

// 创建弧/曲线（用于创建圆或部分圆）
x	圆的中心的 x 坐标。
y	圆的中心的 y 坐标。
r	圆的半径。
sAngle	起始角，以弧度计。（弧的圆形的三点钟位置是 0 度）。
eAngle	结束角，以弧度计。
counterclockwise	可选。规定应该逆时针还是顺时针绘图。False = 顺时针，true = 逆时针。
context.arc(x,y,r,sAngle,eAngle,counterclockwise);


// save() 方法把当前状态的一份拷贝压入到一个保存图像状态的栈中。这就允许您临时地改变图像状态，然后，通过调用 restore() 来恢复以前的值。
save可以理解为锁定了之前的画布
save()与restore()

// 移动画布原点到x,y
context.translate(x,y);

// angle旋转角度，以弧度计（n*Math.PI） 
context.rotate(angle) 

// 在画布上定位图像
context.drawImage(img,x,y);
// 在画布上定位图像，并规定图像的宽度和高度
context.drawImage(img,x,y,width,height);
// 剪切图像，并在画布上定位被剪切的部分
img	规定要使用的图像、画布或视频。
sx	可选。开始剪切的 x 坐标位置。
sy	可选。开始剪切的 y 坐标位置。
swidth	可选。被剪切图像的宽度。
sheight	可选。被剪切图像的高度。
x	在画布上放置图像的 x 坐标位置。
y	在画布上放置图像的 y 坐标位置。
width	可选。要使用的图像的宽度。（伸展或缩小图像）
height	可选。要使用的图像的高度。（伸展或缩小图像）
context.drawImage(img,sx,sy,swidth,sheight,x,y,width,height);

// putImageData() 方法将图像数据（从指定的 ImageData 对象）放回画布上
imgData	规定要放回画布的 ImageData 对象。
x	ImageData 对象左上角的 x 坐标，以像素计。
y	ImageData 对象左上角的 y 坐标，以像素计。
dirtyX	可选。水平值（x），以像素计，在画布上放置图像的位置。
dirtyY	可选。水平值（y），以像素计，在画布上放置图像的位置。
dirtyWidth	可选。在画布上绘制图像所使用的宽度。
dirtyHeight	可选。在画布上绘制图像所使用的高度。
context.putImageData(imgData,x,y,dirtyX,dirtyY,dirtyWidth,dirtyHeight);
```


**参考资料**
[canvas的beginPath和closePath分析总结，包括多段弧的情况](https://www.cnblogs.com/xuehaoyue/p/6549682.html)

![](http://oankigr4l.bkt.clouddn.com/wexin.png)