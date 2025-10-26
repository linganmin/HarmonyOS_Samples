# 基于Text组件及通用属性实现文字特效

### 介绍

本示例基于Text组件及通用属性实现多种文字特效。帮助开发者在ArkTS页面开发中实现文字渐变、歌词滚动、文字倒影、跑马灯渐变等多种文字效果。

### 效果预览

![image](./screenshots/device/text_effects.gif)

**使用说明**

1. 启动应用，查看多种文字特效，包含文字渐变、歌词滚动、文字倒影、跑马灯渐变等效果。

### 工程目录

```
├──entry/src/main/ets/
│  ├──constants
│  │  └──Constants.ets                  // 公共常量类
│  ├──entryability
│  │  └──EntryAbility.ets               // 程序入口类
│  ├──page                  
│  │  └──Index.ets                      // 首页
│  └──view
│     ├──TextGradientView.ets           // 文字渐变     
│     ├──TextMarqueeView.ets            // 跑马灯渐变
│     ├──TextReflectionView.ets         // 文字倒影       
│     └──TextScrollingView.ets          // 歌词滚动
└──entry/src/main/resource              // 应用静态资源目录
```

### 具体实现

1. 文字渐变效果通过blendMode混合属性及linearGradient线性渐变属性实现。
2. 歌词滚动效果使用blendMode混合属性及linearGradient线性渐变属性及显式动画实现。
3. 文字倒影效果使用rotate旋转属性及linearGradient线性渐变属性实现。
4. 跑马灯渐变效果使用Text组件textOverflow超长文本显示属性及linearGradient线性渐变属性实现。

### 相关权限

不涉及

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。
