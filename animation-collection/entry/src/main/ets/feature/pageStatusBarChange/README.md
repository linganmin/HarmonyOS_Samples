# 状态栏显隐切换

### 介绍

本示例介绍使用Scroll组件的滚动事件onWillScroll实现状态栏显隐变化，该场景多用于各种软件的首页、我的等页面中。

### 效果预览

![](../../../../../../screenshots/device/Change.gif)

使用说明：
1. 加载完成后显示状态栏显隐变化页面，上下拖动屏幕，顶端状态栏出现显隐变化。

### 工程目录

```
├──entry/src/main/ets/feature/pageStatusBarChange
│  ├──common/constant
│  │  └──CommonConstants.ets             // 公共常量类
│  └──view                  
│     └──PageStatusBarChange.ets         // 组件
└──entry/src/main/resources              // 应用静态资源目录
```

### 具体实现

1. 在置顶位置使用Stack组件添加两层状态栏。
2. 通过获取Scroll的偏移量，计算透明度，分别对状态栏的组件设置透明度来实现状态栏的显隐变化效果。

### 相关权限
不涉及

### 依赖
不涉及

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。