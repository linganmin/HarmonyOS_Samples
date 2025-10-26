# SOTER

## Overview

This sample illustrates how to use the APIs for SOTER password-free identity verification. You can import the SOTER APIs through **@kit.OnlineAuthenticationKit** and import the **userAuth** API through **@kit.UserAuthenticationKit**. You can implement the functions of generating keys as well as enabling, performing, and disabling SOTER password-free identity verification on a device connected to the Internet.


## Preview

| App entry| App home page| API call buttons |
| --------------- | --------------- | -------------- |
| App icon for opening the app| App home page displayed on the device screen  | Tapping a button to call the corresponding API |
| <img src=".\image\startIcon.png" style="zoom:50%;" /> | <img src=".\image\homepage_en.jpeg" style="zoom:25%;" /> | <img src=".\image\results_en.jpeg" style="zoom:25%;" /> |

## Project Directory

```
├──entry/src/main/ets                     // Code area
│   ├──entryability
│   │   └──EntryAbility.ets               // Entry point class
│   ├──model
│   │   └──SoterModel.ts                  // Key generation, signing, and deletion
│   └──pages
│       └──Index.ets                      // Home page
└──entry/src/main/resources               // App resource directory
```



## How to Use

1. To use fingerprint/3D face authentication for password-free identity verification, record the biometric feature information onto a mobile device.
2. After the fingerprint/3D face information is recorded onto the device, tap **Generate AppSecureKey** to generate an app secure key. A message is displayed, indicating that the operation is successful.
3. Tap **Generate AuthKey** to generate an authentication key. A message is displayed, indicating that the operation is successful.
4. Tap the **Authenticate** button to perform SOTER password-free identity verification based on biometric features (face/fingerprint).
5. Tap the **Disable** button to disable SOTER password-free identity verification based on biometric features (face/fingerprint).


## How to Implement
The following uses performing SOTER password-free identity verification as an example. You need to import the following SOTER APIs first:

import {soter} from '@kit.OnlineAuthenticationKit'
* function getChallenge(keyAlias: string): Uint8Array;
* function auth(keyAlias: string, authToken: Uint8Array, info: string): soter.SignedResult;

Record the fingerprint/3D face information onto the device first. Then, call the **getChallenge()** API to obtain a temporary challenge for the current SOTER authentication. The challenge value must be the same as the one used for biometric authentication. The SOTER service verifies the consistency between the two challenges. Use User Authentication Kit to perform biometric authentication, and then call the **auth()** API to sign the service data. If the operation is successful, a signed packet is returned. If the operation fails, an exception is thrown.

For details about the code, see **Index.ets**.


## Required Permissions

1. **ohos.permission.INTERNET**: permission to access the Internet.
2. **ohos.permission.VIBRATE**: permission to vibrate.
3. **ohos.permission.ACCESS_BIOMETRIC**: permission for biometric recognition.

## Constraints

1. The sample app is only supported on devices with standard systems.Supported devices: Huawei phones, tablets, and 2in1.
2. The HarmonyOS version must be HarmonyOS NEXT Beta1 or later.
3. The DevEco Studio version must be DevEco Studio NEXT Developer Beta1.
4. The HarmonyOS SDK version must be HarmonyOS 5.1.0 Release SDK or later.
