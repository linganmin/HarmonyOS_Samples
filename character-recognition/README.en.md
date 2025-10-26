# Special Text Recognition

### Overview

This sample describes how to use the **enableDataDetector** attribute of the Text component to recognize special characters.

### Preview

![](./screenshots/device/word_en.gif)

##### How to Use

Go to the page, input a message with special text, and send the message. The text in the chat list is automatically identified and marked with special text. Currently, the following types of text can be recognized: phone number, link, email address, and address. Addresses need specific address information to be identified. The recognized text will turn blue and be underlined.

### Project Directory

```
├──entry/src/main/ets/
│  ├──common
│  │  └──CommonConstants.ets         // Common constant class
│  ├──entryability
│  │  └──EntryAbility.ets            // Entry point class
│  ├──pages                  
│  │  └──Index.ets                   // Home page
│  └──viewmodel
│     ├──BasicDataSource.ets         // Data source
│     └──MessageModel.ets            // Message model
└──entry/src/main/resources          // Static resources of the app
```

### How to Implement

1. Use the **enableDataDetector** attribute of the Text component to recognize specific text.

2. Use the **dataDetectorConfig** attribute of the Text component to set the types that can be recognized.

### Required Permissions

N/A

### Constraints

1. The sample app is supported only on Huawei phones running the standard system.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio HarmonyOS 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.
