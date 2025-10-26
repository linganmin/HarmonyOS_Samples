# 基于UIObserver能力的应用埋点

## 介绍

本示例基于UIObserver能力实现了常见的埋点行为：点击埋点、曝光埋点、页面埋点。开发者可以结合业务场景进行应用埋点，针对用户行为收集、处理和发送一些信息，以跟踪应用的使用情况，包括访问数、访客数、停留时长、页面浏览数和跳出率等。

## 效果预览

![](screenshots/device/ApplicationTrack_CN.gif)

## 工程目录

```
├──entry/src/main/ets                        // 代码区
│  ├──entryability
│  │  └──EntryAbility.ets                    // Ability的生命周期回调内容
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets              // EntryBackupAbility的生命周期回调内容
│  ├──pages                                  
│  │  ├──ClickPage.ets                       // 点击埋点
│  │  ├──HomePage.ets                        // 主页面
│  │  ├──NavigationPage.ets                  // 使用Navigation路由时的页面切换埋点页面  
│  │  ├──PageOne.ets                         // 第一个Navigation路由埋点页面 
│  │  ├──PageTwo.ets                         // 第二个Navigation路由埋点页面  
│  │  ├──RouterPageA.ets                     // 第一个Router路由埋点页面 
│  │  ├──RouterPageB.ets                     // 第二个Router路由埋点页面            
│  │  ├──WaterFlowCard.ets                   // 瀑布流卡片       
│  │  └──WaterFlowPage.ets                   // 组件的曝光展示埋点页面        
│  └──viewModel                              // 埋点逻辑
│     ├──CallBackManager.ets                  
│     ├──DataResource.ets                    
│     ├──TrackNode.ets              
│     └──WaterFlowDataSource.ets              
└──entry/src/main/resources                  // 应用资源目录
```

## 使用说明

1. 请参考[应用埋点](https://developer.huawei.com/consumer/cn/doc/best-practices/bpta-application-track-practice)


## 相关权限

- 不涉及

## 依赖

- 不涉及

## 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。