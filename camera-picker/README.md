# 基于系统相机实现拍照功能

### 介绍

本示例展示了系统相机的调用，通过cameraPicker拉起系统相机并进行拍照，获得图片。参考本示例可以学习系统相机的使用，帮助应用开发基本的照相功能。

### 效果预览
![image](screenshots/device/mainpage.png)

### 使用说明

1、点击拍照按钮，拉起系统相机，进行拍照。

2、拍照后点击确定返回应用，应用展示拍摄的照片。

### 工程目录
```
├──entry/src/main/ets
│  ├──common
│  │  └──constants
│  │     └──CommonConstants.ets             // 常量类
│  ├──entryability
│  │  └──EntryAbility.ets                   // 程序入口类
│  └──pages
│     └──MainPage.ets                       // 主页面
└──entry/src/main/resources                 // 应用静态资源目录
```
### 具体实现

* 使用cameraPicker拉起系统相机。

### 相关权限

不涉及。

### 依赖

不涉及。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。