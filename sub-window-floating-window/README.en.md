# Subwindow-based Floating Window

### Overview
This sample shows how to use a subwindow to implement a floating window and use the PiP feature to implement a small video window.

### Preview

|                         Home page                          |
|:----------------------------------------------------------:|
| <img src="screenshots/devices/phone.en.gif" width="300px"> |

### How to Use

1. Touch the **Subwindow - floating window** button to go to the subwindow functional page.
2. Touch the four buttons to view the four different operations in the subwindow.
3. Touch the **PiP - small video window** to go to the PiP functional page.
4. Touch **enable PiP** to create a small video window.

### Project Directory

```
├──entry/src/main/ets/
│  ├──constants                         
│  │  └──CommonConstants.ets                 // Common constants
│  ├──entryability
│  │  └──EntryAbility.ets                    // Entry ability
│  ├──pages
│  │  ├──Index.ets                           // Home page
│  │  ├──MiniWindowPage.ets                  // Page for showing or hiding the subwindow
│  │  ├──NavigationRedirectPage.ets          // Page for redirection from the subwindow to the PiP window through the Navigation component
│  │  ├──ResizeWindowPage.ets                // Page for resizing the subwindow
│  │  ├──RouterRedirect.ets                  // Page for redirection from the subwindow to the home page through the router
│  │  └──RouterRedirectPage.ets              // Redirection back to the home page through the router
│  ├──utils
│  │  └──Logger.ets                          // Log utility
│  ├──view
│  │  ├──MiniWindowComponent.ets             // Custom components used to create, show, and hide the subwindow
│  │  ├──NavigationRedirectComponent.ets     // Custom components used to redirect from the subwindow to the PiP window through the Navigation component
│  │  ├──PipWindowComponent.ets              // Custom components for implementing the PiP feature
│  │  ├──ResizeWindowComponent.ets           // Custom components used to resize the subwindow
│  │  └──SubWindowComponentRouter.ets        // Custom components used to display routes in the floating window
│  └──viewmodel
│     ├──AVPlayerDemo.ets                    // Video playback control class
│     └──WindowPosition.ets                  // Subwindow position
└──entry/src/main/resources                  // Static resources

```

### Required Permissions

N/A

### Dependencies

N/A

### Constraints

1. The sample app is supported only on Huawei phones running the standard system.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.
