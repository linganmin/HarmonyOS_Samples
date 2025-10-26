# 翻页动效案例

### 介绍

本示例基于显示动画接口animateTo实现书籍翻页，日历翻页等场景中翻页的效果。

### 效果预览
![](../../../../../../screenshots/device/page_turning.gif)

**使用说明**

本例通过setInterval函数每秒调用一次翻页动画，实现连续翻页效果。

### 具体实现

1. 创建文本组件。动效中用到了4个文本组件，可以定义一个文本组件BookPage，然后对其进行重复调用。创建时为其添加rotate属性，用来控制组件旋转。由于各组件旋转的角度和旋转中心不同，需要父组件在调用时传入对应的参数，所以为对应变量添加@Prop装饰器，用来控制变量传递。
2. 创建父组件框架。由于文本组件分为上下两层，所以在父组件中采用Stack组件进行层叠布局。同时使用Divider组件作为书籍两个页面间的分隔线。
3. 添加翻页动效。在父组件中定义对应的变量，并在调用子组件时分别传入子组件。自定义pageTurningAnimate函数，在其中使用animateTo方法添加动画效果，同时控制动画的时长，以及动画过程中各元素状态的改变。在aboutToAppear方法中，使用setInterval方法重复调用pageTurningAnimate函数，以实现连续翻页动效。

### 相关权限

不涉及

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。