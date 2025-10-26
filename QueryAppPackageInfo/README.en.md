# Querying App Package Information

### Overview

This sample describes how to query and display app package information (such as the app icon and name) on the ArkTs and native sides as well as app package signature information on the ArkTS side. Based on this sample, you can master the capabilities of managing app packages.

### Preview
![](screenshots/device/QueryAppPackageInfo_EN.gif)

### How to Use

On the home page, touch the corresponding button to access the desired page. Each page contains an information display section and a button. When you touch the button, an interface is invoked to display related information.

#### Note

The Emulator does not contain app package signature information. Therefore, if you run code in the Emulator, the queried signature information may be empty.

### Project Directory
```
├──entry/src/main/cpp                   // C++ code area
│  ├──types
│  │  └──libentry                       // Exported C++ APIs
│  │     ├──Index.d.ts
│  │     └──oh-package.json5
│  ├──CMakeLists.txt                    // CMake file
│  └──napi_init.cpp                     // Code area on the native side
├──entry/src/main/ets                   // Code area on the ArkTS side
│  ├──common        
│  │  └──CommonConstants.ets            // Constant definition file
│  ├──entryability
│  │  └──EntryAbility.ets
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  ├──model
│  │  ├──AppInfoData.ets                // Initial data of the app package information
│  │  ├──AppInfoItem.ets                // Common app package information
│  │  ├──AppSignatureInfoData.ets       // Initial data of the app package signature information
│  │  └──NativeAppInfoData.ets          // Initial data of the app package information on the native side
│  ├──pages
│  │  ├──GetAppInfo.ets                 // Page for querying app package information on the ArkTS side
│  │  ├──GetSignatureInfo.ets           // Page for querying app package signature information on the ArkTS side
│  │  ├──MainPages.ets                  // Main pages
│  │  └──NativeGetAppInfo.ets           // Page for querying app package information on the native side
│  └──view
│     └──AppInfoComponent.ets           // List component
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