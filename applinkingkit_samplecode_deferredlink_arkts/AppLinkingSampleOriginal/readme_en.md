# Starting A Details Screen in the Target App

## Overview

This sample code shows how a caller app starts a target app that has integrated App Linking Kit, streamlining the link opening process and enhancing user experience.

Call the **context.openLink()** API to open the deferred link.

## Preview

|           **Main screen**            |
| :----------------------------------: |
| ![](./screenshots/device/sample.gif) |

## Configuration and Usage

### Configuration Procedure

Open the caller app, configure [automatic signing](https://developer.huawei.com/consumer/en/doc/harmonyos-guides/ide-signing#section18815157237), and click the run icon.

### How to Use

Run the caller app and tap a button on the screen to trigger the link.

## Project Directory

```
├──entry/src/main/ets                         // Code area
│  ├──common
│  │  └──GlobalContext.ets                    // Global app context class
│  ├──entryability
│  │  └──EntryAbility.ets                     // Entry point class
│  ├──pages                                   // Directory for storing app UI files
│  │  └──Index.ets                            // Main screen file
│  └──constants                               // Directory for storing the constant file
│     └──Constants.ets                        // Constant file
└──entry/src/main/resources                   // App resource directory
```

## How to Implement

Call the **openLink()** API to open the target app that has integrated App Linking Kit.

**Reference**

[entry\src\main\ets\pages\Index.ets](./entry/src/main/ets/pages/Index.ets)

## Required Permissions

N/A

## Restrictions

1. This sample code is supported only on Huawei phones running the standard system.
2. This sample code supports API version 17 or later.
3. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.
4. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.
5. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.
