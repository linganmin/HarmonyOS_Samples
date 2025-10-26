# 基于Canvas实现画布的功能

### 介绍

本示例通过Canvas实现了一个包括画笔粗细、颜色和透明度的选择、绘制、缩放、清楚等功能的画布功能。帮助开发者掌握Canvas的相关接口属性，绘制自己的业务UI。

### 效果图预览

![](./screenshots/device/canvas.gif)

##### 使用说明

1. 进入首页后，下方有五个按钮，画笔默认选中，可以在空白部分进行绘画，默认粗细是3，颜色是黑色不透明。
2. 进行绘制后，撤回按钮会高亮可点击，点击后可以撤回上一步的笔画；同时重做按钮会高亮可点击，点击重做后还原上一步撤销的笔画。
3. 点击橡皮擦按钮后，手指绘画就会实现擦除效果，画笔按钮取消高亮。
4. 点击清空按钮会清空整个画布的所有绘制，同时清空按钮高亮。
5. 点击画笔按钮，会弹出半模态弹窗，在弹窗内可以选择画笔的类型、颜色、不透明度和粗细。
6. 本示例只展示圆珠笔和马克笔两种类型，圆珠笔为默认类型，这里可以点击马克笔，关闭弹窗再次进行绘画，笔画就变为马克笔。
7. 再次点击画笔唤起弹窗，可以切换颜色、不透明度和粗细，不透明度只有马克笔可以切换，圆珠笔不可以切换。
8. 双指捏合画布缩小，双指外扩画布放大，缩放时画笔按钮取消高亮，缩放结束后，点击画笔就可以再次进行绘制。

### 工程目录

```
├──entry/src/main/ets/
│  ├──common
│  │  └──CommonConstants.ets         // 公共常量类
│  ├──entryability
│  │  └──EntryAbility.ets            // 程序入口类
│  ├──pages                  
│  │  └──Index.ets                   // 首页
│  ├──view   
│  │  └──myPaintSheet.ets            // 半模态页面
│  └──viewmodel
│     ├──DrawInvoker.ets             // 绘制方法
│     ├──IBrush.ets                  // 笔刷接口
│     ├──IDraw.ets                   // 绘制类
│     └──Paint.ets                   // 绘制属性类
└──entry/src/main/resources          // 应用静态资源目录
```

### 具体实现

1. 通过在Canvas上绑定onTouch事件获取触摸点的相对画布的x轴和y轴坐标，将坐标传入路径对象Path2D的moveTo和lineTo方法实现绘制功能。
2. 橡皮擦功能是通过修改CanvasRenderingContext2D的strokeStyle属性为白色来实现的。
3. 每条绘制路径都会通过add方法存放到绘制数组drawPathList中，撤回功能将drawPathList最后一项移除并存到重做数组redoList中，重做功能把redoList中最后一项清除并重新放回drawPathList中。
4. 清除功能是将drawPathList和redoList数组清空后重新绘制画布。
5. 笔刷中圆珠笔的globalAlpha属性值默认为1，且不可改变，马克笔的globalAlpha属性值默认为0.5，可以通过Slider组件调整不透明度。
6. 颜色和粗细修改是通过修改CanvasRenderingContext2D的strokeStyle和lineWidth属性来实现的。

### 相关权限

不涉及。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。