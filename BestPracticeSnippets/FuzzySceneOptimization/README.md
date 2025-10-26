# 图像模糊动效优化

### 简介

本示例展示了在“转场结合图片模糊”场景中静态模糊与动态模糊的应用。

### 效果预览

|              动态模糊                 |               静态模糊              |
|----------------------------------------|----------------------------------------|
| <img src="screenshots/devices/motion_blur.gif" width="180"> | <img src="screenshots/devices/static_blur.gif" width="180"> |


### 使用说明

1、父页面点击"motion blur"按钮，跳转子页面MotionBlur。

2、在子页面MotionBlur中，点击"motion blur"按钮拉起图片动态模糊处理后的全屏模态页面。

3、父页面点击"static blur"按钮，跳转子页面StaticBlur。

4、在子页面StaticBlur中，点击"static blur"按钮拉起图片静态模糊处理后的全屏模态页面。

### 工程目录
```
├──entry/src/main/ets
│  ├──entryability
│  │  └──EntryAbility.ets                   // Ability的生命周期回调内容
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets             // 程序入口类
│  └──pages
│     ├──MainPage.ets                       // 视图层-父页面
│     ├──MotionBlur.ets                     // 视图层-动态模糊页面
│     └──StaticBlur.ets                     // 视图层-静态模糊页面
└──entry/src/main/resources                 // 应用静态资源目录
```

### 具体实现

1. 动态模糊通过直接对Image组件设置blur，为Image添加模糊效果。
2. 静态模糊先createPixelMap创建图片的PixelMap，然后createEffect创建Filter实例，最后使用Filter图像效果类中的blur，为Image添加模糊效果。

### 相关权限

不涉及。

### 依赖

不涉及。

### 约束与限制

1.本示例仅支持标准系统上运行，支持设备：华为手机。

2.HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3.DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4.HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。

### 下载

如需单独下载本工程，执行如下命令：
```
git init
git config core.sparsecheckout true
echo FuzzySceneOptimization/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```
