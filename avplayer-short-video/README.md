# 基于AVPlayer实现短视频播放

## 项目简介

本示例基于AVPlayer系统播放器实现，适用于短视频播放类应用的开发，指导开发者实现短视频流畅切换，提炼一套可复制的方案，帮助开发者交付极速、流畅的短视频播放体验。

## 效果预览
<img src="./screenshots/devices/Index.webp" width="320">

## 功能特性
1. 本示例包含基本播控、静音播放、循环播放、倍数播放和字幕挂载功能，具体效果可参考[基于AVPlayer基本播放](https://gitee.com/harmonyos_samples/avplayer-basic-control/blob/master/README.md)
2. 本示例包含焦点管理、横竖屏切换与旋转感知和前后台感知，具体效果可参考[基于AVPlayer长视频播放](https://gitee.com/harmonyos_samples/avplayer-long-video/blob/master/README.md)

## 使用说明：
1. 打开应用，可以上下滑动**流畅切换视频**，且支持断点持播功能，切回原视频会从之前的位置继续播放。

## 工程目录
```
├──entry/src/main/
├──ets
│  ├──common
│  │  ├──contanstants
│  │  │  └──CommonConstants.ets        // 公共常量
│  │  └──utils
│  │     ├──Logger.ets                 // 日志工具
│  │     ├──WindowUtil.ets             // 窗口工具
│  │     └──TimeUtils.ets              // 时间工具
│  ├──component
│  │  ├──LanguageDialog.ets            // 语言切换弹窗组件
│  │  ├──VideoPlayer.ets               // 视频播放组件
│  │  ├──SpeedDialog.ets               // 播放倍数弹窗组件
│  │  └──VideoToolBar.ets              // 视频工具栏
│  ├──controller
│  │  └──AvPlayerController.ets        // AVPlayer控制类
│  ├──entryability
│  │  └──EntryAbility.ets              // 入口函数
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  ├──model
│  │  ├──AVDataSource.ets              // 数据操作类
│  │  ├──DataModel.ets                 // 数据源
│  │  └──VideoData.ets                 // 数据类型
│  └──pages
│     ├──AVPlayerView.ets              // 视频播放页
│     └──Index.ets                     // 首页 
└──resources                           // 应用静态资源目录
```

## 具体实现

1. 视频资源加载、暂停、播放、视频跳转的功能接口都封装在AvPlayerController.ets，源码查看：[AvPlayerController.ets](./entry/src/main/ets/controller/AvPlayerController.ets);
2. 结合Swiper进行短视频滑动切换，使用LazyForEach进行数据懒加载；冷启动到prepared阶段，轮播过程中异步创建播放器为下一个视频做准备;

## 相关权限

不涉及

## 约束与限制

1.本示例仅支持标准系统上运行，支持设备：华为手机。

2.HarmonyOS系统：HarmonyOS 5.1.0 Release及以上。

3.DevEco Studio版本：DevEco Studio 5.1.0 Release及以上。

4.HarmonyOS SDK版本：HarmonyOS 5.1.0 Release SDK及以上。

