# Video Landscape/Portrait Mode Switching

### Overview

This sample implements the function of automatically switching between landscape and portrait modes during video playback.

### Preview

| Portrait                                                    | Landscape                                              |
|-------------------------------------------------------------|--------------------------------------------------------|
| <img src="screenshots/devices/portrait.en.png" width='320'> | ![landscape.en.png](screenshots/devices/landscape.png) |

### How to Use

1. Pull down the status bar to disable rotation lock. Open the app, go to the video playback details screen, and rotate your phone to landscape orientation or touch the icon in the lower right corner of the video. The video is played in full screen.

2. During full-screen video playback, touch the back icon in the upper left corner or change your phone from landscape to portrait. The video exits full screen mode.

3. During full-screen video playback, touch the lock icon in the middle of the left screen to lock rotation. The video playback is locked in place and does not rotate when you rotate your screen. When you touch the unlock icon to disable rotation lock, the video will rotate with the screen.

### Project Directory

```
├──entry/src/main/ets/
│  ├──entryability
│  │  └──EntryAbility.ets          // Entry ability lifecycle callbacks
│  ├──entrybackupability                   
│  │  └──EntryBackupAbility.ets    // Application data backup and restore class 
│  ├──pages
│  │  └──VideoDetail.ets           // Video details page
│  ├──util 
│  │  ├──AVPlayerUtil.ets          // Video playback utility class    
│  │  └──Logger.ets                // Log utility
│  │──viewmodel                  
│  │  ├──CommentModel.ets          // Comment model
│  │  └──RelatedModel.ets          // Related model
│  └──views                 
│     ├──BottomView.ets            // Bottom operation bar components
│     ├──CommentsView.ets          // Comment list components
│     ├──RelatedListView.ets       // Related list components
│     └──VideoPlayView.ets         // Video playback component
└──entry/src/main/resources        // Static resources
```

### How to Implement

* The video playback feature is encapsulated in **AVPlayerUtil.ets**. For details about the source code, see [AVPlayerUtil.ets](entry/src/main/ets/utils/AVPlayerUtil.ets).

* For details about the source code for landscape/portrait mode, see [VideoPlayView.ets](entry/src/main/ets/views/VideoPlayView.ets).
  The [https://developer.huawei.com/consumer/en/doc/harmonyos-references/js-apis-window#setpreferredorientation9-1) method of the **Window** object is used for switching between landscape and portrait modes.
  

### Required Permissions

N/A

### Dependencies

N/A

### Constraints

1. The sample is only supported on Huawei phones with standard systems.
2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.
3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.
4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.
