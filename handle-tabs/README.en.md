# Adding and Deleting Tab Tags Using the Tab Component

### Overview

This sample describes how to use the tab component to add or delete a tab and mainly applies to scenarios such as browsers.

### Preview

![](./screenshots/phone_en.gif)

### How to Use

1. Touch the add icon to add a tab.
2. Touch the delete icon to delete a tab.

### Project Directory

```
handletabs
│  ├──entryability
│  │  └──EntryAbility.ets
│  ├──model
│  │  └──ConstantsData.ets                       // Data class
│  └──pages
│     ├──Index.ets                               // Page for adding or deleting a tab
│     ├──MenuBar.ets                             // Toolbar
│     └──TabSheetComponent.ets                   // Custom the TabBar component
└────entry/src/main/resources 
```

## How to Implement

1. Set **barHeight** of the Tab component to 0 to hide the tab bar.
2. Use the **@Link** modifier to bidirectionally bind the custom **TabBar** and **Tab** components through **focusIndex** and **tabArray**.
3. When the values of **focusIndex** and **tabArray** are changed in the customized TabBar, the UI of the Tab component is changed based on the data change accordingly.

### Required Permissions
N/A

### Dependencies
N/A

### Constraints

1. The sample app is supported only on Huawei phones running the standard system.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio HarmonyOS 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.
