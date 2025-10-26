# 实现Native侧子线程与UI主线程通信

### 介绍

本示例主要介绍如何实现在Native侧子线程中回调UI主线程的函数，实现UI主线程页面刷新。该示例可以帮助开发者学习线程安全函数和libuv异步库的使用，并掌握Native侧跨线程调用的相关能力。

### 效果图预览
![](screenshots/device/NativeSub_MainThreadComm.gif) 

### 使用说明

点击对应按钮会分别调用两种不同方式的代码执行逻辑进行数据处理（即对数据进行加30操作），处理后的结果会显在页面中。

**注意事项**

推荐开发者主要使用线程安全函数来实现在Native侧子线程中回调UI主线程的函数，尽量避免使用libuv的方式。如果非要使用libuv异步库，应使用uv_async_send的方式进行线程间通信，而非使用uv_queue_work函数，该函数主要用于抛异步任务，异步任务的execute回调被提交到线程池后会经过调度执行，因此并不保证多次提交的任务之间的时序关系。 uv_queue_work仅限于在loop线程中调用，这样不会产生多线程安全问题。尽量不要将uv_queue_work作为线程间通信的手段，即A线程获取到B线程的loop，并通过uv_queue_work抛异步任务的方式，把execute回调置为空任务，而把complete回调放在B线程中执行。 这种方式不仅低效，而且还增加了发生故障时定位问题的难度。

### 工程结构&模块类型
```
├──entry/src/main/cpp                   // C++代码区
│  ├──types
│  │  └──libentry                       // C++接口导出
│  │     ├──Index.d.ts                
│  │     └──oh-package.josn5              
│  ├──CMakeLists.txt                    // CMake配置文件     
│  └──napi_init.cpp                     // Native业务代码实现
├──entry/src/main/ets                   // ArkTS代码区
│  ├──entryability                      
│  ├──entrybackupability                
│  └──pages    
│     └──index.ets                      // 主页界面
└──entry/src/main/resources             // 应用资源文件
```

### 具体实现

1. 线程安全函数方式：
   1. 首先在ArkTS侧传递函数到Native侧。
   2. 在Native侧主线程中创建线程安全函数并绑定回调，并拆分子线程。
   3. 在子线程中请求并调用线程安全函数触发回调。
   4. 在回调函数中使用napi_call_function接口调用ArkTS传递的函数。
2. libuv异步库方式：
   1. 首先在ArkTS侧传递函数到Native侧。
   2. 在Native侧主线程中保存上下文环境和函数引用。
   3. 在主线程中声明loop、初始化async句柄绑定回调函数，并拆分子线程。
   4. 在子线程中调用uv_async_send接口，在主线程中触发async句柄回调函数。
   5. 在async句柄回调函数中利用前面保存的上下文环境及函数引用，通过napi_call_function接口调用ArkTS传递的函数。

### 相关权限

**不涉及**

### 参考资料

**不涉及**

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。
2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。