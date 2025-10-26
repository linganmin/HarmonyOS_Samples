# 实现嵌入式拉起元服务功能

### 介绍

本示例使用了FullScreenLaunchComponent组件，当被拉起方元服务授权使用方元服务嵌入式运行时，使用方可以通过FullScreenLaunchComponent组件将被拉起方元服务以全屏方式展示出来。通过全屏显示，可以让用户更加沉浸在元服务的界面中，享受更好的视觉效果和交互体验。

### 效果预览

![phone.gif](screenshots/device/phone.gif)

### 工程目录

```
├──entry/src/main/ets/                         
│  ├──entryability
│  │  └──EntryAbility.ets                           // 程序入口类
│  └──pages
│     └──mainPage.ets                               // 主页入口                                                   
└──entry/src/main/resource                          // 应用静态资源目录
```

### 具体实现

使用 FullScreenLaunchComponent 全屏启动元服务组件实现嵌入式拉起元服务。

### 相关权限

不涉及。

### 使用说明

1. 分别手机、折叠屏安装并打开元服务，同时在开发者选项中开启元服务豁免管控。
2. 点击界面上图标，已安装对应元服务的场景下可实现全屏嵌入式运行元服务。
3. 点击界面上图标，未安装对应元服务的场景下跳出式拉起元服务。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。
2. HarmonyOS 系统：HarmonyOS 5.0.0 Release及以上。
3. DevEco Studio 版本：DevEco Studio 5.0.0 Release及以上。
4. HarmonyOS SDK 版本：HarmonyOS 5.0.0 Release SDK及以上。