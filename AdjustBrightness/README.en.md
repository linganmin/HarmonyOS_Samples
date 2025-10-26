# Page Brightness Adjustment

## Overview

In typical scenarios such as video playback and payment code, you need to set different screen brightness levels for different pages of an app. Users can also customize and adjust the screen brightness, which will automatically revert to the system brightness upon page navigation.

This sample uses [setWindowBrightness](https://developer.huawei.com/consumer/en/doc/harmonyos-references/js-apis-window#setwindowbrightness9) and [setWindowKeepScreenOn](https://developer.huawei.com/consumer/en/doc/harmonyos-references/js-apis-window#setwindowkeepscreenon9) provided by the window capability to implement the two typical scenarios, helping you understand and master the development process and details of page brightness setting. If you need to provide the function of adjusting the page brightness, you can directly reuse the sample code.



## Preview

<img src="screenshots/device/SetBrightness.en.gif" width=320>

[Note] The brightness change cannot be recorded during screen recording. The actual implementation is subject to the real device.



## How to Use

1. Touch the Video Playback button to enter the video playback page. Touch the Play button, and swipe up or down on the left side of the video to adjust the screen brightness. The video will be automatically played cyclically. The screen will not turn off and will remain steady on during playback. Pause the video and keep the screen still. The screen will automatically turn off based on the screen-off time set in the system.

2. Tap the Payment Code button. The payment code page is displayed, and the screen brightness is automatically turned up.

3. Return to the home page from the video playback page or payment code page. The screen brightness is restored to the preset value.

4. After adjusting the brightness of the video playback page, return to the home page, and access the video playback page again. The brightness of the video playback page is restored to the adjusted brightness.



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
│  ├──model
│  │  ├──CommentModel.ets               // Video comment data structure model
│  │  └──SystemAreaModel.ets            // Model that caches the heights of the system status bar and navigation bar
│  ├──pages
│  │  ├──Index.ets                      // Home page
│  │  ├──PayCodePage.ets                // Payment code page structure
│  │  └──VideoPage.ets                  // Video playback page structure
│  ├──util
│  │  └──BrightnessUtil.ets             // Brightness adjustment utility
│  ├──view
│  │  ├──PayCodeView.ets                // View of the payment code page
│  │  ├──VideoCommentView.ets           // Video comment view
│  │  └──VideoView.ets                  // Video playback view
│  └──viewmodel
│     ├──BrightnessViewModel.ets        // Brightness adjustment viewModel
│     └──CommentViewModel.ets           // Video comment viewModel
└──entry/src/main/resources             // App resource directory
```



## How to Implement

1. Adjust the brightness of the video playback page: Touch the **Slider** component. **Slider** calls back the sliding progress [0-1] and calls **@ohos.window.setWindowBrightness** to set the screen brightness.[VideoView.ets](entry/src/main/ets/view/VideoView.ets)

2. Turn up the brightness of the video playback page: Use the **Video** component to set **@ohos.window.setWindowKeepScreenOn** in the **onStart** and **onPause** callbacks to determine whether the screen is always on.[VideoView.ets](entry/src/main/ets/view/VideoView.ets)

3. Turn up the payment code page: Access the page and call **@ohos.window.setWindowBrightness(1)**.[BrightnessViewModel](entry/src/main/ets/viewmodel/BrightnessViewModel.ets)

4. Return to the home screen and call **@ohos.window.setWindowBrightness(-1)** to restore the default brightness.[BrightnessViewModel](entry/src/main/ets/viewmodel/BrightnessViewModel.ets)



## Permissions

N/A



## Constraints

* The sample is only supported on Huawei phones with standard systems.

* The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

* The DevEco Studio version must be DevEco Studio HarmonyOS 5.0.5 Release or later.

* The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.