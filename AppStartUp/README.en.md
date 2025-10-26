# Initializing a Startup Task Based on AppStartup

## Overview

This sample describes how to use the system capabilities [StartupConfigEntry](https://developer.huawei.com/consumer/en/doc/harmonyos-references/js-apis-app-appstartup-startupconfig), [StartupTask](https://developer.huawei.com/consumer/en/doc/harmonyos-references/js-apis-app-appstartup-startuptask), and [startupManager](https://developer.huawei.com/consumer/en/doc/harmonyos-references/js-apis-app-appstartup-startupmanager) to implement initialization tasks synchronously or asynchronously when an app is started, which accelerates the app startup. This sample helps you master the ArkUI startup framework AppStartup, making the code for executing startup tasks simpler, clearer, and easier to maintain.

## Preview
<img src="screenshots/device/startWork.en.gif" width=320>

## How to Use

1. Start the app. On the app home page, search for the log "AutoMode Task execute complete", which indicates that the automatic initialization task is complete.
2. Tap Automatic Mode to view the result of the automatic initialization task.
3. Tap Manual Mode to execute and manually initialize the task. You can search for the log "Manual Task execute success".

## Project Directory

```
├──entry/src/main/ets
│  ├──common
│  │  ├──Constants.ets                  // Common constants
│  │  └──GlobalBuilderContext.ets       // Global @Builder
│  ├──entryability
│  │  └──EntryAbility.ets               // Entry ability
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets         // Data conversion and migration
│  ├──pages
│  │  ├──AutoModePage.ets               // Automatic mode page
│  │  ├──Index.ets                      // Home page
│  │  └──ManualModePage.ets             // Manual mode page
│  ├──startup
│  │  ├──FileTask.ets                   // File read and write task
│  │  ├──ImageKnifeTask.ets             // Initialization task of image framework Imageknife
│  │  ├──KvManagerUtilTask.ets          // Initialization task of the KV store
│  │  ├──KVStoreTask.ets                // Task of writing dirty data to the KV store
│  │  ├──RdbStoreTask.ets               // Initialization task of the RDB store
│  │  ├──ResourceManagerTask.ets        // Resource initialization task
│  │  └──StartupConfig.ets              // Configuration capability of the startup framework
│  ├──util
│  │  └──SingleKVStore.ets              // Database operation utility
│  └──view
│     ├──AutoModeView.ets               // Auto mode view
│     └──ManualModeView.ets             // Manual mode view
└──entry/src/main/resources             // App resource directory
```

## How to Implement

1. Define the configuration file of the startup framework [startup_config.json](entry/src/main/resources/base/profile/startup_config.json) and reference it in [module.json](entry/src/main/module.json5).
2. Set the startup parameters [StartupConfig.ets](entry/src/main/ets/startup/StartupConfig.ets).
3. Add a startup task [startup task](entry/src/main/ets/startup) for each component to be initialized.
4. Run a startup task [startupManager.run](entry/src/main/ets/pages/Index.ets) in manual mode.

## Permissions

N/A

## Constraints

* The sample is only supported on Huawei phones with standard systems.
* The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.
* The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.
* The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.
