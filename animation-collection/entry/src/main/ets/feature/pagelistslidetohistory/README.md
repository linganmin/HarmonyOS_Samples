# 长列表滑动到指定列表项动效实现

### 介绍
在长列表场景时，当用户在浏览过程中打断时，列表会从第一项开始重新加载，此时我们使用scrollToIndex跳转到某个列表项时，当开启smooth动效时，会对经过的所有item进行加载和布局计算，当大量加载item时会导致性能问题，影响用户体验。因此我们使用currentOffset方法获取并记录偏移量，然后使用scrollTo方法跳转到上次浏览记录功能，可以流畅滑动到上次列表的位置。

### 效果预览：

![](../../../../../../screenshots/device/ListSlideToHistory.gif)

**使用说明**

1. 进入页面，往下滑动列表；
2. 点击右下角出现的“回到顶部”按钮，列表滑动到顶部，并同时记录上一次的位置坐标；
3. 点击“跳转到还没看的位置”，观察到列表流畅滑动到上次浏览位置。

### 相关权限

不涉及。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。