# Developing Home Screen Shortcuts
## Overview
Home screen shortcuts enable you to rapidly access the core functions of apps, thereby enhancing operation efficiency and increasing users' dependency on apps.

For example, you can create a navigation shortcut for frequently visited places such as your home and company. Tap to launch the map app and start navigation.
## Preview
![](/screenshots/image_en.gif)
## Project Directory
````
├──entry/src/main/ets                                   // Code area
│  ├──entryability
│  │  └──EntryAbility.ets                               // Entry ability
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  └──pages
│     ├──GoCompany.ets                                  // My Company page
│     ├──Login.ets                                      // My Home page
│     └──Logout.ets                                     // Home page
└──entry/src/main/resources                             // App resource directory
````
## How to Use
Long pressing the app icon will display the shortcut list. Tap the icon to quickly open the desired page in the app.
## How to Implement
* Configure the **shortcuts_config.json** file in **/resources/base/profile/**.

* In the **abilities** tag of the **module.json5** file, configure the **metadata** tag for the UIAbility component to which a shortcut needs to be added so that the shortcut configuration file takes effect for the UIAbility.

## Permissions
N/A
## Constraints
* The sample is only supported on Huawei phones with standard systems.

* The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

* The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

* The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.