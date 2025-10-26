# 实现画中画效果

## 介绍

本示例基于媒体服务和ArkUI的基本能力，实现视频播放、手动和自动拉起画中画、画中画窗口控制视频播放和暂停等功能。

## 效果预览

![](screenshots/devices/WindowPiP.gif)

## 使用说明

1. 在主界面，可以**点击对应视频按钮**进入**视频播放页面**；
2. 视频播放页面**点击开启**，应用**拉起画中画**，点击**关闭**，**关闭画中画**；
3. 视频播放页面**点击自动开启画中画**，在返回桌面时会**自动拉起画中画**；
4. 视频播放页面会显示一些**回调信息**。

## 工程目录

```
├──entry/src/main/ets                        // 代码区
│  ├──constants
│  │  └──Constants.ets                       // 常量类
│  ├──entryability
│  │  └──EntryAbility.ets       
│  ├──pages
│  │  ├──AVPlayer.ets                        // 视频播放
│  │  ├──VideoPlay.ets                       // 视频播放页面
│  │  └──WindowPiP.ets                       // 首页
│  └──utils
│     └──Logger.ets                          // 日志工具类
└──entry/src/main/resources                  // 应用资源目录
```


## 具体实现

- 整个示例用**Navigation**构建页面，主页面放置五个可点击视频框，点击之后进入视频播放页面。
- 进入视频播放页面后，有三块区域，最上方的**XComponent**，中间的**画中画控制按钮**以及下方的**回调信息显示框**。
- 点击**开启**后，应用手动拉起画中画，视频在画中画播放，返回桌面视频依旧画中画播放；点击**关闭**后，画中画播放的视频返回**XComponent**播放，同时返回桌面不会拉起画中画。
- 点击**自动拉起画中画**后，返回桌面时应用自动拉起画中画，视频画中画播放。
- 在播放页面进行画中画播放时，XComponent框会提示**当前视频正在以画中画播放**。
- 回调信息显示框会显示**当前状态**，**错误原因**以及**按钮事件和状态**，参考：[VideoPlay.ets](entry/src/main/ets/pages/VideoPlay.ets)。


## 相关权限

不涉及

## 依赖

不涉及

## 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。