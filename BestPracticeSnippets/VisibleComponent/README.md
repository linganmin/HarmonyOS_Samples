# 不可见组件低功耗建议

### 介绍

应用在调用动画、动效以及依赖Vsync机制进行刷新的组件时，需保证使用的组件，在页面进行隐藏、跳转或动画位于屏幕外部时，停止刷新帧请求，规避由此带来的空跑现象。

当前推荐用于预防组件进入不可见状态后，依然空跑的问题大致有两种思路：
* 监听法：监听容器状态，传递关键变量。
* 可见法：通过组件可见性计算，判断显示/隐藏时机。

本示例通过监听法，展示列表组件下拉刷新时，管理刷新动画的不可见现象的场景；通过可见法，展示使用ImageAnimator实现的动画组件。

### 效果预览
![pic1.png](screenshots/visibleComponent.gif)

### 工程目录
```
├──entry/src/main/ets
│  ├──entryability
│  │  └──EntryAbility.ets                   // Ability的生命周期回调内容
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets             // 程序入口类
│  └──pages 
│     └──Index.ets                          // 监听法与可见法示例页面
└──entry/src/main/resources                 // 应用静态资源目录
```

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
echo VisibleComponent/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```