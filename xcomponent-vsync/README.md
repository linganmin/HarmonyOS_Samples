# 基于XComponent技术实现自定义动画功能

### 介绍
XComponent提供了应用在native侧调用OpenGLES图形接口的能力，本文主要介绍如何配合Vsync事件，完成自定义动画。在这种实现方式下，自定义动画的绘制不在UI主线程中完成，即使主线程卡顿，动画效果也不会受影响。

### 效果演示

![](screenshots/device/XComponentVsync.gif)

### 实现思路
1. CMakeLists文件中增加lib依赖
2. 创建Vsync实例
3. 创建OH_NativeVSync_RequestFrame回调，并在回调中使用egl接口进行绘制

### 高性能知识点

- 一个 Vsync 实例对应一个EventRunner创建的新线程，在这个线程中执行渲染处理，理论上这个线程的运算耗时，只会影响动画帧率，不会影响应用主线程的帧率。
- 其余OpenGLES的绘制方法，与社区的OpenGLES的用法一致。
### 工程结构&模块类型

```
├──entry/src/main
│  ├──cpp                           // C++ 代码区
│  │  ├──common                     // 常量定义文件
│  │  │  ├──native_common.h
│  │  │  └──plugin_common.h         
│  │  ├──manager                    // 生命周期管理模块
│  │  │  ├──plugin_manager.cpp
│  │  │  └──plugin_manager.h
│  │  ├──render                     // 渲染模块
│  │  │  ├──egl_core_shader.cpp
│  │  │  ├──egl_core_shader.h
│  │  │  ├──plugin_render.cpp
│  │  │  └──plugin_render.h
│  │  ├──types
│  │  │  └──libentry                // C++接口导出
│  │  │     ├──index.d.ts                        
│  │  │     └──oh-package.josn5                 
│  │  ├──CMakeLists.txt             // CMake配置文件
│  │  └──napi_init.cpp              // Native模块注册
│  └──ets                           // ets 代码区
│     ├──constants
│     │  └──CommonConstants.ets     // 常量定义文件  
│     ├──entryability
│     │  └──EntryAbility.ets       
│     └──pages
│        └──Index.ets               // 主页界面
└──entry/src/main/resources         // 应用资源目录
```

### 模块依赖

**不涉及**

### 参考资料

1. XComponent。 
2. Vsync。
3. EventRunner。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。
2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。