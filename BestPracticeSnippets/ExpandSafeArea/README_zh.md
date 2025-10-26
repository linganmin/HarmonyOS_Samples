# 基于expandSafeArea实现自动避让挖孔区

### 介绍

本示例是[《窗口沉浸式》](https://developer.huawei.com/consumer/cn/doc/best-practices/bpta-multi-device-window-immersive)的配套示例代码，通过父子组件使用expandSafeArea属性，来动态实现避让挖孔区。

### 使用说明

1. 启动应用，首页为沉浸式效果，背景色可透过系统栏区域。
2. 设备旋转后，子组件部分会自动避让系统挖孔区。

### 工程目录
```
├──entry/src/main/ets                                   // 代码区
│  ├──entryability
│  │  └──EntryAbility.ets                               // 程序入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  └──pages                              
│     └──Index.ets                                      // 首页
└──entry/src/main/resources                             // 应用资源目录
```
### 具体实现

* 该示例使用为父组件添加expandSafeArea属性，使父组件拓展系统栏区域，实现父组件背景色可透过系统栏区域。
* 为子组件添加expandSafeArea属性，参数为[]，表示子组件将不拓展任何系统栏区域，从而达到无论屏幕如何旋转，子组件都会自动避让挖孔区。

### 相关权限

不涉及。

### 依赖

不涉及。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。
2. HarmonyOS系统：HarmonyOS 5.1.1 Release及以上。
3. DevEco Studio版本：DevEco Studio 5.1.1 Release及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.1.1 Release SDK及以上。

### 下载

如需单独下载本工程，执行如下命令：
```
git init
git config core.sparsecheckout true
echo ExpandSafeArea/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```