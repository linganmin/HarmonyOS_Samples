# App Continuation

### Overview

A distributed video player with a live video playback interface is developed in ArkTS. This sample shows how to use the distributed video player to:

 - Implement seamless video playback transition between devices, selecting the most suitable device to play the video. 
 - Allow bullet comments to be edited and sent from a mobile phone when the video is played on a tablet.

### Preview
![dia_EN.gif](./screenshots/devices/dia.en.gif)

**How to Use**

1. Log in with the same HUAWEI ID on your phone and tablet, and enable Wi-Fi and Bluetooth on both devices. It is recommended that both devices be connected to the same LAN to improve the data transmission speed.
2. Install the distributed video player on both devices.
3. Swipe to browse videos on your phone and start the distributed video player on your tablet.
4. Touch the phone input button on the tablet to invoke the content on the phone. Then, view the video on the tablet.


### Project Directory

```
├──entry/src/main/ets             // Code
│  ├──common
│  │  └──Constants.ets            // Common constants
│  ├──entryability
│  │  └──EntryAbility.ets         // Entry ability
│  ├──inputability
│  │  └──InputAbility.ets         // APIs for editing text on the phone.
│  ├──model
│  │  ├──LiveData.ets             // Data related to live video.
│  │  └──LiveDataModel.ets        // Live video data model.
│  ├──pages
│  │  ├──CommentPage.ets          // Bullet screen 
│  │  ├──InputPage.ets            // Page for editing the comments on the phone
│  │  └──LivePage.ets             // Video playback page
│  └──utils
│     ├──Logger.ets               // Logger
│     └──WindowUtil.ets           // Window utility
└──entry/src/main/resource        // Static resources of the app
```

### How to Implement
1. Request the ohos.permission.DISTRIBUTED_DATASYNC permission for the app.

   Add **ohos.permission.DISTRIBUTED_DATASYNC** to the **requestPermissions** field.

2. Request user authorization through a dialog when the app is launched for the first time. The app can obtain the corresponding permission only after the user manually grants the authorization.

   In the **entry/src/entryability/EntryAbility.ets** file, implement the function in the **EntryAbility** class so that a dialog is displayed to request user authorization when the app is used for the first time.

3. Obtain the device ID of the target device.

4. Set the target component parameters on the initiator, and call **startAbilityForResult()** to start the target UIAbility. 

   **data** in the asynchronous callback is used to receive the information returned by the target UIAbility to the initiator UIAbility after the target UIAbility terminates itself.

5. After the UIAbility mission on the target device is complete, call **terminateSelfWithResult()** to return the data to the initiator UIAbility.

6. The initiator UIAbility receives the information returned by the target UIAbility and processes the information.

### Required Permissions

ohos.permission.DISTRIBUTED_DATASYNC: Allows the application data to be exchanged between devices.

### Constraints

1. The sample app is supported only on Huawei phones, tablets running the standard system.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.
