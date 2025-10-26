# 跑马灯案例

### 介绍

本示例介绍了文本宽度过宽时，如何实现文本首尾相接循环滚动并显示在可视区，以及每循环滚动一次之后会停滞一段时间后再滚动。

### 效果图预览

![](../../../../../../screenshots/device/Marquee.gif) 

**使用说明**：

1.进入页面，检票口文本处，实现文本首尾相接循环滚动，且在同一可视区，滚动完成之后，停滞一段时间后继续滚动。


### 工程结构

```
├──entry/src/main/ets/feature/pageMarqueeView
│  ├──common
│  │  └──FunctionDescription.ets                                  // 公共组件类
│  ├──entryability
│  │  └──EntryAbility.ets                                         // 程序入口类
│  ├──model                  
│  │  │──Constants.ets                                            // 常量
│  │  │──DataSource.ets                                           // 数据监听器
│  │  │──DataType.ets                                             // 数据类型
│  │  └──MockData.ets                                             // Mock数据
│  └──view                  
│     └──Marquee.ets                                              // 入口组件
└──entry/src/main/ets/feature/pageMarqueeView/resource            // 应用静态资源目录
```

### 相关权限

不涉及。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。