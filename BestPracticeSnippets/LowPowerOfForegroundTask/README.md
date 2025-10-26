# 省电和深色模式下低功耗设计

## 介绍

本示例展示了省电和深色模式下低功耗相关代码。

## 工程目录
```
├──entry/src/main/ets                                   // 代码区
│  ├──entryability
│  │  └──EntryAbility.ets                               // 程序入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  ├──model
│  │  └──LearningResource.ets
│  ├──pages             
│  │  ├──ActionButtonView.ets     
│  │  ├──ActionCardButtonView.ets     
│  │  ├──ActionCardView.ets     
│  │  ├──ActionCardViewNew.ets      
│  │  └──Index.ets                                      // 首页      
│  └──utils
│     └──LottieUtil.ets                                 // Lottie工具类
└──entry/src/main/resources                             // 应用资源目录
```


## 相关权限
无

## 约束与限制
* 本示例仅支持标准系统上运行，支持设备：华为手机。

* HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

* DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

* HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。

## 下载

如需单独下载本工程，执行如下命令：
```
git init
git config core.sparsecheckout true
echo LowPowerOfForegroundTask/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```