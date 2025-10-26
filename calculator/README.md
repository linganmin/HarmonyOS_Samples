# 基于ArkTS实现卡片计算器功能

### 介绍

本示例基于ArkTS卡片实现了一个卡片计算器，利用ArkTS的优势，卡片的设计注重简洁直观的用户界面，确保操作简便流畅，并且能够快速响应用户的输入。

### 效果预览

| 添加卡片                                             | 卡片预览                                                    | 操作卡片                                             |
|--------------------------------------------------|---------------------------------------------------------|--------------------------------------------------|
| ![CalculatorAdd](screenshots/CalculatorAdd.png) | ![CalculatorPreview](screenshots/CalculatorPreview.png) | ![CalculatorUse](screenshots/CalculatorUse.png) |

### 使用说明

1.长按应用图标，将卡片添加到桌面。

2.对桌面上的卡片进行计算操作。

### 工程目录

```
├──entry/src/main/ets                         // 代码区
│  ├──calc/pages
│  │  └──CardCalc.ets                         // 计算器卡片页面
│  ├──entryability
│  │  └──EntryAbility.ets                     // 程序入口类
│  ├──entryformability
│  │  └──EntryFormAbility.ets                 // 卡片声明周期处理文件
│  ├──model
│  │  └──Logger.ts                            // 日志工具
│  └──pages
│     └──index.ets                            // 首页
├──entry/src/main/resources                   // 应用资源目录
└──module.json5                               // 应用配置文件
```

### 相关权限

不涉及。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。
2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。