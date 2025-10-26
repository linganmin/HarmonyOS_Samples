# Device Security Kit - SafetyDetect

## Overview

This sample code illustrates how to obtain the system integrity check, system integrity check on local, system integrity check enhanced, and URL check results in an app.

The APIs that you need to use are packaged into **@kit.DeviceSecurityKit**.

## Preview
![Example effect](screenshots/device/home_page.png)

## How to Configure and Use

### Configuring the Sample App in DevEco Studio

1. [Create a project](https://developer.huawei.com/consumer/en/doc/app/agc-help-createproject-0000001100334664). Under the project, [add an app](https://developer.huawei.com/consumer/en/doc/app/agc-help-createapp-0000001146718717).
2. Open the sample app and set **bundleName** in the **app.json5** file to the app package name configured in [AppGallery Connect](https://developer.huawei.com/consumer/en/service/josp/agc/index.html).
3. Enable **Safety Detect** in [AppGallery Connect](https://developer.huawei.com/consumer/en/service/josp/agc/index.html). For details, please refer to [here](https://developer.huawei.com/consumer/en/doc/harmonyos-guides/devicesecurity-deviceverify-activateservice).

#### Using the Sample App
1. Before running the sample app, connect the device to the network.
2. Run the sample app. Tap **SysIntegrity** to obtain the system integrity check result. Tap **SysIntegrityOnLocal** to obtain the system integrity check on local result. Tap **SysIntegrityEnhanced** to obtain the system integrity check enhanced result. Tap **UrlThreat** to obtain the URL check result. If the result is obtained successfully, it will be displayed on the page. If the result fails to be obtained, an error code will be displayed on the page.

## Project Directory

```
├─entry/src/main/ets       // Code area.
│ ├─entryability
│ │ └─EntryAbility.ets     // Entry point class.
│ ├─model
│ │ └─SafetyDetectModel.ts // Class for obtaining the system integrity check, system integrity check on local, system integrity check enhanced, and URL check results.
│ ├─pages
│ │ └─Index.ets            // Home page, where the system integrity check, system integrity check on local, system integrity check enhanced, and URL check results can be obtained.
```
## How to Implement

Call the system integrity check, system integrity check on local, system integrity check enhanced, and URL check functions directly on the page. To be specific, call the **safetyDetect.checkSysIntegrity()** method to obtain the system integrity check result of the device, call the **safetyDetect.checkSysIntegrityOnLocal()** method to obtain the system integrity check on local result of the device, call the **safetyDetect.checkSysIntegrityEnhanced()** method to obtain the system integrity check enhanced result of the device, and call the **safetyDetect.checkUrlThreat()** method to obtain the URL check result. For details about the source code, please refer to **SafetyDetectModel.ts**.

Reference:
1. entry\src\main\ets\entryability\EntryAbility.ets
2. entry\src\main\ets\model\SafetyDetectModel.ts
3. entry\src\main\ets\pages\Index.ets

## Required Permissions

None

## Dependencies

The device where the sample app runs must connect to the network.

## Constraints

1. The sample app is only supported on Huawei phone, tablet, and 2-in-1 devices with standard systems.

2. The HarmonyOS version must be HarmonyOS NEXT Developer Beta1 or later.

3. The DevEco Studio version must be DevEco Studio NEXT Developer Beta1 or later.

4. The HarmonyOS SDK version must be HarmonyOS NEXT Developer Beta1 SDK or later.
