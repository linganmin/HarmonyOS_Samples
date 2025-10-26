# Application Tracking Based on UIObserver

## Overview

This sample implements common tracking activities based on UIObserver, including click tracking, exposure tracking, and page tracking. It allows you to track app usage by collecting, processing, and sending information for specific user behavior based on service scenarios, including the number of visits, number of visitors, stay duration, number of page views, and bounce rate.

## Preview

![](screenshots/device/ApplicationTrack_EN.gif)

## Project Directory

```
├──entry/src/main/ets                        // Code area
│  ├──entryability
│  │  └──EntryAbility.ets                    // Entry ability lifecycle callbacks
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets              // EntryBackupAbility lifecycle callbacks
│  ├──pages
│  │  ├──ClickPage.ets                       // Click tracking
│  │  ├──HomePage.ets                        // Home page
│  │  ├──NavigationPage.ets                  // Navigation page
│  │  ├──PageOne.ets                         // The first navigation tracking page
│  │  ├──PageTwo.ets                         // The second navigation tracking page
│  │  ├──RouterPageA.ets                     // The first router tracking page
│  │  ├──RouterPageB.ets                     // The second router tracking page
│  │  ├──WaterFlowCard.ets                   // Waterfall card
│  │  └──WaterFlowPage.ets                   // Waterfall exposure tracking page
│  └──viewModel                              // Tracking logic
│     ├──CallBackManager.ets
│     ├──DataResource.ets
│     ├──TrackNode.ets
│     └──WaterFlowDataSource.ets
└──entry/src/main/resources                  // App resource directory
```

## How to Use

1. For details, see [Application Tracking](https://developer.huawei.com/consumer/en/doc/best-practices/bpta-application-track-practice).

## Permissions

- N/A

## Dependencies

- N/A

## Constraints

1. The sample is only supported on Huawei phones with standard systems.
2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.
3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.
4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.