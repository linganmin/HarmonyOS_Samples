# Video Player

### Overview

This sample demonstrates how to develop a video app using the AVPlayer and AVSession capabilities provided by HarmonyOS.

### Preview


<img src="screenshots/videoPlayer_EN.gif" width='320'>

### How to Use

1. After the app is launched, the video playlist is displayed and the first video is automatically played.

2. Touch the button on the screen to switch between portrait and landscape modes.

3. Swipe up or down to switch between videos, and view historical playback records.

4. Drag the progress bar or swipe in full-screen mode to adjust the playback progress.

5. When the app is switched to the background, the playback can continue. You can control the playback in the Media Controller.


### Project Directory

```
├──entry/src/main/ets                              
│  ├──entryability  
│  │  └──EntryAbility.ets               // Entry ability
│  ├──model
│  │  ├──BasicDataSource.ets            // Lazy loading data sources
│  │  └──DataModel.ets                  // Data classes
│  ├──pages                                     
│  │  └──IndexPage.ets                  // Home page
│  ├──utils                                     
│  │  ├──WindowUtil.ets                 // Window utility class
│  │  └──BreakpointSystem.ets           // Breakpoint utility class
│  └──view
│     ├──AVPlayer.ets                   // Video component
│     ├──VideoList.ets                  // Video list on the home page
│     ├──VideoSide.ets                  // Video swiper components
│     └──VideoDetails.ets               // Video details components
├──entry/src/main/resources             // Static resources
└──MediaService/src/main/ets
│  ├──common  
│  │  └──CommonConstants.ets            // Common constants
│  ├──controller
│  │  ├──AvPlayerController.ets         // Video playback control
│  │  ├──AvSessionController.ets        // AVSession control
│  │  └──AvSessionControllerPCode.ets   // AVSession control pseudocode
│  ├──model
│  │  └──VideoData.ets                  // Video data class
│  └──utils
│      ├──BackgroundTaskManager.etss    // Background playback
│      ├──CommUtils.ets                 // Utility class
│      └──Logger.ets                    // Image pixel processing class
└──MediaService/src/main/resources      // Log utility
```

### Required Permissions

1. **ohos.permission.KEEP_BACKGROUND_RUNNING**: allows an app to run in the background.

2. **ohos.permission.INTERNET**: allows an app to access the Internet.

### Constraints

1. The sample is only supported on Huawei phones with standard systems.

2. The HarmonyOS version must be HarmonyOS 6.0.0 Release or later.

3. The DevEco Studio version must be DevEco Studio 6.0.0 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 6.0.0 Release SDK or later.

### Download

To download this project separately, execute the following command:
```
git init
git config core.sparsecheckout true
echo VideoPlayerSample/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```
