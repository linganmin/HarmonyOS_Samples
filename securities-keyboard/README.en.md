# Custom Keyboard for Securities Codes

### Overview

This sample shows how to implement a custom keyboard application that allows securities codes such as 300 and 600 to be entered with a single tap.

### Preview

![image](screenshots/device/keyboard_EN.gif)

### How to Use

1. Tap the search box. The securities code keyboard is displayed.

2. Tap **600** and **001** on the securities code keyboard. "600001" is displayed in the search box.

3. Tap **clear** on the securities code keyboard. The information in the search box is cleared.

4. Tap **ABC** on the securities code keyboard. The keyboard is switched to an English keyboard.

5. Tap **n**, **i**, **H**, **a**, and **o** on the English keyboard. "niHao" is displayed in the search box.

6. On the English keyboard, tap the shift key in the lower left corner to switch from lowercase to uppercase letters.

7. Tap the close (downward arrow) key on the keyboard to close the keyboard.

8. Tap **x** on the right of the search box to clear the search box.

### Project Directory

```
├──entry/src/main/ets	                 // Code
│  ├──common
│  │  ├──constants
│  │  │  └──CommonConstants.ets          // Common constants
│  │  └──utils
│  │     └──Logger.ets	                 // Logging utility
│  ├──entryability
│  │  └──EntryAbility.ets                // Entry ability
│  ├──model
│  │  └──MenuData.ets                    // Keyboard menu
│  ├──pages
│  │  └──Index.ets                       // Home page
│  ├──view
│  │  ├──DeleteKey.ets                   // Behavior and appearance of the Delete key on the keyboard
│  │  ├──EnglishKeyboard.ets             // Overall structure and layout of the English keyboard
│  │  ├──EnglishKeyItem.ets              // Key items on the English keyboard
│  │  ├──NumberKeyboard.ets              // Overall structure and layout of the numeric keyboard
│  │  ├──NumberKeyItem.ets               // Key items on the numeric keyboard
│  │  └──ShiftKey.ets                    // Shift key on the keyboard
│  └──viewmodel
│     └──KeyEventListen.ets              // APIs for listening for key events
└──entry/src/main/resources              // Static resources of the app
```

### How to Implement

- Tap **Search**. The custom keyboard is displayed. If a custom keyboard is set, activating the text box opens the custom component, instead of the system input method.
- The custom keyboard is implemented in Flex layout.

### Required Permissions

N/A

### Dependencies

N/A

### Constraints

1. The sample is only supported on Huawei phones with standard systems.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.
