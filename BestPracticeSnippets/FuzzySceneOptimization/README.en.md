# Optimizing Image Blur Effect

### Overview

This sample shows motion blur and static blur in the transition with blurred image scenario.

### Preview

|              Motion blur                |               Static blur             |
|----------------------------------------|----------------------------------------|
| <img src="screenshots/devices/motion_blur.gif" width="180"> | <img src="screenshots/devices/static_blur.gif" width="180"> |


### How to Use

1. Tap the **motion blur** button on the parent page to redirect to the child page **MotionBlur**.

2. Tap the **motion blur** button on the child page **MotionBlur** to launch the full-screen modal page with a dynamically blurred image.

3. Tap the **static blur** button on the parent page to redirect to the child page **StaticBlur**.

4. Tap the **static blur** button on the child page **StaticBlur** to display the full-screen modal page with a statically blurred image.

### Project Directory
```
├──entry/src/main/ets
│  ├──entryability
│  │  └──EntryAbility.ets                   // Entry ability lifecycle callbacks
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets             // Entry ability that provides backup and restore capabilities for the application
│  └──pages
│     ├──MainPage.ets                       // View layer - parent page
│     ├──MotionBlur.ets                     // View layer - motion blur page
│     └──StaticBlur.ets                     // View layer - static blur page
└──entry/src/main/resources                 // Static resources
```

### How to Implement

1. To implement motion blur, set the **blur** value of the **Image** component to add the blur effect to the image.
2. To implement static blur, call **createPixelMap** to create the **PixelMap** of an image, call **createEffect** to create a **Filter** instance, and use **blur** in the **Filter** class to add the blur effect to the image.

### Required Permissions

N/A

### Dependencies

N/A

### Constraints

1. This sample is supported only on Huawei phones running the standard system.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.

### Download

To download this project separately, execute the following command:
```
git init
git config core.sparsecheckout true
echo FuzzySceneOptimization/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```
