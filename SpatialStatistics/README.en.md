# System Storage Statistics

### Overview

This sample shows how to use APIs for obtaining the storage information of an app and a file system.

1. App storage statistics: provides APIs for obtaining storage space information, including the space of built-in and plug-in memory cards, space occupied by different types of data, and space of app data.
2. File system storage statistics: provides APIs for obtaining storage information of a file system, including the total size and free size of a file system, in bytes.

### Preview

![](screenshots/device/SpatialStatistics_EN.gif)

### How to Use

1. On the home page, go to **App Storage Statistics** page.
2. Tap **App Storage Statistics** to display the app storage data.
3. Tap **Back** in the upper left corner to return to the home page.
4. On the home page, go to **File System Storage Statistics** page.
5. Tap **File System Storage Statistics** to display the storage data of the file system.

## Project Directory

```
├──entry/src/main/ets                        // Code
│  ├──constants
│  │  └──Constants.ets                        // Common constants
│  ├──entryability
│  │  └──EntryAbility.ets                     // Entry ability
│  ├──pages
│  │  ├──AppSpatialPage.ets                   // App Storage Statistics page
│  │  ├──FileSpacePage.ets                    // File System Storage Statistics page
│  │  └──Home.ets                             // Home page
│  ├──utils
│  │  ├──Logger.ets                           // Log file
│  ├──view
│  │  └──SpaceInfo.ets                        // Widget child component
│  └──viewmodel
│     └──CommonViewModel.ets                  // Common methods
└──entry/src/main/resources                   // Static resources of the app
```

### Required Permissions

N/A

### Constraints

1. The sample is only supported on Huawei phones with standard systems.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.