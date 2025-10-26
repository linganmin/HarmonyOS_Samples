# 一多窗口适配开发实践

### 简介
与最佳实践文章《一多窗口适配开发实践》配套的示例代码。

### 预览效果
不涉及

### 使用说明
工程本身不具备实际功能，开发者请直接阅读文档结合源码来理解多设备功能开发。

### 工程目录

```
├──entry/src/main/ets
|  ├──components                        
|  │  └──WindowUtil.ets                     // 窗口工具类
|  ├──entryability                        
|  │  ├──EntryAbility.ets                   // 程序入口类
|  │  ├──EntryAbility1.ets                  // 程序入口类同源代码块
|  │  ├──EntryAbility2.ets                  // 程序入口类同源代码块
|  │  └──EntryAbility3.ets                  // 程序入口类同源代码块
|  ├──entrybackupability                  
|  │  └──EntryBackupAbility.ets             // 数据备份恢复类
|  └──pages
|     ├──FreeMultiWindowMode.ets            // 自由多窗口模式
|     ├──FreeMultiWindowObserver.ets        // 自由多窗口Observer
|     └──Index.ets                          // 首页
└──entry/src/main/resources                 // 应用资源目录
```

### 具体实现
不涉及

### 相关权限
无

### 约束与限制
* 本示例仅支持标准系统上运行，支持设备：华为手机。

* HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

* DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

* HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。

### Download

To download this project separately, execute the following command:
```
git init
git config core.sparsecheckout true
echo bptaMultiWindow/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```
