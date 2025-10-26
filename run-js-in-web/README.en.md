# JS Injection and Execution

### Overview

Based on HTML5 games, this sample uses the ArkUI component **\<button>** to implement basic game control. This sample demonstrates the JS injection and execution capabilities of the WebView component and the communication capabilities between native applications and HTML5.

### Preview

| Home page                        |
|----------------------------------|
| ![](screenshots/device/main.png) |

How to Use

1. Connect the device to the hotspot to access the Internet.

2. Open the app and control the game using the buttons on the screen.

### Project Directory
```
├──entry/src/main/ets
│  ├──entryability
│  │  └──EntryAbility.ets                // Dialog box component
│  ├──model
│  │  └──Logger.ets                      // Logger
│  └──pages
│     └──Index.ets                       // Home page
└──entry/src/main/resources              // Resources
```

### How to Implement

* This sample consists of one module.
  * Use buttons to implement basic control on games, use the **WebViewController** APIs to control behaviors of the **Web** components, and use the WebView to inject JS and execution capabilities.
  * Source code: [EntryAbility.ets](entry/src/main/ets/entryability/EntryAbility.ets), [Index.ets](entry/src/main/ets/pages/Index.ets)
  * API reference: @ohos.window, @ohos.web.webview

### Required Permissions

Internet access permission: ohos.permission.INTERNET

### Dependency

N/A

### Constraints

1. The sample app is supported only on Huawei phones running the standard system.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.
