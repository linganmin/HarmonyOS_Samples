# 使用Stack组件构建多层次堆叠布局

### 介绍

本示例介绍运用Stack组件以构建多层次堆叠的视觉效果。通过绑定Scroll组件的onScrollFrameBegin滚动事件回调函数，精准捕获滚动动作的发生。当滚动时，实时地调节组件的透明度、高度等属性，从而成功实现了嵌套滚动效果、透明度动态变化以及平滑的组件切换。

### 效果图预览

![image](./screenshots/phone.gif)

### 使用说明

1. 加载完成后显示整个界面，超过一屏可以上下滑动可见堆叠效果。

### 目录结构

```
componentstack
├──entry/src/main/ets
│  ├──constant
│  │  └──StackConstant.ets                        // 常量类
│  ├──entryability
│  │  └──EntryAbility.ets                         // 应用生命周期类
│  ├──model
│  │  └──IconModel.ets                            // 本地数据源
│  ├──pages
│  │  └──Index.ets                                // 组件堆叠主页面 
│  ├──view
│  │  ├──IconView.ets                             // 按钮快捷入口自定义组件 
│  │  └──ProductList.ets                          // 商品列表自定义组件
│  └──viewmodel
│     ├──DataSource.ets                           // 列表数据模型
│     └──IconViewModel.ets                        // 数据类型定义
└────entry/src/main/resources 
```

### 实现思路

1. 在向上滑动过程中观察到头部组件是处于层级底部，而其他组件覆盖在其上方，为此，选择Stack组件来获取堆叠效果。
2. 在顶部的可滚动区域，通过使用Scroll组件来获取堆叠效果。
3. 实现滚动过程中动态调整文本框高度的功能时，运用Scroll组件滚动事件回调函数onScrollFrameBegin在滚动时修改文本框的高度及组件的透明度。
4. 存在多层嵌套滚动的情况时，应该先滚动父组件，再滚动自身。只需要在内层的Scroll组件的属性nestedScroll设置向前向后两个方向上的嵌套滚动模式，实现与父组件的滚动联动。
5. 在商品列表区域，采用瀑布流（WaterFlow）容器进行布局，将商品信息动态分布并分成两列呈现，每列商品自上而下排列。

### 相关权限
不涉及。

### 依赖
不涉及。

### 约束与限制

1.本示例仅支持标准系统上运行，支持设备：华为手机。

2.HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3.DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4.HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。