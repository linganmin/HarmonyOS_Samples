# 基于NFC的应用跳转

## 介绍

近场通信（Near Field Communication，NFC）是一种短距高频的无线电技术。电子设备可以通过NFC通信技术和NFC标签通信，从标签中读取数据。

其分为两种场景：

* NFC标签前台读取：打开特定应用程序，设备触碰NFC标签后，会把读取到的卡数据分发给前台应用。
* NFC标签后台读取：不打开特定应用程序，设备触碰NFC标签后，根据NFC标签的技术类型，分发给能够处理的应用。如果匹配到多个，则弹出应用选择器给用户手动选择。如果只匹配到一个，则直接打开匹配到的应用程序。

（注：无论是前台读取还是后台读取，电子设备能够发现NFC标签的前提条件是设备必须是亮屏和解锁状态）。

## 预览效果

| 前台读取                                  | 后台读取                                   |
|---------------------------------------|----------------------------------------|
| ![](screenshots/divice/forground.gif) | ![](screenshots/divice/background.gif) |

## 工程目录

```
├──entry/src/main/ets                                   // 代码区
│  ├──entryability
│  │  └──EntryAbility.ets                               // 程序入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  ├──pages                              
│  │  └──Index.ets                                      // 首页
│  └──view  
│     └──ReadNFCTag.ets                                 // 展示NFC信息页面
└──entry/src/main/resources                             // 应用资源目录
```

## 使用说明

示例代码包含两个场景：

* 前台读卡：打开应用，NFC标签触碰设备NFC可识别区域，读取NFC标签数据，跳转子页面并在页面中展示NFC标签支持的技术类型和标签信息。


* 后台读卡：不打开应用，NFC标签触碰设备NFC可识别区域，根据NFC标签的技术类型匹配应用，若匹配多个则弹出选择框给用户手动选择打开应用；若匹配一个应用，则直接打开匹配到的应用程序，展示NFC标签支持的技术类型和标签信息。

## 相关权限

* 允许应用读取Tag卡片：ohos.permission.NFC_TAG。

## 约束与限制

* 本示例仅支持标准系统上运行，支持设备：华为手机。
* HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
* DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
* HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。
