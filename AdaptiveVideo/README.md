# 实现短视频沉浸和旋转播放功能

#### 介绍

根据提供的adaptive_video库实现短视频的沉浸、旋转播放，同时提供一个高阶组件库方便开发者实现功能，降低开发成本，提高开发效率。

#### 效果预览

<img src="./screenshots/screenshots.gif" width="320">

#### 功能描述

1. 非高阶场景支持视频沉浸播放，手机横向视频支持全屏播放，上下切换视频等功能
2. 高阶场景支持视频沉浸播放，手机横向视频支持全屏播放，双击点赞动画，长按2倍速播放，PC/2in1设备支持键盘操作进度等功能

#### 工程目录

```
├──commons
│  ├──base/src/main/ets
│  │  ├──constants
│  │  │  ├──BreakpointConstants.ets                 // 断点常量类
│  │  │  └──CommonConstants.ets                     // 常量类
│  │  └──model
│  │     ├──BreakpointType.ets                      // 根据断点获取不同断点的值
│  │     └──VideoDataSource.ets                     // 懒加载数据源
│  └──base/src/main/resources                       // 应用静态资源目录
├──features
│  ├──adaptive_video_component/src/main/ets
│  │  ├──components
│  │  │  ├──AdaptiveAVPlayer.ets                    // 沉浸和旋转库实现类
│  │  │  ├──CustomAdaptiveVideoComponent.ets        // 高阶组件实现类
│  │  │  ├──PCVideoControl.ets                      // PC端播放控制栏
│  │  │  └──VideoControl.ets                        // 全屏播放播放控制栏
│  │  ├──pages
│  │  │  ├──Home.ets                                // 底部TAB所在类
│  │  │  └──Recommend.ets                           // 顶部TAB所在类
│  │  └──utils
│  │     └──AVPlayerUtil.ets                        // 播放工具类
│  └──adaptive_video_component/src/main/resources   // 应用静态资源目录
└──products
   ├──entry/src/main/ets
   │  ├──entryability
   │  │  └──EntryAbility.ets
   │  ├──entrybackupability
   │  │  └──EntryBackupAbility.ets
   │  └──pages
   │     └──Index.ets                              // 主页面
   └──entry/src/main/resources                     // 应用静态资源目录
```

#### 依赖

依赖自适应视频沉浸式、自适应视频旋转、视频自适应沉浸高阶组件库

库源码地址：https://gitcode.com/openharmony-sig/hadss_adaptive/tree/master/adaptive_video

#### 注意事项

1. 需要实现沉浸效果，需要设置全屏，这样才能根据返回结果控制展示效果

```typescript
windowClass.setWindowLayoutFullScreen(true)
```

如果是2in1设备需要去除标题栏，需要添加如下设置：

```typescript
if (canIUse('SystemCapability.Window.SessionManager')) {
  // 2in1设备设置隐藏标题栏和标题栏高度
  windowClass.setWindowDecorVisible(false);
}
```

2. 如果需要修改本地视频源，注意视频源放到features目录下的rawfile中；同时修改CommonConstants中的VIDEO_SOURCE
3. 如果修改网络视频源，修改CommonConstants中的VIDEO_SOURCE
4. 调用接口后未达到预期效果，如无法实现预期的沉浸式布局，视频页面无法根据旋转属性进行旋转使用adaptive_video中的自适应工具前，需要调用init()方法进行初始化。
5. 在实现短视频滑动播放页面时，视频播放器应选择使用单个AVPlayer还是多个AVPlayer?使用多个AVPlayer，每个AVPlayer控制一个视频播放，确保各视频的播放状态相互独立，并根据视频播放器的索引保证同一时间最多只有一个AVPlayer处于“playing”状态。
6. 视频滑动播放页面的旋转属性需在点击全屏播放（调用setOrientationFullScreen()）后才能生效可能是因为非全屏页面未设置初始旋转属性，建议在进入视频滑动页面或视频切换时主动调用一次AdaptiveRotation的setOrientationNotFullScreen()方法。

#### 相关权限

本Sample依赖以下权限（播放网络视频源）：ohos.permission.INTERNET

#### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机、折叠屏、平板、PC/2in1设备。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。