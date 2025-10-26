# Redirecting to A Details Screen Based on the Deferred Link Function

## Overview

This sample code shows how a target app obtains the deferred link in the caller app and redirects to a details screen to enhance user experience and link conversion rate.

1. Configure **skills** of the deferred link in the **module.json5** file of the demo app.

2. Call the **deferredLink.popDeferredLink()** API to obtain the deferred link.

## Preview

|           **Main screen**            |
| :----------------------------------: |
| ![](./screenshots/device/sample.gif) |


## Configuration and Usage

### Configuration Procedure

1. [Create a project](https://developer.huawei.com/consumer/en/doc/app/agc-help-create-project-0000002242804048). Under the project, [create an app](https://developer.huawei.com/consumer/en/doc/app/agc-help-create-app-0000002247955506).
2. Open the demo app and set **bundleName** in the **app.json5** file to the app package name configured in [AppGallery Connect](https://developer.huawei.com/consumer/en/service/josp/agc/index.html).
3. Create a signature through [manual signing](https://developer.huawei.com/consumer/en/doc/harmonyos-guides/ide-signing#section297715173233) and replace the **signingConfigs** content in the **build-profile.json5** file in the demo project.
4. Enable App Linking on [AppGallery Connect](https://developer.huawei.com/consumer/en/service/josp/agc/index.html) and configure the website domain name. For details, please refer to [here](https://developer.huawei.com/consumer/en/doc/harmonyos-guides/applinking-preparations).
5. Configure **skills** in the **module.json5** file of the app. For details, please refer to the following figure:

![](./screenshots/setting/module.png)

### How to Use

1. Install **AppLinkingSampleOriginal** on the phone and tap a button on the screen to trigger the link.
2. Install **AppLinkingSampleDestination** and open the app for the first time to trigger the deferred link function and redirect to the details screen.


## Project Directory

```
├──entry/src/main/ets                         // Code area
│  ├──entryability
│  │  └──EntryAbility.ets                     // Entry point class
│  ├──pages                                   // Directory for storing app UI files
│  │  ├──Index.ets                            // Main screen file
│  │  └──Page1.ets                            // Details screen 1
│  └──constants                               // Directory for storing UI constants
│     └──Constants.ets                        // Constant file
└──entry/src/main/resources                   // App resource directory
```

## How to Implement

Call the **deferredLink.popDeferredLink()** API to obtain the deferred link supported by App Linking to redirect to a details screen.

**References**

1. [entry\src\main\ets\pages\Index.ets](./entry/src/main/ets/pages/Index.ets)

2. [entry\src\main\ets\pages\Page1.ets](./entry/src/main/ets/pages/Page1.ets)



## Required Permissions

N/A

## Restrictions

1. This sample code is supported only on Huawei phones running the standard system.
2. This sample code supports API version 17 or later.
3. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.
4. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.
5. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.
