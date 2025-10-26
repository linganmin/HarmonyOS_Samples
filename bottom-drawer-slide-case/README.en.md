# Bottom Drawer Sliding Effect

### Overview

This sample demonstrates the sliding effect of a bottom drawer, which is implemented using the **List** component. It also displays a page in immersive (full screen) mode and a dragging background map.

### Preview

![](screenshots/device/BottomDrawerSlideCase_EN.gif)

### How to Use

Slide up the list at the bottom. Tiered drawer-style sliding is supported based on the distance slid.

### How to Implement

1. In this sample, the RelativeContainer and Stack layouts are used to place a scrollable list at the bottom of the page and always display the top title bar on the page even when the list is scrolled to the top.
2. The **onTouch** attribute of the **List** component is used to capture the vertical coordinates when the finger is pressed down and when it is left the screen, so as to determine whether the slide direction is upward or downward.
3. Change the height of the **List** component based on the distance slid.
4. When the finger slide ends and leaves the screen, assign an appropriate height to the **List** component by determining the range that the height falls into at that moment.

## Project Directory

```
├──entry/src/main/ets                        // Core code
│  ├──constants
│  │  └──CommonConstants.ets                   // Common constants
│  ├──entryability
│  │  └──EntryAbility.ets       
│  ├──model
│  │  └──CommonModel.ets                      // Common entity class      
│  ├──pages
│  │  └──BottomDrawerSlideCase.ets            // Home page    
│  ├──utils
│  │  ├──ArrayUtil.ets                        // Array utility class
│  │  ├──GlobalContext.ets                    // Variable utility class
│  │  ├──Logger.ets                           // Log utility
│  │  ├──SettingItem.ets                      // Image entity class
│  │  └──WindowModel.ets                      // Window management
│  └──view
│     └──ComComponent.ets                     // Common components
└──entry/src/main/resources                   // Static resources
```


### Required Permissions

N/A

### Constraints

1. The sample is only supported on Huawei phones with standard systems.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.
