# Transfer of Data in Multiple Types Across Applications Using Distributed Functions

## Overview

This sample demonstrates how to implement transfer of text and images across applications using distributed data objects and the distributed file system. Specifically, this sample uses distributed data objects to transmit data across devices and triggers application continuation and data transfer by a tap on the Dock bar.

## Preview

![](screenshots/device/ContinuePublish_EN.gif)

## Instructions

1. Go to the app home screen, tap **Add High-Quality Image**. After you select an image, the image is displayed in the horizontal list.
2. Tap the **Title**/**Body** text box to input the corresponding content.
3. Tap "Location" in the lower left corner to select a location. "Location" will be replaced by the selected location.
4. Start the **Publish** app on device A, the **Publish** app icon is added to the Dock bar of device B. When you tap the app continuation (publish) app on device A, the app can be seamlessly continued on device B.

## Project Directory

```
├──entry/src/main/ets                         // Code
│  ├──constants
│  │  ├──BreakpointConstants.ets              // Breakpoint constant class
│  │  └──CommonConstants.ets                  // Common constants
│  ├──entryability
│  │  └──EntryAbility.ets       
│  ├──model
│  │  └──CommonModel.ets                      // Common entity class      
│  ├──pages
│  │  └──Home.ets                             // Homepage      
│  ├──utils
│  │  ├──BreakpointSystem.ets                 // A multi-breakpoint tool class
│  │  ├──FileUtil.ets                         // Image selection utility class
│  │  └──LocationUtil.ets                     // Local location utility class
│  └──view
│     ├──AddPic.ets                           // Add picture module
│     ├──BottomToolbar.ets                    // Bottom tool module
│     ├──EditorComponent.ets                  // Edit input module
│     └──TopArea.ets                          // Top area module
└──entry/src/main/resources                   // App resource directory
```

## Required Permissions

- Apply for the ohos.permission.APPROXIMATELY_LOCATION and ohos.permission.LOCATION permissions to obtain device location information.

## Dependency

N/A

## Constraints

1. The sample is only supported on Huawei phones with standard systems.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.

5. The same HUAWEI ID is logged on both devices.

6. Wi-Fi and Bluetooth must be enabled on both devices. If possible, both devices should be connected to the same LAN for faster data transmission.

7. Application continuation can be triggered only between the same application (UIAbility) of both devices, that is, the application must have been installed on the two devices.
