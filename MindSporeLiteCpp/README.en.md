# Image Classification by Using C++ APIs Provided by MindSporeLite

### Overview

This sample describes how to implement an on-device image classification program by using C++ APIs provided by MindSporeLite. It demonstrates the deployment process on the device, helping you master the capabilities of the C++ APIs for image classification.

1. Select an image classification model.
2. Convert the model into MindSporeLite model format.
3. Use the MindSporeLite inference model on the device to display possible classification results.

### Preview

| Home                                                         |
| ------------------------------------------------------------ |
| <img src="screenshots/MindSporeLiteArkTSDemo.png"  width="240px"> |

### How to Use

1. On the home page, tap **Photo** to access the page for selecting photos in the album.
2. Select a photo from the album and tap **OK**.
3. Inference is performed on the selected photo, and the inference result is displayed on the home page.

### Project Directory

```
├──entry/src/main/cpp/                     // Model inference
│  ├──types/libentry/
│  │  ├──Index.d.ts                        // C++ method declaration
│  │  └──oh-package.json5                  // Dependency declaration
│  ├──CMakeLists.txt                       // Link to the MindSporeLite dynamic library
│  └──napi_init.cpp                        // Image recognition
├──entry/src/main/ets/                     // Home page of the app
│  ├──common
│  │  ├──constants
│  │  │  └──CommonConstants.ets             // Common constants
│  │  └──utils
│  │     └──Logger.ets                      // Logger
│  ├──entryability
│  │  └──EntryAbility.ets                   // Entry ability
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets             // Data backup and restoration
│  └──pages
│     └──Index.ets                         // Home page entry
├──entry/src/main/resource                 // Static resources of the app
│  └──rawfile
│     └──mobilenetv2.ms                    // Model file
└──entry/src/main/module.json5             // Module configuration

```

### How to Implement

* Use the image classification model file **mobilenetv2.ms**, which is placed in the **entry\src\main\resources\rawfile** directory of the project.

Note: You can download the [image classification model from MindSpore Model Zoo](https://download.mindspore.en/model_zoo/official/lite/mobilenetv2_openimage_lite/1.5/mobilenetv2.ms) as required.

* Call the **@ohos.file.picker**, **@ohos.multimedia.image**, and **@ohos.file.fs** APIs to obtain and process images in the album. For details about the code, see **Index.ets**.

* Call the **@ohos.ai.mindSporeLite** APIs to implement on-device inference. For details about the code, see **model.ets**.

* Call the inference APIs and process the result. For details about the code, see **Index.ets**.

### Permissions

N/A

### Constraints

1. The sample is only supported on Huawei phones with standard systems.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.