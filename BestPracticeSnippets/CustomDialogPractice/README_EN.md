# **Custom Dialog Box Development**
## Overview
The dialog box is a basic function that needs to be implemented during application development. It is usually used to display information or operations that users need or must pay attention to. It can be used for interactions with users, such as advertising, prize winning, warning, and software update.
During application development, you need to customize the UI and functionalities. However, the system dialog box cannot meet this requirement and you need to customize dialog boxes.

Proper selection of different system capabilities to implement dialog boxes helps improve application development efficiency and meet better function requirements. Therefore, it is important to understand the types of custom dialog boxes and their differences. During application development, pay attention to the following two points in terms of use scenarios to select a proper dialog box:
 

* Decoupling between dialog boxes and UI code
During service logic development, for example, in some network request failure scenarios, a corresponding dialog box needs to be triggered to remind the user to perform a proper operation. As the dialog box is not associated with a specific page and it may be triggered on any page, you should decouple the dialog box from the page.
 

* Retaining the dialog box after the page is redirected
On some permission configuration pages, when a user accesses an application for the first time, a permission configuration dialog box is displayed for the user to perform operations. If the user taps the dialog box to go to the privacy details page, the dialog box needs to be retained on the page after the user returns.

## Preview
![](./screenshots/device/Effect.gif)

## Project Directory
``` 
├──entry/src/main/ets                                   // Code
│  ├──entryability
│  │  └──EntryAbility.ets                               // Entry ability
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  ├──pages                              
│  │  ├──CustomDialogDisplayAndExitAnimations.ets       // Customizing entrance and exit animations for dialog box 
│  │  ├──CustomDialogNotDisappear.ets                   // Retaining the dialog box after page switching
│  │  ├──GlobalDialogDecoupledFromThePage.ets           // Decoupling global dialog box from the page
│  │  ├──Index.ets                                      // Entry file
│  │  ├──InterceptReturn01.ets                          // Example 1 of blocking to close a dialog box through the Back button or swiping
│  │  └──InterceptReturn02.ets                          // Example 2 of blocking to close a dialog box through the Back button or swiping
│  └──utils.ets
│     └──PromptActionClass.ets                            // Encapsulated custom dialog box class
└──entry/src/main/resources                             // Application resources
``` 
## How to Use
Touch the five buttons on the home page in sequence to implement the following four scenarios:
* Dialog Decoupled From the Page (button 1)
* Intercept Return (buttons 2 and 3)
* Dialog Not Disappear (button 4)
* Dialog Display And Exit Animations (button 5)

## How to Implement
* To implement the global dialog box, use **UIContext.getPromptAction**. For details, see [Decoupling Global Dialog Box from the Page](https://developer.huawei.com/consumer/en/doc/best-practices/bpta-custome-dialog-development-practice#section7466312192919).
* To block the closing of dialog box through back button and swiping gestures, use **onWillDismiss** of **BaseDialogOptions** for interactive dismissal of the dialog box, or use **onBackPressed** of **NavDestination** based on the custom dialog box **Navigation**. For details, see [Blocking to Close a Dialog Box Through the Back Button or Swiping](https://developer.huawei.com/consumer/en/doc/best-practices/bpta-custome-dialog-development-practice#section111721345172917).
* To retain the dialog box after page switching, use **Navigation.Dialog** or **NavDestinationMode.DIALOG** in the route stack. For details, see [Retaining the Dialog Box After Page Switching](https://developer.huawei.com/consumer/en/doc/best-practices/bpta-custome-dialog-development-practice#section690764913302).
* To customize entrance and exit animations for dialog box, use **CustomDialogOptions** to define the options of the custom dialog box based on **UIContext.getPromptAction**. The **transition** parameter of **BaseDialogOptions** can be used to set the transition effect for the entrance and exit of the dialog box. For details, see [Customizing Entrance and Exit Animations for Dialog Box](https://developer.huawei.com/consumer/en/doc/best-practices/bpta-custome-dialog-development-practice#section621242223120).

## Required Permissions
N/A

## Constraints
* This sample is supported only on Huawei phones running the standard system.

* The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

* The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

* The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.

## Download

To download this project separately, execute the following command:
```
git init
git config core.sparsecheckout true
echo AppPrivacyProtection/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```
