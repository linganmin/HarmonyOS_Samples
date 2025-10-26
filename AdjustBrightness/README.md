## 实现页面亮度调节的功能

### 介绍

在“视频播放”和“付款码展示”这两种典型场景下，应用需要在不同的页面分别设置不同的屏幕亮度，用户也可以自定义调节屏幕亮度，并且随着页面跳转而自动恢复系统亮度设置。
本示例通过窗口能力提供的[setWindowBrightness](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-window#setwindowbrightness9)和[setWindowKeepScreenOn](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-window#setwindowkeepscreenon9)实现这两种典型场景，帮助开发者理解并掌握页面亮度设置开发的流程与细节，当开发者业务需要“调节页面亮度”的情况，可直接复用本示例代码。

### 预览效果
![image](screenshots/device/SetBrightness.gif)

【备注】录屏无法录制亮度变化，具体实现已真机为准

### 使用说明

1. 点击“视频播放”按钮，进入视频播放页面，点击播放，手指触摸视频左侧上下滑动调节页面亮度，视频自动循环播放，播放过程中不会熄屏，保持常亮；
暂停视频，静置，屏幕跟随系统设置熄屏时间自动熄屏。
2. 点击“付款码”按钮，进入付款码页面，页面自动高亮。
3. 从“视频播放页”或“付款码页”返回首页，页面恢复在系统设置的屏幕亮度。
4. 在“视频播放页”调节完亮度后，返回主页，再次进入“视频播放页”，页面恢复之前设置的“视频播放页”亮度。

### 工程目录

``` 
├──entry/src/main/ets                          
│  ├──common
│  │  ├──Constants.ets                  // 公共常量
│  │  └──GlobalBuilderContext.ets       // 缓存全局@Builder
│  ├──entryability
│  │  └──EntryAbility.ets               // 程序入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets         // 自定义应用数据转换和迁移模板类
│  ├──model                              
│  │  ├──CommentModel.ets               // “视频播放页”视频评论数据结构 model
│  │  └──SystemAreaModel.ets            // 缓存系统状态栏和导航栏高度 model
│  ├──pages
│  │  ├──Index.ets                      // 首页
│  │  ├──PayCodePage.ets                // 付款码页面结构
│  │  └──VideoPage.ets                  // 视频播放页面结构
│  ├──util
│  │  └──BrightnessUtil.ets             // 亮度调节工具类
│  ├──view                        
│  │  ├──PayCodeView.ets                // 付款码页面 view
│  │  ├──VideoCommentView.ets           // 视频页评论 view
│  │  └──VideoView.ets                  // 视频页视频播放组件 view
│  └──viewmodel
│     ├──BrightnessViewModel.ets        // 亮度调节 viewModel
│     └──CommentViewModel.ets           // 视频播放页评论 viewModel
└──entry/src/main/resources             // 应用资源目录
``` 

### 具体实现

1. “视频播放页”调节亮度：触摸滑动Slider组件，Slider回调滑动进度[0-1]，调用@ohos.window.setWindowBrightness,设置屏幕亮度。
[VideoView.ets](entry/src/main/ets/view/VideoView.ets)
2. “视频播放页”亮度高亮：播放视频Video组件，分别在onStart/onPause回调中，设置屏幕是否常亮 @ohos.window.setWindowKeepScreenOn。
[VideoView.ets](entry/src/main/ets/view/VideoView.ets)
3. “付款码页”屏幕高亮：进入页面，调用 @ohos.window.setWindowBrightness(1)。
[BrightnessViewModel](entry/src/main/ets/viewmodel/BrightnessViewModel.ets)
4. 返回主页恢复默认亮度，调用 @ohos.window.setWindowBrightness(-1)。
[BrightnessViewModel](entry/src/main/ets/viewmodel/BrightnessViewModel.ets)

### 相关权限

不涉及

### 约束与限制

* 本示例仅支持标准系统上运行，支持设备：华为手机。
* HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
* DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
* HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。