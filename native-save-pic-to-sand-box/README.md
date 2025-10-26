# 基于Native实现保存图片到应用沙箱功能

### 介绍

本示例主要介绍如何在Native侧将图片保存到应用沙箱中，主要包括保存网络图片和保存Rawfile中的图片两种场景。保存网络图片主要利用Curl三方库能力实现，保存Rawfile中的图片主要通过资源管理器以及字节流的方式保存图片。通过该案例开发者可以了解到两种不同场景下获取图片并保存的详细方法。

### 效果图预览

![](screenshots/device/native_image_to_sandbox.gif)

**使用说明**

1. rawfile路径下存有一张图片IMG_4558.JPG。

2. 设备连接上网络。

3. 点击"保存Rawfile图片"，前端通过调用Native侧暴露的saveImageOfRawfileCallback接口将rawfile中的图片IMG_4558.JPG保存到应用沙箱中并返回沙箱路径到前端进行显示；点击“保存网络图片”，前端通过调用Native侧暴露的saveImageOfInternetCallback接口将网络图片保存到应用沙箱中并返回沙箱路径到前端进行显示。

### 工程结构&模块类型

```
│  ├──entry/src/main/cpp                      // C++ 代码区
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

### 模块依赖

本实例依赖开源库libcurl。

### 相关权限

网络访问权限：ohos.permission.INTERNET。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。
2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。
