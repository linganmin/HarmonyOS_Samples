# Reading and Saving Images Using Media Library Kit

## Overview

This sample demonstrates how to use security components, authorization dialogs, and system permissions to read and save images.

## Effect

<img src="./screenshots/device/preview.en.gif" width="320">

## Project Directory

```
├──entry/src/main/ets                     // Code area 
│  ├──entryability 
│  │  └──EntryAbility.ets                 // Entry ability 
│  ├──component                           // Common components 
│  │  ├──ReadBtn.ets                      // Reading component 
│  │  └──WriteBtn.ets                     // Writing component 
│  ├──pages 
│  │  └──Index.ets                        // Home page 
│  ├──view 
│  │  ├──PhotoPicker.ets                  // Album access using PhotoPicker 
│  │  ├──PhotoViewPicker.ets              // Album access using PhotoViewPicker 
│  │  ├──Preview.ets                      // Preview page 
│  │  ├──ReadView.ets                     // Reading view 
│  │  └──WriteView.ets                    // Writing view 
│  └──utils                               // Utility class 
│     └──AuthorizationTools.ets           // Authorization utility class 
└──entry/src/main/resources               // Static resources
```

## How to Use

1. On the main page, choose any of the three album reading modes to select an image.
2. On the preview page, view the image information.
3. On the saving page, choose any of the three saving modes to save the image to the album.

## How to Implement

1. Use the [PhotoPickerComponent](https://developer.huawei.com/consumer/en/doc/harmonyos-references/ohos-file-photopickercomponent ) component to read images.
2. Use the select property of [PhotoViewPicker](https://developer.huawei.com/consumer/en/doc/harmonyos-references/js-apis-photoaccesshelper#photoviewpicker ) to open the selection page 
   and read images.
3. Call [requestPermissionsFromUser](https://developer.huawei.com/consumer/en/doc/harmonyos-references/js-apis-abilityaccessctrl#requestpermissionsfromuser9 ) to request the 
   media library permission to read images.
4. Use the [SaveButton](https://developer.huawei.com/consumer/en/doc/harmonyos-references-V5/ts-security-components-savebutton-V5 ) component to temporarily 
   obtain the storage permission, and write the image to a file using [packToFile](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkts-apis-image-imagepacker#packtofile11) to save the image.
5. Use [showAssetsCreationDialogue]( https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkts-apis-photoaccesshelper-photoaccesshelper#showassetscreationdialog12) to display the authorization dialog box and write the image to a file using [copyFile]( https://developer.huawei.com/consumer/en/doc/harmonyos-references/js-apis-fileio#fileiocopyfile ) to save the image.
6. Call [requestPermissionsFromUser]( https://developer.huawei.com/consumer/en/doc/harmonyos-references/js-apis-abilityaccessctrl#requestpermissionsfromuser9 ) to request the media library permission, and write the image to a file using [packToFile](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkts-apis-image-imagepacker#packtofile11) to save the image.

## Required Permissions

* Ohos.permission.READ_SMAGEVideo: allows an application to read images.
* Ohos.permission.WRITE: allows an application to write images.

## Constraints

1. This sample is only supported on Huawei phones running standard systems.
2. The HarmonyOS version must be HarmonyOS 5.1.1 Release or later.
3. The DevEco Studio version must be DevEco Studio 5.1.1 Release or later.
4. The HarmonyOS SDK version must be HarmonyOS 5.1.1 Release SDK or later.
