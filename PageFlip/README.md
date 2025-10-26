# 实现阅读器翻页效果

## 介绍

本示例基于显式动画、List组件、drawing接口实现了阅读器上下翻页、左右覆盖翻页、仿真翻页等效果。

## 效果预览

<img src="./screenshots/device/page_flip.webp" width="320">

### 使用说明

- 进入应用默认为仿真翻页，在屏幕上滑动手指执行翻页。支持点击左右两侧自动翻页。点击屏幕中部区域，弹出翻页选项。
- 选择上下翻页，显示上下翻页页面。支持上下滑动。
- 选择覆盖翻页，显示覆盖翻页页面。支持左右滑动翻页，以及点击屏幕左右侧后滑动翻页。

## 工程目录

```
├──entry/src/main/ets/
│  ├──common
│  │  └──Constants.ets               // 公共常量类
│  ├──entryability
│  │  └──EntryAbility.ets            // 程序入口类
│  ├──pages
│  │  └──Index.ets                   // 首页
│  ├──view
│  │  ├──BottomView.ets              // 按钮弹窗
│  │  ├──CoverFlipPage.ets           // 覆盖翻页
│  │  ├──EmulationFlipPage.ets       // 仿真翻页
│  │  ├──ReaderPage.ets              // 文字页面
│  │  └──UpDownFlipPage.ets          // 上下翻页
│  └──viewmodel
│     ├──BasicDataSource.ets         // 列表数据类
│     └──PageNodeController.ets      // 节点控制类
└──entry/src/main/resource           // 应用静态资源目录
```

## 具体实现

1. 使用List组件实现上下滑动效果；使用组件位移及显式动效animateTo实现左右覆盖翻页效果。

2. 使用ArkGraphics 2D（方舟2D图形服务） @ohos.graphics.drawing接口及NodeContainer组件，实现仿真翻页效果的绘制。根据手指滑动触摸位置，计算仿真页的边缘节点，填充区域后实现。

## 相关权限

不涉及

## 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机、平板。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。
