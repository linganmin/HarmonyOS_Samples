# 实现自定义标题栏的应用窗口高性能拖动

### 简介

在PC/2in1和平板设备上使用自由多窗模式时，对于没有标题栏或自定义标题栏的窗口，开发者可调用系统能力来实现该窗口的高性能拖动。本示例将展示没有标题栏或自定义标题栏窗口的拖动场景高性能开发方案。

### 效果预览

![](screenshots/windowDrag.gif)

### 使用说明
- 点击应用中间的蓝色区域，可拖动应用。

### 工程目录

```
├──entry/src/main/ets
|  ├──entryability                        
|  │  └──EntryAbility.ets                   // 程序入口类
|  ├──entrybackupability                  
|  │  └──EntryBackupAbility.ets             // 数据备份恢复类
|  └──pages                               
|     └──Index.ets                          // 首页
└──entry/src/main/resources                 // 应用资源目录
```

### 具体实现
1. 手指触摸动作触发onTouch()该方法。
2. 使用startMoving()方法,指定鼠标在窗口内的位置并移动窗口。

### 相关权限

不涉及

### 模块依赖

不涉及

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为PC/2in1设备、华为平板。
2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。

### 下载

如需单独下载本工程，执行如下命令：
```
git init
git config core.sparsecheckout true
echo CustomTitleBarWindowDrag/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```