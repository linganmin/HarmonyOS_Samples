# List Item Exchange

### Overview

This sample implements the functions of exchanging and deleting list items.

### Preview

Below shows the preview effects.

![running](screenshots/Devices/image1_EN.gif)


How to Use

1. You can view the page effect in the previewer or on the corresponding device.

### Project Directory

```
├──entry/src/main/ets                             // Code area
│  ├──constants                                  
│  │  ├──CommonConstants.ets                      // Common constants
│  ├──entryability  
│  │  └──EntryAbility.ets 
│  ├──pages                             
│  │  └──Index.ets                                 // Home page
│  ├──utils
│  │  └──Logger.ets                                // Log printing class       
│  └──viewModel
│     ├──AttributeModifier.ets                     // List style class
│     ├──ListExchangeCtrl.ets                      // List exchange control class
│     └──ListInfo.ets                              // List item information class   
└──entry/src/main/resources                        // App resource directory

```

### How to Implement


In this sample, you can determine whether to exchange list items by combining gestures (press and hold, drag, and drag distance), and use the swipeAction attribute of the ListItem component to set the deletion component.



### Required Permissions

N/A

### Dependencies

N/A

### Constraints

1. The sample app is supported only on Huawei phones running the standard system.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release or later.
