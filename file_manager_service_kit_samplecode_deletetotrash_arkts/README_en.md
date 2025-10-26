# Implementing File Deletion to the Recycle Bin Based on File Manager Kit (ArkTS)

## Brief Introduction 
This example uses the API provided by the File Manager Service Kit to implement the selection and
deletion of files to the recycle bin for your reference.

## Preview Figure

![Image](./screenshots/device/indexPage_en.gif)	

## Project Directory

```
└──entry/src/main                      //Code area
   ├──ets
   │  ├──entryability 
   │  │  └──EntryAbility.ets           //Program Entry Class
   │  └──pages
   │     └──Index.ets                  //Main page
   └──resources                        //Resource File Directory
```

## Instructions for use

1.  Use DevEco Studio to open the project directory.
2.  Configure signature information in signingConfigs of build-profile.json5.
3.  Run the sample code on a HarmonyOS device.
4.  Click 'Select files to delete' to select the corresponding file.

## Implementation

The APIs of the file management service are defined in @kit.FileManagerServiceKit. An example API is as follows:

```
/**
     *Delete file or directory to trash.
     *
     *@param {string} uri - File or directory to delete.
     *@returns {Promise<string>} - Uri of file or directory in trash.
     *@throws {BusinessError} 401 - Parameter error.
     *@throws {BusinessError} 1014000001 - Operation not permitted.
     *@throws {BusinessError} 1014000002 - No such file or directory.
     *@throws {BusinessError} 1014000003 - No space left on device.
     *@throws {BusinessError} 1014000004 - System inner fail.
     *@syscap SystemCapability.FileManagement.FileManagerService.Core
     *@since 5.0.5(17)
     */
    function deleteToTrash(uri: string): Promise<string>;
```

To use services, run the import { fileManagerService } from '@kit.FileManagerServiceKit' command to import the corresponding module.
For details, see the [entry\src\main\ets\pages\Index.ets](./entry/src/main/ets/pages/Index.ets)  file.

## Constraints and Limitations

1.  This example can run only on the standard system. Supported devices: Huawei phone, tablet, and PC/2in1.
2.  HarmonyOS system: HarmonyOS 5.0.5 Release or later.
3.  DevEco Studio version: DevEco Studio 5.0.5 Release or later.
4.  HarmonyOS SDK version: HarmonyOS 5.0.5 Release SDK or later.

