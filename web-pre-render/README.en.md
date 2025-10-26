# Displaying Web Pages in an Instant Manner

### Overview

This sample shows how to display the web pages in an instant manner by using pre-rendering.

### Preview
![](screenshots/device/phone_EN.png)

Instructions:
1. Tap the title to open the dialog box and load the web page.

### Project Directory

```
├──entry/src/main/ets/
│  ├──common
│  │  └──Constants.ets                  // Common constant class
│  ├──entryability
│  │  └──EntryAbility.ets               // Entry ability
│  └──pages              
│     └──Index.ets                      // Home page
│     └──WebPage.ets                    // Pre-rendering web page
└──entry/src/main/resources             // Static resources
```

### How to Implement

1. Create a **Web** component.
2. Pre-render the web page in **EntryAbility**, and the dialog box is displayed instantly on the home page.

### Required Permissions
ohos.permission.INTERNET

### Constraints

1. The sample app is only supported on Huawei phones with standard systems.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release or later.
