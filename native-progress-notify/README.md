# 基于Native实现进度通知功能

### 介绍

本示例通过模拟下载场景介绍如何将Native的进度信息实时同步到ArkTS侧。通过在Native侧创建线程安全函数将Native侧子线程中的进度数据实时同步给ArkTS侧，用于界面显示。通过该示例开发这个可以了解Native线程安全函数相关接口以及Native侧进度条实时同步实现方案。

### 效果图预览

![](screenshots/device/native_progress_notify.gif)

**使用说明**

1. 点击“Start Download“按钮后，Native侧启动子线程模拟下载任务。
2. Native侧启动子线程模拟下载，并通过ArkTS的回调函数将进度信息实时传递到ArkTS侧。

### 高性能知识点

本例中，在Native侧使用子线程执行下载任务，从而避免对主线程资源的占用，能有效提升性能。

### 工程结构&模块类型

```
├──entry/src/main/cpp                         // C++ 代码区
│  ├──types
│  │  └──libentry                             // C++接口导出
│  │     ├──index.d.ts                        
│  │     └──oh-package.josn5                 
│  ├──CMakeLists.txt                          // CMake配置文件
│  └──napi_init.cpp                           // Native模块注册
├──entry/src/main/ets                         // ets 代码区
│  ├──constants
│  │  └──CommonConstants.ets                  // 常量定义文件  
│  ├──conversionability
│  │  └──ConversionAbility.ets       
│  └──pages
│     └──Index.ets                            // 主页界面
└──entry/src/main/resources                   // 应用资源目录
```

### 相关权限

**不涉及**

### 参考资料

1. [Progress](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-basic-components-progress)
2. [使用Node-API实现跨语言交互](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/using-napi-interaction-with-cpp)

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。 
2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。 
3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。 
4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。