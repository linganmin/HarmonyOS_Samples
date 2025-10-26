# 实现智能手表上的地图应用

## 简介

本示例使用Map Kit的基本能力，实现了智能手表上查看地图并实现定位的功能，指导开发者在穿戴设备上适配地图。

## 效果预览

<img src="./screenshots/device/home.png" width="320">

## 使用说明

1. 进入主页，授予应用获取位置权限。
2. 点击定位按钮，地图视图移动至当前位置。

## 工程目录
```
├──entry/src/main/ets                     // 代码区
│  ├──common  
│  │  └──util                 
│  │     └──PermissionUtil.ets            // 权限工具类  
│  ├──entryability
│  │  └──EntryAbility.ets                 // 程序入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  └──pages
│     └──Index.ets                        // 首页
└──entry/src/main/resources               // 应用静态资源目录
```

## 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为智能穿戴。
2. HarmonyOS系统：HarmonyOS 5.1.0 Release及以上。
3. DevEco Studio版本：DevEco Studio 5.1.0 Release及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.1.0 Release SDK及以上。