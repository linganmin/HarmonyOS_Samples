# 帧率问题分析同源示例代码

### 介绍

本示例代码为最佳实践《帧率问题分析》配套示例代码。

### 使用说明

不涉及

### 工程目录

``` 
├──entry/src/main/ets     
│  ├──components
│  │  └──DiscoverView.ets               // 程序入口类                     
│  ├──entryability
│  │  └──EntryAbility.ets               // 程序入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets         // 数据备份恢复类
│  └──pages        
│     ├──Index.ets                      // 自定义动画丢帧问题示例代码：优化前
│     ├──page2.ets                      // 自定义动画丢帧问题示例代码：优化后
│     ├──page3.ets                      // 布局嵌套过深示例代码
│     └──page4.ets                      // 布局嵌套过深示例代码：子组件
└──entry/src/main/resources             // 应用资源目录
```

### 相关权限

不涉及

### 约束与限制

* 本示例仅支持标准系统上运行，支持设备：华为手机。
* HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
* DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
* HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。

### 下载

如需单独下载本工程，执行如下命令：
```
git init
git config core.sparsecheckout true
echo PerformanceAnalysis/BptaFramePractice/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```