# List Nested Sliding

### Overview
This sample uses the **scrollToIndex** method of the **List** component to implement nested sliding of multiple **List** components.

### Preview

|                 Home page                 |
|:-----------------------------------------:|
| ![home](screenshots/devices/phone_en.gif) |

### How to Use

Open the sample app, and slide on the screen.

### Project Directory

```
├──entry/src/main/ets/
│  ├──constants                         
│  │  └──CommonConstants.ets            // Common constants
│  ├──entryability
│  │  └──EntryAbility.ets               // Entry ability
│  ├──pages
│  │  └──Index.ets                      // Home page
│  ├──view
│  │  └──CardItemComponent.ets          // Custom child components
│  └──viewmodel
│     ├──CardItem.ets                   // Card entity class
│     ├──ClassifyModel.ets              // List entity class
│     └──ClassifyViewModel.ets          // Data class
└──entry/src/main/resources             // Static resources

```

### How to Implement

Use the **scrollToIndex** method of the **List** component to implement one list to follow and scroll to the corresponding position when another list is scrolled.

### Required Permissions

N/A

### Dependencies

N/A

### Constraints

1. The sample app is supported only on Huawei phones running the standard system.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.
