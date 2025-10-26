# 基于分帧渲染实现应用界面优化

### 介绍

在应用开发中，页面内列表结构复杂，每个列表项包含的组件较多，就会导致嵌套层级较深，从而引起组件负载加重，绘制耗时增长。
本示例介绍在高负载的转场场景和滑动场景下使用分帧渲染提升性能，本工程配套官网[高负载场景下分帧渲染](https://developer.huawei.com/consumer/cn/doc/best-practices/bpta-dispose-highly-loaded-component-render)。
涉及的ArkUI接口：[@ohos.graphics.displaySync (可变帧率)](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-graphics-displaysync#displaysynccreate)。

### 预览效果

| 转场场景                                             | 滑动场景                                          |
|--------------------------------------------------|-----------------------------------------------|
| ![image](screenshots/device/TransitionScene.gif) | ![image](screenshots/device/SlidingScene.gif) |

#### 使用说明

1. 点击“转场场景”按钮，转场动画完成后进入页面，页面加载完成。
2. 点击“滑动场景”按钮，进入日历页面，页面可以上下流畅滑动。

## 工程目录

``` 
├──entry/src/main/ets                          
│  ├──common
│  │  ├──CommonConstants.ets            // 公共常量
│  │  └──GlobalBuilderContext.ets       // 缓存全局@Builder
│  ├──entryability
│  │  └──EntryAbility.ets               // 程序入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets         // 自定义应用数据转换和迁移模板类
│  ├──model                              
│  │  ├──BasicDataSource.ets            // 数据适配器基类
│  │  ├──MidListDataSource.ets          // 转场场景中间横向List数据适配器
│  │  ├──MonthDataSource.ets            // 日历数据适配器
│  │  ├──ProductDetailSource.ets        // 转场场景底部瀑布流数据适配器
│  │  └──SwiperDataSource.ets           // 转场场景swiper数据适配器
│  ├──pages
│  │   └──Index.ets                     // 首页
│  ├──util
│  │   └──CalculationDateUtil.ets       // 日历工具类
│  └──view                        
│     ├──DateItemView.ets               // 每个月的日历数据
│     ├──SlidingScene.ets               // 日历页面 UI
│     ├──TestCode.ets                   // 代码同源举例
│     └──TransitionScene.ets            // 转场场景 UI
└──entry/src/main/resources             // 应用资源目录
``` 

### 具体实现

1. [转场场景](https://developer.huawei.com/consumer/cn/doc/best-practices/bpta-dispose-highly-loaded-component-render#section5987133112411)
2. [滑动场景](https://developer.huawei.com/consumer/cn/doc/best-practices/bpta-dispose-highly-loaded-component-render#section15195122915243)

### 相关权限

不涉及

## 约束与限制

* 本示例仅支持标准系统上运行，支持设备：华为手机。
* HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
* DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
* HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。

### 下载

如需单独下载本工程，执行如下命令：
```
git init
git config core.sparsecheckout true
echo FramedRendering/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```