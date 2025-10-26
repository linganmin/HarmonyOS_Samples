# Starting the System Camera

### Overview

This sample shows how to start the system camera to take a photo and return it to the app.

### Preview
![image](screenshots/device/mainpage.en.png)

### How to Use

1. Touch the **Photo** button to start the system camera. Take a photo.

2. Touch **OK** to return to the app. The app displays the photo.

### Project Directory
```
├──entry/src/main/ets
│  ├──common
│  │  └──constants
│  │     └──CommonConstants.ets             // Common constants
│  ├──entryability
│  │  └──EntryAbility.ets                   // Entry ability
│  └──pages
│     └──MainPage.ets                       // Main page
└──entry/src/main/resources                 // Static resources
```
### How to Implement

Use **cameraPicker** to start the system camera.

### Required Permissions

N/A

### Dependencies

N/A

### Constraints

1. The sample app is supported only on Huawei phones running the standard system.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.
