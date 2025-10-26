# **点击完成时延分析**

## 介绍

用于模拟点击完成时延分析，通过修改点击后耗时函数，优化点击完成时延。

## 工程目录

```
├──entry/src/main/ets                                   // 代码区
│  ├──conponents
│  │  ├──AudioPlayerService.ets                         // AudioPlayerService类
│  │  ├──AudioPlayerStatus.ets                          // AudioStatusUtils类
│  │  └──ContinueModel.ets                              // ContinueModel类
│  ├──entryability
│  │  └──EntryAbility.ets                               // 程序入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  ├──pages                              
│  │  ├──MainPage.ets                                   // 首页
│  │  ├──Page1.ets                                      // 动画时延耗时页面（100ms）
│  │  └──Page2.ets                                      // 动画时延耗时页面（1000ms）
│  └──service  
│     └──ServiceTask.ets                                // 耗时函数
└──entry/src/main/resources                             // 应用资源目录
```

## 使用说明

animationDuration属性有300ms的动画时长，当该属性值设置过长时会导致完成时延变大。
本示例用于对比animationDuration属性分别设置为100ms与1000ms时，对完成时延的影响。

## 相关权限

无

## 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。

## 下载

如需单独下载本工程，执行如下命令：
```
git init
git config core.sparsecheckout true
echo PerformanceAnalysis/BptaDelayAnalysis/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```