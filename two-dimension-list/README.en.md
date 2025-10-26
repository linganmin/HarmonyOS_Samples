# 2D List of UI Framework

### Overview

This sample shows how to implement a list that responds to both horizontal and vertical scrolling through nested component scrolling.

### Preview
![running](screenshots/device/list.en.gif)


### Project Directory
```
├──entry/src/main/ets                        // Code
│  ├──common
│  │  ├──CommonConstants.ets                  // Constants
│  ├──entryability
│  │  └──EntryAbility.ets 
│  ├──model
│  │  ├──ListDataSource.ets                  
│  │  ├──MessageList.ets                      // List data
│  │  └──TitleList.ets                        // List title data
│  └──pages
│     └──Index.ets                            // Home page
└──entry/src/main/resources                   // Static resources of the app
```
### How to Implement
Encapsulate multiple custom components into the **Scroll** component, and load list data in lazy loading mode to implement horizontal and vertical scrolling.

### Required Permissions

N/A

### Dependencies

N/A

### Constraints

1. The sample app is supported only on Huawei phones running the standard system.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release or later.
