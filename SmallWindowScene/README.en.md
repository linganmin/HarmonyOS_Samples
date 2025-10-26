# Immersive Browsing Through Scrolling in Horizontal Split-Screen Mode

### Overview

This sample describes how to adapt your app to typical scenarios when your app is used on a bar-type mobile phone in horizontal split-screen mode. You will learn how to use the **List** or **Scroll** component to implement immersive browsing through scrolling, use the **Scroll** component to implement scrolling on a page, use the **Stack** component to implement the short video playback page, and use **constraintSize** to adapt the dialog box.

### Preview

![](./screenshots/phone.en.gif)

### How to Use

1. Open an app and drag it from the bottom navigation bar to the upper left corner to enter the horizontal split-screen mode.
2. The home page supports immersive browsing through scrolling. The title bar on the top and tab bar at the bottom are hidden during scrolling. When scrolling stops, they are gradually restored by using a delay animation.
3. Tap the list item Short Video to access the short video playback page. The side components can be scrolled. When you tap the Share button, the dialog box is popped up and can be scrolled, and its maximum height cannot exceed 90% of the height of its parent component.
4. Return to the home page and tap the list item Image and Text Details to access the page. The image and text details page can be scrolled.

### Project Directory

```
entry/src/main/ets
│  ├──constants
│  │  └──CommonConstants.ets
│  ├──entryability
│  │  └──EntryAbility.ets                        // Entry ability
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  ├──pages
│  │  └──Index.ets                               // Home page
│  ├──utils
│  │  └──WindowUtil.ets                          // Window utility
│  ├──viewmodels
│  │  ├──BlogViewModel.ets                       // Blog model
│  │  └──SideIconViewModel.ets                   // Side button model
│  └──views
│     ├──BlogView.ets                            // Blog view
│     ├──DetailView.ets                          // View for image and text details
│     ├──ShareDialog.ets                         // Video sharing dialog
│     └──ShortVideoView.ets                      // Short video view
└────entry/src/main/resources
```

### Permissions
N/A

### Dependencies
N/A

### Constraints

1. The sample is only supported on Huawei phones with standard systems.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.