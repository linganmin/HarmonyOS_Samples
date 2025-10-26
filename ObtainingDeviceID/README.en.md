# Obtaining Device IDs

## Overview
A device ID is a code or symbol used to identify a device, and is used by an app to distinguish a device. HarmonyOS provides three types of device IDs:
* [ODID (Open Device Identifier)](https://developer.huawei.com/consumer/en/doc/harmonyos-references/js-apis-device-info): used to identify apps running on the same device of the same developer.
* [OAID (Open Anonymous Device Identifier)](https://developer.huawei.com/consumer/en/doc/harmonyos-guides/oaid-service): used to provide personalized ads for users while protecting their personal data privacy.
* [AAID (Anonymous Application Identifier)](https://developer.huawei.com/consumer/en/doc/harmonyos-guides/push-get-aaid): used to identify apps during app push.

## Preview
![](./screenshots/device/Effct_en.gif)

## Project Directory
```
├──entry/src/main/ets                                   // Code area
│  ├──entryability
│  │  └──EntryAbility.ets                               // Entry ability
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  ├──pages
│  │  └──Index.ets                                      // Entry file
│  └──view
│     └──CreateIDComponent.ets                          // Pages for creating device IDs
└──entry/src/main/resources                             // App resource directory
```
## How to Use
Tap the three buttons on the app home page in sequence to access the pages for creating device IDs. The following three scenarios can be implemented:
* Create an ODID. After the creation is successful, the ODID is displayed in the text box. Save the ODID to the asset. Tap the Query button. After the query is successful, the ODID is displayed in the text box.
* Create an AAID. After the creation is successful, the AAID is displayed in the text box. Save the AAID to the asset. Tap the Query button. After the query is successful, the AAID is displayed in the text box.
* Create an OAID. After the creation is successful, the OAID is displayed in the text box. Save the OAID to the asset. Tap the Query button. After the query is successful, the OAID is displayed in the text box.

## How to Implement
* Obtain an ODID using [deviceInfo](https://developer.huawei.com/consumer/en/doc/harmonyos-references/js-apis-device-info).
* Obtain an OAID using [identifier.getOAID](https://developer.huawei.com/consumer/en/doc/harmonyos-references/js-apis-oaid#identifiergetoaid).
* Obtain an AAID using [AAID.getAAID](https://developer.huawei.com/consumer/en/doc/harmonyos-references/push-kit-aaid#section573317917425).
* Add an asset using [asset.add](https://developer.huawei.com/consumer/en/doc/harmonyos-references/js-apis-asset#assetadd).
* Query one or more assets using [asset.query](https://developer.huawei.com/consumer/en/doc/harmonyos-references/js-apis-asset#assetquery).

## Permissions
Allow apps to read the OAID (**ohos.permission.APP_TRACKING_CONSENT**).

## Constraints
* The sample is only supported on Huawei phones with standard systems.

* The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

* The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

* The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.