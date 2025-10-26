# 实现组件的封装

### 介绍

本示例展示组件封装中的常见问题代码。

### 使用说明

进入首面，点击按钮，分别进入示例页面。

### 工程目录

```
├──entry/src/main/ets
│  ├──entryability
│  │  └──EntryAbility.ets                   // Ability入口
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets             // Backup恢复类
│  └──pages
│     ├──Index.ets                          // 首页
│     ├──BuilderParamPage.ets               // BuilderParam传递布局示例页面
│     ├──ControllerCallPage.ets             // controller调用父组件方法示例页面
│     ├──EmitterCallPage.ets                // emitter调用父组件方法示例页面
│     ├──ParentCallPage.ets                 // 父组件调用子组件方法示例页面
│     └──WatchCallPage.ets                  // watch调用父组件方法示例页面
└──entry/src/main/resources                 // 应用资源目录
```

### 具体实现

1. 分别实现页面，包括父组件调用子组件方法，子组件调用父组件方法，BuilderParam布局传参等。

### 相关权限

不涉及。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 5.1.0 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.1.0 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.1.0 Release SDK及以上。

### 下载

如需单独下载本工程，执行如下命令：
```
git init
git config core.sparsecheckout true
echo ComponentEncapsulation/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```