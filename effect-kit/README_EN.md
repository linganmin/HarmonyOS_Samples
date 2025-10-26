# Converting the Background Color in Line with the Theme using colorPicker

### Overview

This sample describes how to use the image library and colorPicker in the EffectKit library to pick the color of the target image, use the obtained color as the background gradient color, and use the Swiper component to rotate images.

### Preview

<img src="screenshots/device/effect_kit.png" width=320>

**How to Use**

Go to the page and swipe left or right on the image, or wait for 2 seconds until the image is automatically rotated. The background color automatically changes after the image is switched.

### How to Implement

1. When the **onAnimationStart** event is triggered to switch the animation, obtain the average color value of the image through the image module, and call **ColorPicker** in the EffectKit library to obtain the color value.
2. In addition, the **animateTo** API is called to enable the attribute animation of background color rendering. Enable the immersive status bar on the global UI.
3. Set the background color rendering direction and rendering atmosphere through the **linearGradient** attribute.

### High-Performance Knowledge

N/A

### Project Directory
```
├──entry/src/main/ets                         // ets code
│  ├──constants
│  │  └──CommonConstants.ets                  // Constant definition file 
│  ├──entryability
│  │  └──EntryAbility.ets       
│  └──pages
│     └──Index.ets                            // Home page
└──entry/src/main/resources                   // App resource directory
```

### Module Dependency

N/A

### See Also

N/A

### Constraints

1. The sample is only supported on Huawei phones with standard systems.
2. HarmonyOS: HarmonyOS 5.0.5 Release or later.
3. DevEco Studio: DevEco Studio 5.0.5 Release or later.
4. HarmonyOS SDK: HarmonyOS 5.0.5 Release SDK or later.
