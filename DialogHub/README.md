# 基于DialogHub实现通用弹窗库案例
## 简介
本案例演示了如何利用[DialogHub](https://gitee.com/hadss/dialoghub)弹窗框架实现多样化的弹窗需求。
涵盖了常见弹窗类型展示、弹窗与页面及用户的交互模式、弹窗组件的复用技巧，以及在同一页面中有效管理多个弹窗的解决方案。
通过这些实例，您可以快速掌握DialogHub的灵活应用，提升用户界面的交互体验与功能丰富性。

## 效果图预览

| 自定义弹窗                                       | 跟手弹窗                                       | 半模态弹窗                                      | Toast弹窗                                    |
|---------------------------------------------|--------------------------------------------|--------------------------------------------|--------------------------------------------|
| ![](screenshots/device/zh/customDialog.png) | ![](screenshots/device/zh/popupDialog.png) | ![](screenshots/device/zh/sheetDialog.png) | ![](screenshots/device/zh/toastDialog.png) |

## 工程目录
```text
├─entry/src/main/ets                         // 代码区
├── components                               // UI组件
│   ├── ActiveCloseBuilder.ets               // 可主动关闭的弹窗Builder
│   ├── AutoDismissBuilder.ets               // 点击蒙层自动关闭的弹窗Builder
│   ├── IconToastBuilder.ets                 // 可透传手势的弹窗Builder
│   ├── ImagePopupBuilder.ets                // 指向选定组件的带箭头弹窗Builder
│   ├── InputBuilder.ets                     // 避让键盘的弹窗Builder
│   ├── InputCallbackBuilder.ets             // 向页面返回数据弹窗Builder
│   ├── ProgressBuilder.ets                  // 父页面可刷新弹窗内容的弹窗Builder
│   ├── SheetBuilder.ets                     // 动态调整高度的底部弹窗Builder
│   ├── SimpleCustomBuilder.ets              // 模板弹窗Builder
│   ├── SkipBuilder.ets                      // 带跳转链接的弹窗Builder
│   ├── SnackbarBuilder.ets                  // 指定位置的非模态弹窗Builder
│   ├── TextToastBuilder.ets                 // 简单模板弹窗Builder
│   └── TimeToastBuilder.ets                 // 定时弹窗Builder
├── entryability
│   └── EntryAbility.ets
├── pages                                    // 页面
│   ├── Others                               // 带跳转链接页面
│   │   ├── RouterSkip.ets                   // router跳转页面
│   │   └── SkipAction.ets                   // navigation跳转页面
│   ├── CommonExamples.ets                   // 常见示例页面
│   ├── Index.ets                            // 主页
│   ├── MultiDialogExample.ets               // 多个弹窗处理页面
│   ├── OperableExample.ets                  // 用户交互页面
│   └── ReuseExample.ets                     // 弹窗复用页面
└── utils    
    ├── CommonConstant.ets                   // 公共常量类                                
    ├── ItemHead.ets                         // 模块头部组件
    └── SampleModifier.ets                   // 动态属性工具                                 
```

## 约束与限制
- 本示例仅支持标准系统上运行，支持设备：华为手机。
- HarmonyOS系统： HarmonyOS 5.0.3 Release及以上。
- DevEco Studio版本：DevEco Studio 5.0.3 Release及以上。
- HarmonyOS SDK版本： HarmonyOS 5.0.3 Release SDK及以上。
- 暂不支持预览器，请运行代码查看实际效果。