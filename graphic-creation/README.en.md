# AI Powered Image and Text Creation
### Overview
This sample demonstrates the process of creating image/text in social communication apps. It integrates HarmonyOS features such as hoping and service interaction.
### Preview
![](./screenshots/screen.en.gif)
### How to Use
1. Install the sample app on both a tablet and a mobile phone to test image/text hopping.
2. The current cross-device capability only allows a tablet to invoke a mobile phone; it is not possible for a mobile phone to invoke a tablet.
3. To implement cross-device photography, album selection, and image/text hopping, you must log in to the two devices with the same account, connect them to the same Wi-Fi network, and enable their Bluetooth.
4. You can test the following capabilities in this sample: system picker for photo selection, HDR Vivid image display, AI-based text recognition and image matting, moving photo capture, cross-device photography, scanning, album selection, and the capability to continue editing images and text across devices.
### Project Directory
```
├──ets
│  ├──common
│  │  └──CommonConstants.ets             // Common constants
│  ├──entryability
│  │  └──EntryAbility.ets
│  ├──model
│  │  ├──CameraService.ets               // Camera service
│  │  ├──SelectedDataSource.ets          // Data source of photos picked
│  │  └──WaterFlowDataSource.ets         // Waterfall data source on the home page
│  ├──pages
│  │  ├──GraphicCreationPage.ets         // Image/Text editing and release page
│  │  ├──ImageEditPage.ets               // Switch between the image selection and editing page and the custom camera
│  │  ├──Index.ets                       // Home page
│  │  ├──PreviewMovingPhotoPage.ets      // Preview moving photo page
│  │  └──PreviewPhotoPage.ets            // Preview common photo page
│  ├──utils
│  │  ├──BreakpointSystem.ets            // Breakpoint listener
│  │  ├──DataUtils.ets                   // Data conversion tool
│  │  ├──FileUtils.ets                   // File processing tool
│  │  ├──Logger.ts                       // Log utility
│  │  └──UIUtils.ets                     // UI setting tools
│  └──view
│     ├──CameraView.ets                  // Camera view
│     ├──FlowItemView.ets                // Waterfall widget components
│     ├──HomeView.ets                    // Home page view
│     ├──ListAddPictureView.ets          // Add image list view
│     ├──NavigationBarView.ets           // Custom navigation bar components on the home page
│     ├──SearchTitleView.ets             // Title search view on the home page
│     ├──SelectedEditeView.ets           // Selected image editing view
│     └──TitleBackView.ets               // Back title component
└──resources
```
### How to Implement
Leverage HarmonyOS features in the image/text editing and release phase of social communication applications for scenario implementation.
### Required Permissions
Permissions related to Internet, location, camera, distributed device management, read/write, and microphone:
```
ohos.permission.DISTRIBUTED_DATASYNC
ohos.permission.APPROXIMATELY_LOCATION
ohos.permission.LOCATION
ohos.permission.INTERNET
ohos.permission.LOCATION_IN_BACKGROUND
ohos.permission.CAMERA
ohos.permission.MICROPHONE
ohos.permission.READ_IMAGEVIDEO
ohos.permission.WRITE_IMAGEVIDEO
```
### Constraints
1. The sample app is supported only on Huawei phones and tablets running the standard system.
2. The HarmonyOS version must be HarmonyOS 5.0.0 Release or later.
3. The DevEco Studio version must be DevEco Studio 5.0.0 Release or later.
4. The HarmonyOS SDK version must be HarmonyOS 5.0.0 Release or later.