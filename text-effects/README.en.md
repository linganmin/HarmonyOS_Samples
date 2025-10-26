# Text Effect Collection

### Overview

This sample describes how to implement multiple text effects based on the **Text** component and common attributes.

### Preview

![image](./screenshots/device/text_effects.en.gif)

### How to Use

1. Launch the app and view multiple text effects, including text gradient, lyric scrolling, text reflection, and automatic text scrolling.

### Project Directory

```
├──entry/src/main/ets/
│  ├──constants
│  │  └──Constants.ets                  // Common constants
│  ├──entryability
│  │  └──EntryAbility.ets               // Entry point class
│  ├──page                  
│  │  └──Index.ets                      // Home page
│  └──view
│     ├──TextGradientView.ets           // Text gradient    
│     ├──TextMarqueeView.ets            // Automatic text scrolling
│     ├──TextReflectionView.ets         // Text reflection      
│     └──TextScrollingView.ets          // Lyrics scrolling
└──entry/src/main/resource              // Static resources
```

### How to Implement

1. The text gradient effect is implemented using the **blendMode** and **linearGradient** attributes.
2. The lyric scrolling effect is implemented using the **blendMode** and **linearGradient** attributes, and explicit animation.
3. The text reflection effect is implemented using the **rotate** and **linearGradient** attributes.
4. The automatic text scrolling effect is implemented using the **textOverflow** and **linearGradient** attributes of the **Text** component.

### Required Permissions

N/A

### Constraints

1. The sample is only supported on Huawei phones with standard systems.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.
