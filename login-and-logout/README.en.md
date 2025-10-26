# Login and Logout
## Overview
This sample uses the Navigation component for navigating between pages and PromptAction for popping up dialog boxes. It simulates the login and logout scenarios, and its UI code adapts to different device models. In addition, the app's login process complies with privacy requirements and features proper navigation logic.

##  Preview
Running effect on a mobile phone

![](/screenshots/image1_en.png)

Running effect on a foldable phone

![](/screenshots/image2_en.png)

Running effect on a tablet

![](/screenshots/image3_en.png)

## Project Directory
````
├──entry/src/main/ets                                   // Full-screen login code
│  ├──common
│  │  └──CommonConstants.ets                            // Common constants
│  ├──entryability
│  │  └──EntryAbility.ets                               // Entry ability
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  ├──pages                              
│  │  ├──AuthorizedDialog.ets                           // Privacy authorization dialog box
│  │  └──Index.ets                                     // Home page
│  │  ├──Login.ets                                      // Login page
│  │  └──Logout.ets                                     // Logout page
│  └──utils.ets
│     └──JudgeHasNet.ets                                // Check for Internet connection
└──entry/src/main/resources                             // Static resources
├──login/src/main/ets                                   // Full-screen login code
│  ├──common
│  │  └──CommonConstants.ets                            // Common constants
│  ├──loginability
│  │  └──LoginAbility.ets                               // Login ability
│  ├──pages                              
│  │  ├──AuthorizedDialog.ets                           // Privacy authorization dialog box
│  │  ├──Index.ets                                      // Home page
│  │  ├──Login.ets                                      // Login page
│  │  └──Logout.ets                                     // Logout page
│  └──utils.ets
│     └──JudgeHasNet.ets                                // Check for Internet connection
└──login/src/main/resources                             // Static resources
````
## How to Use
This sample has two modules:

* entry module: If the code in this module is run, the login page is displayed in full screen. When there is no Internet connection, a message indicating the lack of connectivity is displayed after you touch the login button. If you enter a mobile number and password without agree to the terms, a dialog box is displayed to ask for your confirmation. Touching OK signifies your acceptance of the terms. Upon successful login, the user information is displayed on the home page. To log out of the app, access Settings and touch Logout in the displayed dialog box.

* login module: If the code in this module is run, the login page is displayed in a modal dialog box. The display and logic of other pages are the same as those in the entry module.

## Required Permissions
ohos.permission.INTERNET: allows an app to access the Internet.

ohos.permission.GET_NETWORK_INFO: allows an app to obtain network information.

## Constraints
* The sample app is supported only on Huawei phones running the standard system.

* The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

* The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

* The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release or later.