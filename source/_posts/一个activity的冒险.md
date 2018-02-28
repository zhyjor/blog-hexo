---
title: 一个activity的冒险
tags:
  - android
  - activity
categories: android
copyright: true
date: 2018-02-28 15:40:15
---
在实例界面出现在屏幕上之前，操作系统到底干了什么，在activity1消失的时候，后台到底又干了什么。一个activity的出现于销毁到底经历了怎么样的冒险
<!--more-->
## 一个activity的冒险
在实例界面出现在屏幕上之前，操作系统到底干了什么，在activity1消失的时候，后台到底又干了什么。一个activity的出现于销毁到底经历了怎么样的冒险

### onCreate(...)
通常，activity通过覆盖onCreate(...)方法来准备以下用户界面相关的工作：

* 实例化组件，并将组件放置在屏幕上（setContentView(int)方法）
* 引用已实例化的组件
* 为组件设置监听器以处理用户交互

设备旋转时，系统会销毁当前QuizActivity实例，然后创建一个新的QuizActivity实例。再次旋转设备，查看该销毁与再创建的过程。

旋转设备会改变设备配置（device configuration）。设备配置是用来描述设备当前状态的一系列特征。这些特征包括：屏幕的方向、屏幕的密度、屏幕的尺寸、键盘类型、底座模式以及语言，等等。通常，为匹配不同的设备配置，应用会提供不同的备选资源。为适应不同分辨率的屏幕，向项目里添加多套箭头图标就是这样一个使用案例。设备的屏幕密度是个固定的设备配置，无法在运行时发生改变。然而，有些特征，如屏幕方向，可以在应用运行时进行改变。在运行时配置变更（runtime configuration change）发生时，可能会有更合适的资源来匹配新的设备配置。

### 工作原理
启动activity的请求会由Instrumentation来处理，然后他通过Binder向AMS(ActivityManagerSrevice)发请求，AMS内部维护着一个ActivityStatck并负责栈内的Activity的状态同步，AMS通过ActivityThread去同步Activity的状态从而完成生命周期方法的调用，在ActivityStack中的resumeTopActivityInnerLocked方法中


**参考资料**
[]()

![](http://oankigr4l.bkt.clouddn.com/wexin.png)