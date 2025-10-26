# UI组件性能优化同源示例代码

### 介绍

本示例代码为最佳实践《UI组件性能优化》配套示例代码。

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
│     ├──segment.ets                    // 避免在自定义组件的生命周期内执行高耗时操作：反例1
│     ├──segment2.ets                   // 避免在自定义组件的生命周期内执行高耗时操作：正例1
│     ├──segment3.ets                   // 避免在自定义组件的生命周期内执行高耗时操作：反例2
│     ├──segment4.ets                   // 避免在自定义组件的生命周期内执行高耗时操作：正例2
│     ├──segment5.ets                   // 按需注册组件属性同源代码：反例
│     ├──segment6.ets                   // 按需注册组件属性同源代码：正例
│     ├──segment7.ets                   // 优先使用@Builder方法代替自定义组件：反例
│     ├──segment8.ets                   // 优先使用@Builder方法代替自定义组件：正例
│     └──segment9.ets                   // 按需注册组件属性同源代码
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
echo UI_Component_Performance_Optimization/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```