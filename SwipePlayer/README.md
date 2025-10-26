# 实现短视频流畅点播
## 简介
本场景主要聚焦短视频流畅点播切换场景，提供了短视频上下滑动、快速起播、动态添加数据源、自定义跟随视频滑动的组件、自定义滑动组件切换、全屏和弹框等能力，同时通过自定义能力的开放，满足应用不同短视频滑动场景的业务诉求，开发者可以基于SwipePlayer
库快速实现短视频流畅滑动的场景开发体验，可以更加聚焦实际场景业务的开发。

## 预览图效果

| 竖屏页                                               | 评论页                                               | 横屏页                                            |
|---------------------------------------------------|---------------------------------------------------|------------------------------------------------|
| <img src="./screenshots/display.gif" width="320"> | <img src="./screenshots/comment.gif" width="320"> | <img src="./screenshots/full.gif" width="320"> | 


## 工程主要模块结构
```typescript
├──entry/src/main/ets/
│  │──constants                        // 常量
│  │  ├──AdvertConstants.ets           // 广告页资源常量
│  │  ├──CommonConstant.ets            // 资源常量
│  │  └──TabConstants.ets              // 标签栏资源常量
│  ├──entryability
│  │  └──EntryAbility.ets              // Ability的生命周期回调内容
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets        // EntryBackupAbility的生命周期回调内容
│  ├──model
│  │  ├──CommonModel.ets               // 页面公共方法
│  │  └──CommonUtils.ets               // 组件公共方法
│  ├──pages
│  │  └──Index.ets                     // 主页面
│  └──screen                           // 页面
│     ├──Advert.ets                    // 广告页
│     ├──CommentsDetails.ets           // 评论区列表页
│     ├──Comments.ets                  // 评论页
│     ├──FastSpeed.ets                 // 倍速弹窗页
│     ├──FullScreenComponent.ets       // 横屏页
│     ├──TabButton.ets                 // 按钮标签页
│     ├──TopTabButton.ets              // 上方标签页
│     └──ViewScreenComponent.ets       // 竖屏页
└──entry/src/main/resources            // 应用静态资源目录
```

## 相关权限
网络权限：ohos.permission.INTERNET，用于加载网络视频场景。

## 依赖
本方案使用了三方库swipePlayer，如出现缺少依赖的情况可通过命令下载 ohpm i @hadss/swipeplayer

## 约束与限制
1.本示例仅支持标准系统上运行，支持设备：华为手机。

2.HarmonyOS系统：HarmonyOS NEXT Release及以上。

3.DevEco Studio版本：DevEco Studio NEXT Release及以上。

4.HarmonyOS SDK版本：HarmonyOS NEXT Release SDK及以上。