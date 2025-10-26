# Launching the Atomic Service in an Embedded Manner

### Overview

This sample shows how to use **FullScreenLaunchComponent** to launch the atomic service in an embedded manner.

If the invoked app (the one being launched) grants the invoker the authorization to run the atomic service in an embedded manner, the invoker can operate the atomic service in full-screen embedded mode. If authorization is not provided, the invoker will launch the atomic service in a pop-up manner.

### Preview

![phone.en.gif](screenshots/device/phone.en.gif)

### Project Directory

```
├──entry/src/main/ets/                         
│  ├──entryability
│  │  └──EntryAbility.ets                           // Entry ability
│  └──pages
│     └──mainPage.ets                               // Home page                                                  
└──entry/src/main/resource                          // Static resources of the app
```

### How to Implement

Use **FullScreenLaunchComponent** to launch the atomic service in an embedded manner.

### Required Permissions

N/A

### How to Use

1. Install and open atomic service on the phone and foldable device, and enable the atomic service control exemption in **Developer options**.
2. Tap an icon on the page to start the mapping authorized atomic service in a full-screen embedded manner.
3. Tap an icon on the page to start the mapping unauthorized atomic service in a pop-up manner.

### Constraints

1. The sample app is supported only on Huawei phones running the standard system.
2. The HarmonyOS version must be HarmonyOS 5.0.0 Release or later.
3. The DevEco Studio version must be DevEco Studio 5.0.0 Release or later.
4. The HarmonyOS SDK version must be HarmonyOS 5.0.0 Release or later.
