# Implementing Performance Trace with HiTraceMeter

### Overview

This sample describes how to use HiTraceMeter to implement performance trace in common scenarios, including ArkTS, native, component callback, and custom component lifecycle. This depends on the **hiTraceMeter.startTrace** and **hiTraceMeter.finishTrace** APIs in **@kit.PerformanceAnalysisKit** as well as **OH_HiTrace_StartAsyncTrace** and **OH_HiTrace_FinishAsyncTrace** APIs in **libhitrace_ndk.z.so**. This sample provides performance trace reference for your own service code so that you can determine the time consumption points of your application and improve your application performance.

### Preview
![](screenshots/device/HiTraceMeterPerfTag_EN.gif)

### How to Use

Tap the corresponding button to go to the desired page. On the pages for HiTraceMeter trace on the ArkTS side and HiTraceMeter trace on the native side, tapping the button will execute time-consuming tasks and record the trace time. After the invocation is complete, the result will be displayed in a dialog box. On the page for component callback time trace page, tapping the button will redirect to the specified grid position and record the trace. On the page for lifecycle time trace page, there is a list. A refreshed component will be reused, and the lifecycle time will be recorded in the component reuse callback.

#### Querying Trace Information
1. Using the Profiler of DevEco Studio
   1. Run a project, select an application thread with the Profiler, and create a CPU analysis task to capture data. During the recording, execute the service call logic on the device.
   
      ![img.png](screenshots/device/img1.png)
   2. After the data is loaded, view the tracks. If a trace task exists, you can view the trace details triggered by the current thread in the corresponding track. For example, **ArkTSPerfTag** in the figure corresponds to the name printed by HiTraceMeter in the code (for example, **ArkTSPerfTag** in **hiTraceMeter.startTrace("ArkTSPerfTag", 1)**).
   
      ![img.png](screenshots/device/img2.png)


2. Using command lines

   1. Run a project and run the **hitrace** command to obtain the logs related to the trace task. Run the following commands in DevEco Studio Terminal to capture traces (xxx\xxx indicates the project path):

      PS D:\xxx\xxx> hdc shell

      $ hitrace --trace_begin app

   2. After capturing traces, execute the service call logic on the device, and then run the following commands (xxx indicates the name printed by HiTraceMeter in the code, for example, **ArkTSPerfTag** in **hiTraceMeter.startTrace("ArkTSPerfTag", 1)**):

      $ hitrace --trace_dump |grep xxx

      $ hitrace --trace_finish

   3. Capture result:

      ![img.png](screenshots/device/img3.png)

### Project Directory
```
├──entry/src/main/cpp                   // C++ code area
│  └──types
│     ├──libentry                       // Exported C++ APIs
│     │  ├──Index.d.ts
│     │  └──oh-package.json5
│     ├──CMakeLists.txt                 // CMake file
│     └──napi_init.cpp                  // Service code on the native side
├──entry/src/main/ets                   // Code area on the ArkTS side
│  ├──common
│  │  └──CommonConstants.ets            // Common constants
│  ├──entryability
│  │  └──EntryAbility.ets
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  ├──model
│  │  ├──GridDataSource.ets             // Grid component APIs
│  │  └──ListDataSource.ets             // List component APIs
│  ├──pages
│  │  ├──ArkTSPerfTag.ets                 // Performance trace on the ArkTS side
│  │  ├──ComponentCBPerfTag.ets           // Component callback trace
│  │  ├──LifeCyclePerfTag.ets             // Lifecycle trace page
│  │  ├──MainPages.ets                  // Main pages
│  │  └──NativePerfTag.ets                // Performance trace on the native side
│  └──view
│     ├──ReusableComponent.ets          // Reusable component
│     └──TextComponent.ets              // Text component
└──entry/src/main/resources             // Resources
```

### Permissions

**N/A**

### References

**N/A**

### Constraints

1. The sample is only supported on Huawei phones with standard systems.
2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.
3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.
4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.