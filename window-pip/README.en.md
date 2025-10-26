# PiP Effect

## Overview

This sample demonstrates video playback, manual and automatic invocation of Picture-in-Picture (PiP), and video play and pause control in the PiP window. These features are implemented using interfaces provided by @kit.ArkUI and @kit.MediaKit.

## Preview

![](screenshots/devices/WindowPiP_EN.gif)

## How to Use

1. On the home page, touch a video to access the corresponding video playback page.
2. On the video playback page, touch **Enable**. The app starts a PiP window. Touch **Disable**. The PiP window is closed.
3. On the video playback page, enable **Auto PiP**. When you return to the home screen, the app starts a PiP window.
4. The video playback page displays callback information.

## Project Directory

```
├──entry/src/main/ets                        // Core code
│  ├──constants
│  │  └──Constants.ets                       // Constants
│  ├──entryability
│  │  └──EntryAbility.ets       
│  ├──pages
│  │  ├──AVPlayer.ets                        // Video playback
│  │  ├──Index.ets                           // Home page
│  │  └──VideoPlay.ets                       // Video playback page
│  └──utils
│     └──Logger.ets                          // Log utility
└──entry/src/main/resources                  // Static resources
```


## How to Implement

- The sample uses the **Navigation** component to construct the pages. Five clickable videos are placed on the home page. When you touch a video, the corresponding video playback page is displayed.
- The video playback page can be divided into three areas: XComponent on the top, PIP control buttons in the middle, and callback information in the lower part.
- After you touch **Enable**, the app starts a PiP window, and the video is played in the PiP window. When you return to the home screen, the video is still played in the PiP window. After you touch **Disable**, the video is played in the XComponent area, and no PiP window is started when you return to the home screen.
- After you enable **Auto PiP**, the app automatically starts a PiP window when you return to the home screen, and the video is played in the PiP window.
- When a video is displayed in the PiP window, the XComponent area displays the message "The video is being played in PiP mode."
- The callback information shows the status, error cause, and button event and status. For details, see [VideoPlay.ets](entry/src/main/ets/pages/VideoPlay.ets).


## Required Permissions

N/A

## Dependencies

N/A

## Constraints

1. The sample is only supported on Huawei phones with standard systems.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.
