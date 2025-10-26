# 稳定性运维&前台任务低功耗

### 介绍

APM（Application Performance Management）是一种用于监控和管理应用程序性能的解决方案。它通过收集、分析和报告应用程序的性能数据，帮助开发和运维团队快速定位并解决应用程序问题，提高应用程序的可靠性和性能。HarmonyOS 提供了完善的 HiAppEvent 机制，帮助开发者上报稳定性、性能等应用事件，开发者可以利用它构建自身的 APM 系统。
低功耗是指设备在执行各种任务时，通过应用一系列技术和策略来减少能耗，从而延长电池寿命和设备使用时间。手机等移动设备因其便携、移动的特性，续航时间的长短直接影响用户对品牌的体验和满意度。

### 使用说明
不涉及。

### 工程结构

```
├──entry/src/main/ets/
│  ├──entryability
│  │  └──EntryAbility.ets                    // 程序入口类
│  └──entrybackupability
│  │  └──EntryBackupAbility.ets              // 备份类
│  └──pages
│     └──Index.ets                           // 入口页面
│     └──MonitorCrash.ets                    // 崩溃监测实践文章配套代码
│     └──MusicPlayRule.ets                   // 音乐播放场景低功耗规则文章配套代码
│     └──NavigationAndPositioningRule.ets    // 导航定位场景低功耗规则文章配套代码
│     └──NetworkResourcePage.ets             // 网络资源低功耗建议文章配套代码
│     └──StaticScenesRule.ets                // 静态场景低功耗规则文章配套代码
│     └──VideoSceneLayers.ets                // 视频场景图层低功耗建议文章配套代码
│     └──VideoScenesROMRule.ets              // 视频场景ROM低功耗建议文章配套代码
├──entry/src/main/cpp/
│        ├──VideoSceneEncoding.cpp           // 视频场景编解码低功耗规则文章配套代码
│        ├──napi_init.cpp                    // 初始化文件 
│        ├──EGLCore.cpp                      // EGL文件 
│        ├──EGLCore.h                        // EGL头文件 
│        ├──CMakeLists.txt 
│        └──types
│             └──index.d.ts                  // c++导出文件
└──entry/src/main/resource                   // 应用静态资源目录
```

### 相关权限

- 允许应用使用 Internet 网络权限：ohos.permission.INTERNET。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS 系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio 版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK 版本：HarmonyOS 5.0.5 Release及以上。

### 下载

如需单独下载本工程，执行如下命令：
```
git init
git config core.sparsecheckout true
echo RationalUseOfFrontEndResources/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```
