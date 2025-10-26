# 数字滚动动效

### 介绍

本示例介绍数字滚动动效的实现方案。 该方案多用于数字刷新，例如页面刷新抢票数量等场景。

### 效果图预览

![](../../../../../../screenshots/device/digital_scroll.gif)

**使用说明**

1. 下拉页面刷新，数字进行刷新。

### 实现思路

1. 通过双重ForEach循环分别横向、纵向渲染数字。
2. 通过Math.random()生成随机数，并更新到currentData数组中。
3. 使用显示动画animateTo，对currentData数组中的每个数字执行不同的滚动动效。
4. 设置数字所在容器属性.clip(true)，将多余的数字裁剪。

### 相关权限
不涉及。

### 依赖
不涉及。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。