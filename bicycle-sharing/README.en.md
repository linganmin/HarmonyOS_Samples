# Bike Sharing

## Overview

This sample implements functions such as QR code scanning, locating bikes on a map, and live view notification. It uses capabilities of Scan Kit, Map Kit, and Live View Kit. However, direct access via QR code scanning is not supported at present.

## Preview
![Preview](screenshots/riding.en.gif)

## How to Use
1. With this app, you can locate bikes, scan QR codes to unlock bikes, and receive live view notifications.
2. When you touch the **Unlock** button, a live view is displayed.<br>
3. When you touch the **Return bike** button, the live view is updated.<br>
4. Touch the **Pay now** button to finish the process.

## Project Directory
```
├──ets
│  ├──constants
│  │  └──CyclingConstants.ets        // Common constants
│  ├──entryability  
│  │  ├──EntryAbility.ets
│  │  └──LiveViewLockScreenExtAbility.ets  // ExtensionAbility of the immersive live view        
│  ├──liveview  
│  │  ├──LiveNotification.ets       // Live view notification class
│  │  ├──LiveViewContext.ets        // Live view content class
│  │  ├──LiveViewController.ets     // Live video control class
│  │  ├──LiveViewDataBuilder.ets    // Live view data construction class
│  │  ├──LiveViewEnvironment.ets    // Live view environment class
│  │  ├──TextCapsuleBuilder.ets     // Text capsule class
│  │  └──TextLayoutBuilder.ets      // Text extension area class
│  ├──pages  
│  │  ├──ConfirmUnlock.ets          // Unlock page
│  │  ├──CyclingPage.ets            // Home page
│  │  ├──FindBike.ets               // Locate bikes page
│  │  ├──LiveViewLockScreenPage.ets // Immersive live view page
│  │  ├──Pay.ets                    // Payment page
│  │  ├──PayCompleted.ets           // Payment complete page
│  │  └──Riding.ets                 // Cycling page
│  └──utils
│     ├──Logger.ets                 // Log utility
│     ├──MapUtil.etx                // Map utility class
│     └──ScanUtil.ets               // QR code scanning utility class
└──resources                        // Static resources
```
## How to Implement
1. Map Kit is used to implement map, locating, and route planning.
2. Scan Kit is used to implement QR code scanning.
3. Live View Kit is used to implement the live view.

## Required Permissions
[Live View Kit Preparations](https://developer.huawei.com/consumer/en/doc/harmonyos-guides-V5/liveview-preparations-V5)

[Map Kit Preparations](https://developer.huawei.com/consumer/en/doc/harmonyos-guides-V5/map-config-agc-V5)

Grant the live view push permission and map permission in AppGallery Connect.

- **ohos.permission.LOCATION**: allows an app to obtain the location.
- **ohos.permission.APPROXIMATELY_LOCATION**: allows an app running in the foreground to obtain the precise location.
- **ohos.permission.LOCATION_IN_BACKGROUND**: allows an app running the background to obtain the device location.
- **ohos.permission.INTERNET**: allows an app to access the Internet.
- **ohos.permission.GET_NETWORK_INFO**: allows an app to obtain data network information.
- **ohos.permission.CAMERA**: allows an app to use the camera.

## Constraints
1. The sample is only supported on Huawei phones with standard systems.

2. The HarmonyOS version must be HarmonyOS 5.0.0 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.0 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.0 Release SDK or later.
