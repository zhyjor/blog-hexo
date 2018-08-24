---
title: android开发之权限获取
tags:
  - android
  - 权限获取
  - 基础库

copyright: true
date: 2017-10-20 15:11:19
categories: android
---
Android6.0(M)的权限管理策略舍弃了之前的`install time permissions model`,取而代之的是`runtime permissions model`，也就是动态权限管理。这种改变让用户更加容易的控制自己的隐私，好处不言而喻。但是对于程序员来说，还是有点小负担的，增加了一些学习和开发的成本。
<!--more-->
### 权限分类
Android 将系统权限分成了四个保护等级：

* normal ：普通级别
* dangerous ：危险级别
* signature：签名级别
* signatureOrSystem：系统签名级别

而对于开发而言，关心的只有 普通权限 和 危险权限 两类
其他两级权限，为高级权限，应用拥有platform级别的认证才能申请。

当应用试图在没有权限的情况下做受限操作，应用将被系统杀掉以警示。
所以权限的控制很重要，不小心就会crash.

#### 普通权限 (normal permission)
普通权限 会在App安装期间被默认赋予。这类权限不需要开发人员进行额外操作就可以自己默认可以获取，这类权限包括：
> ACCESS_LOCATION_EXTRA_COMMANDS
ACCESS_NETWORK_STATE
ACCESS_NOTIFICATION_POLICY
ACCESS_WIFI_STATE
BLUETOOTH
BLUETOOTH_ADMIN
BROADCAST_STICKY
CHANGE_NETWORK_STATE
CHANGE_WIFI_MULTICAST_STATE
CHANGE_WIFI_STATE
DISABLE_KEYGUARD
EXPAND_STATUS_BAR
FLASHLIGHT
GET_PACKAGE_SIZE
INTERNET
KILL_BACKGROUND_PROCESSES
MODIFY_AUDIO_SETTINGS
NFC
READ_SYNC_SETTINGS
READ_SYNC_STATS
RECEIVE_BOOT_COMPLETED
REORDER_TASKS
REQUEST_INSTALL_PACKAGES
SET_TIME_ZONE
SET_WALLPAPER
SET_WALLPAPER_HINTS
TRANSMIT_IR
USE_FINGERPRINT
VIBRATE
WAKE_LOCK
WRITE_SYNC_SETTINGS
SET_ALARM
INSTALL_SHORTCUT

#### 危险权限
这些权限是在开发6.0程序时，必须要注意的。
这些权限处理不好，程序可能会直接被系统干掉。
权限如下：

| 权限组 |权限  |
| -----|:----:|
| CALENDAR| READ_CALENDAR，WRITE_CALENDAR   |
| CAMERA    | CAMERA    |
| CONTACTS    | READ_CONTACTS，WRITE_CONTACTS，GET_ACCOUNTS    |
|LOCATION|ACCESS_FINE_LOCATION，ACCESS_COARSE_LOCATION|
|MICROPHONE|RECORD_AUDIO|
|PHONE|READ_PHONE_STATE，CALL_PHONE，READ_CALL_LOG，WRITE_CALL_LOG，ADD_VOICEMAIL，USE_SIP，PROCESS_OUTGOING_CALLS
|
|SENSORS|BODY_SENSORS|
|SMS|SEND_SMS，RECEIVE_SMS，READ_SMS，RECEIVE_WAP_PUSH，RECEIVE_MMS
|
|STORAGE|READ_EXTERNAL_STORAGE，WRITE_EXTERNAL_STORAGE|
|||