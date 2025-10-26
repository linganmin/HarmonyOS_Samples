# Implementing Communication Between Native Child Threads and the UI Main Thread

### Overview

This sample introduces how to call back the function of the UI main thread in the native child threads to refresh the UI main thread page. This help you learn how to use thread-safe functions and the libuv library and master the cross-thread calling capabilities on the native side.

### Preview
![](screenshots/device/NativeSub_MainThreadComm_EN.gif)

### How to Use

Tap the corresponding button to invoke the code execution logic to process data (add 30 to the data). The processing result will be displayed on the page.

**Note**

You are advised to use thread-safe functions to call back the function of the UI main thread in the native child threads rather than using the libuv library. If the libuv library is required, use the **uv_async_send** mode instead of the **uv_queue_work** function for inter-thread communication, because this function is used to throw asynchronous tasks. The **execute** callback of asynchronous tasks is scheduled after being submitted to the thread pool. Therefore, the time sequence between submitted tasks is not ensured. **uv_queue_work** can be called only on the loop thread. This prevents multi-threading issues. Try to avoid using **uv_queue_work** as a method for inter-thread communication. That is, thread A obtains the loop of thread B, uses **uv_queue_work** to throw asynchronous tasks, sets the **execute** callback to an empty task, and executes the **complete** callback in thread B. Using this method is inefficient and increases the difficulty in locating faults.

### Project Directory
```
├──entry/src/main/cpp                   // C++ code area
│  ├──types
│  │  └──libentry                       // Exported C++ APIs
│  │     ├──Index.d.ts
│  │     └──oh-package.josn5
│  ├──CMakeLists.txt                    // CMake file
│  └──napi_init.cpp                     // Implementation of native service code
├──entry/src/main/ets                   // ArkTS code area
│  ├──entryability
│  ├──entrybackupability
│  └──pages
│     └──index.ets                      // Home page
└──entry/src/main/resources             // Resource files
```

### How to Implement

1. Thread-safe function mode:
   1. Pass functions from ArkTS side to native side.
   2. Create a thread-safe function in the native main thread, bind the thread to the callback, and split the thread into multiple child threads.
   3. Request and call a thread-safe function in child threads to trigger a callback.
   4. Use the **napi_call_function** API in the callback to call the function passed by ArkTS.
2. libuv library mode:
   1. Pass functions from ArkTS side to native side.
   2. Save the context and function reference in the native main thread.
   3. Declare the loop in the main thread, initialize the async handle, bind the thread to the callback, and split the thread into child threads.
   4. Call the **uv_async_send** API in child threads to trigger the async handle callback in the main thread.
   5. In the async handle callback, use the saved context and function reference to call the function passed by ArkTS through the **napi_call_function** API.

### Permissions

**N/A**

### References

**N/A**

### Constraints

1. The sample is only supported on Huawei phones with standard systems.
2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.
3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.
4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.