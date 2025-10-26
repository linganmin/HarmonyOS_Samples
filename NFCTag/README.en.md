# NFC-based App Redirection

## Overview

Near-field communication (NFC) is a short-range high-frequency radio technology. It enables electronic devices to communicate with NFC tags and read data from the tags.

There are two scenarios:

* NFC tag reading in the foreground: When a specific app is opened and the device touches the NFC tag, the tag data is distributed to the app in the foreground.
* NFC tag reading in the background: When a specific app is not opened and the device touches the NFC tag, the tag data is distributed to an app that can process the data based on the NFC tag technology type. If multiple apps are matched, the app selector is displayed for the user to manually select an app. If only one app is matched, the matched app is directly opened.

(Note: Regardless of whether the NFC tag is read in the foreground or background, a prerequisite for the electronic device to discover the NFC tag is that the device is in a screen-on and unlocked state.)

## Preview

| Tag reading in the foreground            | Tag reading in the background             |
|------------------------------------------|-------------------------------------------|
| ![](screenshots/divice/forground_en.gif) | ![](screenshots/divice/background_en.gif) |

## Project Directory

```
├──entry/src/main/ets                                   // Code area
│  ├──entryability
│  │  └──EntryAbility.ets                               // Entry ability
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  ├──pages
│  │  └──Index.ets                                      // Home page
│  └──view
│     └──ReadNFCTag.ets                                 // NFC information page
└──entry/src/main/resources                             // App resource directory
```

## How to Use

The sample code involves the following scenarios:

* Tag reading in the foreground: When the app is opened and the NFC tag touches the NFC recognizable area of the device, the NFC tag data is read. The sub-page is displayed, showing the technology types and tag information supported by the NFC tag.


* Tag reading in the background: When the app is not opened and the NFC tag touches the NFC recognizable area of the device, the app will be matched based on the NFC tag technology type. If multiple apps are matched, a dialog box is displayed for the user to manually open one of the apps. If only one app is matched, the app is directly opened, displaying the NFC tag technology type and tag information.

## Permissions

* **ohos.permission.NFC_TAG**: allows an app to read NFC tag information.

## Constraints

* The sample is only supported on Huawei phones with standard systems.
* The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.
* The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.
* The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.