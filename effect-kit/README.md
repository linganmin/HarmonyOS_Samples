# 基于ColorPicker实现自适应背景色功能

### 介绍

本示例介绍使用Image库以及EffectKit库中的colorPicker对目标图片进行取色，将获取的颜色作为背景渐变色，通过Swiper组件对图片进行轮播。基于该案例开发者可以熟练的使用ColorPicker相关接口以及图片的自动轮播设置。

### 效果图预览

<img src="screenshots/device/effect_kit.png" width=320>

**使用说明**

直接进入页面，对图片进行左右滑动，或者等待2s后图片自动轮播，图片切换后背景颜色会自动改变。

### 实现思路

1. 在事件onAnimationStart切换动画过程中通过Image模块相关能力，获取图片颜色平均值，使用effectKit库中的ColorPicker智能取色器进行颜色取值。
2. 同时通过接口animateTo开启背景颜色渲染的属性动画。全局界面开启沉浸式状态栏。
3. 通过属性linearGradient设置背景色渲染方向以及渲染氛围。

### 高性能知识点

**不涉及**

### 工程结构&模块类型
```
├──entry/src/main/ets                         // ets 代码区
│  ├──constants
│  │  └──CommonConstants.ets                  // 常量定义文件  
│  ├──entryability
│  │  └──EntryAbility.ets       
│  └──pages
│     └──Index.ets                            // 主页界面
└──entry/src/main/resources                   // 应用资源目录
```

### 模块依赖

**不涉及**

### 参考资料

**不涉及**

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。
2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。