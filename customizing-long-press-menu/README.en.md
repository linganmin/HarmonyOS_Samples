# Customizing the Touch and Hold Menu on the Web Page

### Overview

This sample describes how to bind a custom menu to a tappable element (hyperlink or image) on the web page.

### Preview

![](./screenshots/device/web.gif)

##### How to Use

Touch and hold an image or link on a web page to display the customized menu and create customized operations, such as copying an image, opening a link using a browser, and copying a link.

### Project Directory

```
├──entry/src/main/ets/
│  ├──common
│  │  └──CommonConstants.ets         // Common constant class
│  │  └──Utils.ets                   // Utils functions
│  ├──entryability
│  │  └──EntryAbility.ets            // Entry point class
│  └──pages                  
│     └──Index.ets                   // Home page
└──entry/src/main/resources          // Static resources of the app
```

### How to Implement

1. Create a web component, import the sample HTML file, and bind the pop-up menu component.

2. Invoke the **onContextMenuShow** function of the web component to obtain the pop-up menu information of the current page element, such as the location information, current link, whether media elements such as images exist, and event source.

3. Create a customized menu. You can obtain the information and events that trigger the menu element from the **onContextMenuShow** event and dynamically create a customized pop-up menu based on the information and events.

### Required Permissions

N/A

### Constraints

1. The sample app is supported only on Huawei phones running the standard system.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio HarmonyOS 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.
