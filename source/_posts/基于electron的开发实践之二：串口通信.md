---
title: 基于electron的开发实践之二：串口通信
tags:
  - dev
categories: dev
top: false
copyright: true
date: 2018-09-05 14:18:08
---
electron提供了node的环境，可以通过安装serialport包，来进行串口通信。
<!--more-->
## node与串口通信
### 出现的错误
```
MSBUILD : error MSB3428: 未能加载 Visual C++ 组件“VCBuild.exe”。
```

```
E:\myProject\node-prj\node-serialport\node_modules\@serialport\bindings\build\bindings.vcxproj(20,3): error MSB4019: 未找到导入的项目“E:\Microsoft.Cpp.Default.props”。请确认 <Import> 声明中的路径正确，且磁盘上存在该文件。

```

```
Traceback (most recent call last):
  File "E:\Front\node\npmpg\node_modules\npm\node_modules\node-gyp\gyp\gyp_main.py", line 13, in <module>
    import gyp
  File "E:\Front\node\npmpg\node_modules\npm\node_modules\node-gyp\gyp\pylib\gyp\__init__.py", line 8, in <module>
    import gyp.input
  File "E:\Front\node\npmpg\node_modules\npm\node_modules\node-gyp\gyp\pylib\gyp\input.py", line 15, in <module>
    import multiprocessing
  File "E:\python\python27\lib\multiprocessing\__init__.py", line 84, in <module>
    import _multiprocessing
ImportError: DLL load failed: %1 不是有效的 Win32 应用程序。

```


**参考资料**
[node-serialport/node-serialport](https://github.com/node-serialport/node-serialport)
[终于在electron中成功编译node-serialport了](https://www.jianshu.com/p/696fbdeb5b8a)
[Nodejs Serialport文档翻译](https://www.jianshu.com/p/65e2afa199f9)
[electron串口工具桌面应用开发踩坑记(node-serialport)](https://cnodejs.org/topic/5a430931749e665a378f9192)
[如何在web页面上获取客户端的串口数据？](https://www.zhihu.com/question/53168610/answer/133789563)

[MSBUILD : error MSB3428: 未能加载 Visual C++ 组件“VCBuild.exe”。](https://www.jianshu.com/p/03b93d32f015)


![](http://oankigr4l.bkt.clouddn.com/wexin.png)