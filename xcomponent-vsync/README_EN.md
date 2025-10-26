
# Customize Animations with XComponent and Vsync

### Overview
This sample describes how to customize animations by using XComponent and Vsync events. XComponent enables applications to call OpenGLES graphics APIs on the native side. In this implementation, the drawing of the customized animation is not completed in the main thread of a UI. Even if the main thread freezes, the animation effect is not affected.

### Effect

![](screenshots/device/XComponentVsync.gif)

### How to Implement
1. Add the **lib** dependency to the **CMakeLists** file.
2. Create a **Vsync** instance.
3. Create the **OH_NativeVSync_RequestFrame** callback and use the EGL API to draw animations in the callback.

### High-Performance Knowledge

- A Vsync instance corresponds to a new thread created by **EventRunner**. Rendering is performed in this thread. Theoretically, the calculation time of this thread affects only the animation frame rate rather than the frame rate of the main thread of the application.
- The drawing methods using other OpenGLES APIs are the same as those of the community OpenGLES APIs.
### Project Directory

```
├──entry/src/main
│  ├──cpp                           // C++ code area
│  │  ├──common                     // Common constants
│  │  │  ├──native_common.h
│  │  │  └──plugin_common.h                
│  │  ├──manager                    // Lifecycle management module
│  │  │  ├──plugin_manager.cpp
│  │  │  └──plugin_manager.h
│  │  ├──render                     // Render module
│  │  │  ├──egl_core_shader.cpp
│  │  │  ├──egl_core_shader.h
│  │  │  ├──plugin_render.cpp
│  │  │  └──plugin_render.h
│  │  ├──types
│  │  │  └──libentry                // C++ APIs
│  │  │     ├──index.d.ts                        
│  │  │     └──oh-package.josn5                 
│  │  ├──CMakeLists.txt             // CMake configuration file
│  │  └──napi_init.cpp              // Native module registration
│  └──ets                           // ETS code area
│     ├──constants
│     │  └──CommonConstants.ets     // Common constants 
│     ├──entryability
│     │  └──EntryAbility.ets       
│     └──pages
│        └──Index.ets               // Home page
└──entry/src/main/resources         // App resources
```

### Dependencies

N/A

### Reference

1. XComponent
2. Vsync
3. EventRunner

### Constraints

1. The sample app is supported only on Huawei phones running the standard system.
2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.
3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.
4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.
