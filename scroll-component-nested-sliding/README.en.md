# Scroll Nested Sliding

### Overview

In this sample, the **nestedScroll** attribute is used to implement the function of sliding up the Scroll container to the Tabs subcomponent. The Tabs subcomponent is mounted to the top, and the content in the List subcomponent can continue to slide.

### Preview

![](screenshots/device/ceiling_EN.gif)

Instructions:
1. Start the app and slide up. The tabs component will be mounted to the top.
2. Continue to slide up. The content of the List component continues to scroll up.
3. Tap a tab to switch between different contents.

### Project Directory

```
├──entry/src/main/ets/
│  ├──common/constant
│  │  └──CommonConstants.ets            // Common constant class
│  ├──entryability
│  │  └──EntryAbility.ets               // Entry point class
│  ├──page                  
│  │  └──Index.ets                      // Home page
│  └──viewmodel                  
│     └──InitData.ets                   // Data
└──entry/src/main/resource              // Static resources
```

### How to Implement

* Add the **nestedScroll** attribute to the **List** component and set the **scrollForward** and **scrollBackward** parameters to **PARENT_FIRST** and **SELF_FIRST** respectively. In this way, the parent component scrolls first when scrolling to the end, and the parent component scrolls first when scrolling to the start. For details about the source code, see [index.ets](https://codehub-y.huawei.com/Codelab_Team/HarmonyOS_Codelab/files?ref=master&filePath=20240330%2FScrollComponentNestedSliding%2Fentry%2Fsrc%2Fmain%2Fets%2Fpages%2FIndex.ets&isFile=true).


### Required Permissions
N/A

### Dependencies
N/A

### Constraints

1. The sample app is supported only on Huawei phones running the standard system.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio HarmonyOS 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.
