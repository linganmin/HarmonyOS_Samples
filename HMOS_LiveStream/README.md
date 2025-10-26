# 基于HarmonyOS媒体子系统实现媒体直播功能

## 项目简介

本示例基于HarmonyOS媒体子系统，实现媒体直播的开直播端和看播端。本示例实现了直播场景常用的音视频采集、音视频播放、音频焦点管理、ROI、
背景音乐添加、前后摄像头翻转等功能。基于本示例可帮助应用开发开启直播和观看直播的场景。

- 看播端是通过播放视频文件来模拟的，主要流程是将直播端录制的视频文件通过AvPlayer播放。
- 直播端视频录制的主要流程是相机采集->Opengl旋转->编码->封装成mp4文件。
- 直播过程通过分布式文件进行模拟。两台手机分别模拟直播端和看播端，须登录同一个华为账号并开启WIFI和蓝牙，完成分布式组网。具体流程为：直播端
  将录制的视频文件保存到沙箱并拷贝到分布式目录中，看播端将分布式文件下的视频文件拷贝到沙箱后，通过AvPlayer进行播放。
- 录制场景在相机和编码之间加了OpenGL渲染管线，开发者可参考该流程加上对应的Shader，如直播场景加上美颜、滤镜等算子。

### 播放支持的原子能力规格

| 媒体格式 | 封装格式    | 码流格式                                |
|------|:--------|:------------------------------------|
| 视频   | mp4     | 视频码流：H.264/H.265， 音频码流：AAC          |
          

### 录制支持的原子能力规格

| 封装格式 | 视频编解码类型     | 音频编解码类型 | 
|------|-------------|---------|
| mp4  | H.264/H.265 | AAC |

## 效果预览

| 应用主界面                                                                            | 直播页                                                                                      | 看播页                                                                                  |
|----------------------------------------------------------------------------------|------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------|
| <img src="screenshots/device/Index_zh.png" width="320"  alt="App Home Screen" /> | <img src="screenshots/device/StartLive_zh.png" width="320"  alt="Live Streaming Demo" /> | <img src="screenshots/device/Watch_zh.png" width="320"  alt="Live Streaming Demo" /> |

## 使用说明

1. 在弹出是否允许“HMOSLiveStream”访问你的相机后，点击“允许”。
2. 在弹出是否允许“HMOSLiveStream”访问你的麦克风后，点击“允许”。
3. 在弹出是否允许“HMOSLiveStream”发现和连接附近的设备后，点击“允许”。

### 开直播

1. 点击“开直播”。

2. 确认允许录制文件保存到分布式文件。

3. 录制完成后点击右上角的按钮关闭。

### 看直播

1. 在开直播结束后，可以进行看直播。

2. 点击“看直播”，即可进入直播播放页面。

## 工程目录

```       
├──entry/src/main/cpp                 // Native层
│  ├──capbilities                     // 能力接口和实现
│  │  ├──render                       // 送显模块接口和实现
│  │  │  ├──include                   // 送显模块接口
│  │  │  │  ├──egl_render_context.h   // EGL渲染上下文接口
│  │  │  │  ├──render_thread.h        // 渲染线程接口
│  │  │  │  └──shader_program.h       // 封装 OpenGL ES 着色器程序的接口
│  │  │  ├──render_thread.cpp         // 渲染线程
│  │  │  ├──egl_render_context.cpp    // EGL渲染上下文实现
│  │  │  └──shader_program.cpp        // 封装 OpenGL ES 着色器程序
│  │  ├──codec                        // 音视频采集编解码
│  │  │  ├──include                   // 音视频采集编解码接口
│  │  │  ├──AudioCapturer.cpp         // 音频采集实现
│  │  │  ├──AudioDecoder.cpp          // 音频解码实现
│  │  │  ├──AudioEncoder.cpp          // 音频编码实现
│  │  │  ├──AudioRender.cpp           // 音频渲染实现
│  │  │  ├──CodecCallback.cpp         // 编解码相关的回调
│  │  │  ├──Demuxer.cpp               // 解封装实现
│  │  │  ├──Muxer.cpp                 // 封装实现
│  │  │  └──VideoEncoder.cpp          // 视频编码实现
│  ├──common                          // 公共模块
│  │  ├──dfx                          // 日志
│  │  ├──ApiCompatibility.h           // API兼容性
│  │  └──SampleInfo.h                 // 功能实现公共类  
│  ├──player                          // Native层播放接口和实现
│  │  ├──include                      // Native层播放接口
│  │  │  ├──Player.h                  // Native层播放功能调用逻辑的接口
│  │  │  └──PlayerNative.h            // Native层 播放的入口的接口
│  │  ├──Player.cpp                   // Native层播放功能调用逻辑的实现
│  │  └──PlayerNative.cpp             // Native层 播放的入口
│  └──recorder                        // Native层录制接口和实现
│  │     ├──include                   // Native层录制功能调用逻辑的实现
│  │     │  ├──Recorder.h             // Native层录制功能调用逻辑的接口
│  │     │  └──RecorderNative.h       // Native层 录制入口的接口
│  │     ├──Recorder.cpp              // Native层录制功能调用逻辑的实现
│  │     └──RecorderNative.cpp        // Native层 录制的入口
│  ├──types                           // Native层提供上来的接口
│  │  ├──libplayer                    // 播放模块提供给UI层的接口
│  │  └──librecorder                  // 录制模块提供给UI层的接口
│  └──CMakeLists.txt                  // 编译入口       
├──ets                                // UI层
│  ├──common                          // 公共模块
│  │  ├──utils                        // 共用的工具类
│  │  │  ├──BackgroundTaskManager.ets // 后台任务工具类
│  │  │  ├──CameraCheck.ets           // 检查相机参数是否支持
│  │  │  ├──DateTimeUtils.ets         // 时间转换工具类
│  │  │  ├──ImageUtil.ets             // 图片处理工具类
│  │  │  └──Logger.ets                // 日志工具
│  │  ├──GlobalConstants.ets          // 全局变量名称
│  │  └──CommonConstants.ets          // 参数常量
│  ├──components                      // 组件目录
│  │  └──SettingPopupDialog.ets       // 设置相关数据类   
│  ├──controller                      // 控制器
│  │  ├──BgmController.ets            // 背景音乐控制器
│  │  ├──CameraController.ets         // 相机控制器
│  │  ├──DistributeFileManager.ets    // 分布式文件管理器
│  │  ├──VideoPlayerController.ets    // 本地音视频播放控制器
│  │  └──VideoSessionController.ets   // 音频会话控制器 
│  ├──entryability                    // 应用的入口
│  │  └──EntryAbility.ets            
│  ├──entrybackupability            
│  │  └──EntryBackupAbility.ets   
│  ├──model            
│  │  ├──CameraDataModel.ets          // 相机参数数据类  
│  │  └──SettingPopupOptionItem.ets   // 设置的数据类  
│  ├──pages                           // EntryAbility 包含的页面
│  │  ├──Index.ets                    // 首页
│  │  ├──StartLiveStream.ets          // 直播端页面
│  │  └──WatchLiveStream.ets          // 看播端页面
│  └──view                            // EntryAbility 包含的页面
│     ├──AvplayerView.ets             // 看播端AvPlayer音视频播放
│     ├──StartLiveDecorationView.ets  // 直播端数据页面
│     ├──StartLiveRenderView.ets      // 直播端渲染器
│     └──WatchLiveDecorationView.ets  // 看播端数据页面
├──resources                          // 存放应用的资源文件
└──module.json5                       // 模块配置信息
```

## 具体实现

### 开直播

#### UI层

1. 在UI层Index页面，用户点击“开直播”后，确认保存录制文件到分布式文件夹下，将会创建一个新的文件。
2. 创建好文件后，会用刚刚创建文件的fd，和用户预设的录制参数，调用Native层的initNative()进行录制初始化，待初始化结束后，Native层会调用
   OH_NativeWindow_GetSurfaceId接口，得到NativeWindow的surfaceId，并把surfaceId回调回UI层。
3. UI层拿到编码器给的surfaceId后，构造cameraController和bgmController，并调起页面路由，跳转到StartLiveStream页面。
4. StartLiveStream页面中的StartLiveRenderView组件的XComponent在构建时，会调起.onLoad()方法，此方法首先会拿到XComponent的surfaceId，
   然后调起cameraController的createRecorder()和startNative()，此函数会建立一个相机生产，XComponent和编码器的surface消费的生产消费模型。

#### Native层编码

1. 进入录制界面后，编码器启动，开始对UI层相机预览流进行编码。
2. 编码器每编码成功一帧，sample_callback.cpp的输出回调OnNewOutputBuffer()就会调起一次，此时用户会拿到AVCodec框架给出的OH_AVBuffer。
3. 在输出回调中，用户需手动把帧buffer、index存入输出队列中，并通知输出线程解锁。
4. 在输出线程中，把上一步的帧信息储存为bufferInfo后，pop出队。
5. 在输出线程中，使用上一步的bufferInfo，调用封装接口WriteSample后，这一帧被封装入MP4中。
6. 最后调用FreeOutputBuffer接口后，这一帧buffer释放回AVCodec框架，实现buffer轮转。

#### Native层解码

1. 具体实现原理：
    - 解码器Start后，解码器每拿到一帧，OnNeedInputBuffer就会被调起一次，AVCodec框架会给用户一个OH_AVBuffer。
    - 在输入回调中，用户需手动把帧buffer、index存入输入队列中，并同时输入线程解锁。
    - 在输入线程中，把上一步的帧信息储存为bufferInfo后，pop出队。
    - 在输入线程中，使用上一步的bufferInfo，调用ReadSample接口解封装帧数据。
    - 在输入线程中，使用解封装后的bufferInfo，调用解码的PushInputData接口，此时这片buffer用完，返回框架，实现buffer轮转。
    - PushInputData后，这一帧开始解码，每解码完成一帧，输出回调会被调起一次，用户需手动把帧buffer、index存入输出队列中。
    - 在输出线程中，把上一步的帧信息储存为bufferInfo后，pop出队。
    - 在输出线程中，调用FreeOutputData接口后，就会送显并释放buffer。释放的buffer会返回框架，实现buffer轮转。
2. 解码器config阶段，OH_VideoDecoder_SetSurface接口的入参OHNativeWindow*，即为PluginManager中的pluginWindow_。
3. 解码器config阶段，SetCallback接口，sample_callback.cpp的输入输出回调需将回调上来的帧buffer和index存入一个用户自定义容器sample_info.h中，方便后续操作。
4. Player.cpp的Start()创建两个专门用于输入和输出的线程。

### 看直播

#### UI层

1. 在UI层Index页面，用户点击看直播按钮后，触发点击事件，应用会将分布式目录下的视频文件拷贝到沙箱中，并选择最新的视频文件进行播放。
2. 将视频文件信息传递给AvplayerView，使用Avplayer完成视频的播放。

## 相关权限

- 允许应用使用相机：ohos.permission.CAMERA。
- 允许应用使用麦克风：ohos.permission.MICROPHONE。
- 运行应用使用分布式文件进行同步：ohos.permission.DISTRIBUTED_DATASYNC。
- 运行应用后台运行：ohos.permission.KEEP_BACKGROUND_RUNNING。

## 依赖

- 不涉及

## 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 6.0.0 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 6.0.0 Release SDK及以上。