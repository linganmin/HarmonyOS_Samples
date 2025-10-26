# 不同场景下组件嵌套的性能优化策略

### 介绍

本示例是[《组件嵌套优化》](https://developer.huawei.com/consumer/cn/doc/best-practices/bpta-component-nesting-optimization)的配套示例代码，通过正反例代码展示页面布局时，如何减少性能开销。


### 工程目录
```
├──entry/src/main/ets                                   // 代码区
│  ├──entryability
│  │  └──EntryAbility.ets                               // 程序入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  ├──pages
│  │  └──Index.ets
│  └──segment      
│     ├──segment1.ets                                   // 场景1
│     ├──segment2.ets                                   // 场景2
│     ├──segment3.ets                                   // 场景3
│     ├──segment4.ets                                   // 场景4
│     ├──segment5.ets                                   // 场景5
│     └──segment6.ets                                   // 场景6
└──entry/src/main/resources                             // 应用资源目录
```

### 相关权限

不涉及。

### 依赖

不涉及。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。
2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。

### 下载

如需单独下载本工程，执行如下命令：
```
git init
git config core.sparsecheckout true
echo ArkUI/Component_Nesting_Optimization/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```