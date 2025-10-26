# Music Playback on Smart Watches

## Overview

This sample demonstrates the implementation of a music playback application on a smart watch, aiming to help developers gain a clear understanding of the layout modes and unique features involved in developing applications for wearable devices.

## Preview

<img src='./screenshots/device/img.png' width="320">

## How to Use

1. Install and launch the application.
2. Tap the play button to start music playback.
3. Tap the pause button to pause the music.
4. Tap the previous button to play the previous track.
5. Tap the next button to play the next track.
6. Touch the favorite button. It is highlighted.
7. Tap the playback mode to switch between different playback modes. (Note: The playback mode function is not implemented)

## Project Directory

```
├──entry/src/main/ets/ 
│  ├──common 
│  │  └──Constants.ets                          // Constant class. 
│  ├──entryability 
│  │  └──EntryAbility.ets                       // Entry point class. 
│  ├──entrybackupability 
│  │  └──EntryBackupAbility.ets                 // Data migration class. 
│  ├──model 
│  │  └──mediaData.ets                          // Media data class. 
│  ├──pages 
│  │  └──Index.ets                              // Page. 
│  ├──utils 
│  │  ├──GlobalContextUtils.ets                 // Cache context. 
│  │  ├──Logger.ets                             // Log utility. 
│  │  └──MediaPlayerUtils.ets                   // Music playback control class. 
│  ├──view 
│  │  └──MusicHomeView.ets                      // UI. 
│  └──viewmodel 
│     └──ProviderManager.ets                    // AVSession provider status management. 
└───entry/src/main/resources                    // App resource directory.
```

## How to Implement

1. Set **deviceTypes** to **wearable** in [module.json](entry/src/main/module.json5).
2. Apply [borderRadius：“50%”](entry/src/main/ets/pages/Index.ets) to adapt the page to the round display.
3. Use [AVPlayer](entry/src/main/ets/utils/MediaPlayerUtils.ets) for music playback control.
4. Use [AVSession](entry/src/main/ets/viewmodel/ProviderManager.ets) for music playback in the background.

## Required Permissions

Music playback in the background: ohos.permission.KEEP_BACKGROUND_RUNNING

## Constraints

1. This sample is only supported on Huawei smart wearables running standard systems.
2. The HarmonyOS version must be HarmonyOS 5.1.0 Release or later.
3. The DevEco Studio version must be DevEco Studio 5.1.0 Release or later.
4. The HarmonyOS SDK version must be HarmonyOS 5.1.0 Release SDK or later.
