# 实现Swiper组件加载慢丢帧优化

### 介绍

本示例通过采用懒加载和预加载技术，优化了Swiper组件在多图片场景下的加载性能，实现了流畅的滑动体验。这种方式不仅减少了初始加载时间，还确保了用户在浏览时的顺畅与高效。

### 效果预览

| 答题页                                           | 图片页                                          |
|-----------------------------------------------|----------------------------------------------|
| ![Question.png](screenshots/devices/pic1.png) | ![Picture.png](screenshots/devices/pic2.png) |

### 目录结构

```
├──entry/src/main/ets/
│  ├──common
│  │  ├──ImageUtils.ets                   // 图片处理工具类
│  │  ├──MyDataSource.ets                 // 懒加载数据源工具类
│  │  └──Logger.ets                       // 日志打印工具类
│  ├──entryability
│  │  └──EntryAbility.ets                 // 程序入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets           // 数据备份恢复类
│  ├──model
│  │  ├──Question.ets                     // 问题实体类
│  │  └──SwiperData.ets                   // 图片实体类
│  └──pages
│     ├──Index.ets                        // 应用入口页
│     ├──LazyForEachSwiper.ets            // Swiper懒加载（答题）页面
│     └──PreloadDataSwiper.ets            // Swiper数据预加载（图片）页面
└──entry/src/main/resources               // 应用静态资源目录

```

### 使用说明

1. 点击首页按钮“使用LazyForEach加载Swiper”，进入问答页面，页面左右滑动流畅。
2. 点击首页按钮“提前加载数据加载Swiper”，进入图片页面，页面左右滑动流畅。

### 实现说明

1. Swiper懒加载使用LazyForEach实现。
2. Swiper数据预加载在onAnimationStart方法中提前加载数据。

### 相关权限

* ohos.permission.INTERNET：允许使用Internet网络。

### 依赖

不涉及。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。
2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。



