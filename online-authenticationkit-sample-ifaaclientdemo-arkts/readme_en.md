# IFAA

## Overview

This sample illustrates how to use the APIs for IFAA password-free identity verification.

You can import IFAA APIs through **@kit.OnlineAuthenticationKit** to enable, perform, and disable on-device IFAA password-free identity verification.


## Preview

| App entry| App home page| API call buttons|
| --------------- | --------------- | -------------- |
| App icon for opening the app| App home page displayed on the device screen  | Tapping a button to call the corresponding API |
| <img src=".\image\startIcon.png" style="zoom:50%;" /> | <img src=".\image\homepage_en.jpeg" style="zoom:25%;" /> | <img src=".\image\results_en.jpeg" style="zoom:25%;" /> |

## Project Directory

```
├── entry/src/main/ets               // Code area
│    ├── entryability
│    │    └── EntryAbility.ets       // Entry point class.
│    ├── model
│    │    └── IfaaModel.ets          // Enabling, performing, and disabling IFAA password-free identity verification
│    └── pages
│         └── Index.ets              // Home page
│    └── util
│         └── Util.ets               // Utility class
```



## How to Use

1. To use fingerprint/3D face authentication for password-free identity verification, record the biometric feature information onto a mobile device.
2. After the fingerprint/3D face information is recorded onto the device, tap **Enable** to enable IFAA password-free identity verification. Biometric authentication is required in this step.
3. Tap the **Authenticate** button to perform IFAA password-free identity verification based on biometric features (face/fingerprint).
4. Tap the **Disable** button to disable IFAA password-free identity verification based on biometric features (face/fingerprint).


## How to Implement
The following uses performing IFAA password-free identity verification as an example. You need to import the following IFAA APIs first:

import { ifaa } from '@kit.OnlineAuthenticationKit'
* function preAuthSync(): Uint8Array;
* function auth(authToken: Uint8Array, authData: Uint8Array):Promise&lt;Uint8Array&gt;;

Record the fingerprint/3D face information onto the device first. Then, call the **preAuth()** API to obtain a temporary challenge for the current IFAA authentication. The challenge value must be the same as the one used for biometric authentication. The IFAA service verifies the validity period of the challenge. If the challenge is not used for a long time after being obtained, the authentication will fail.
After obtaining the fingerprint/face information by calling Authentication Kit, call the **auth()** API for identity verification. If the operation is successful, a signed packet is returned. If the operation fails, an exception is thrown.
For details about the code, see **Index.ets**.


## Required Permissions

1. **ohos.permission.ACCESS_BIOMETRIC**: permission for biometric recognition.

## Dependencies

UserAuthenticationKit

## Constraints

1. The sample app is only supported on devices with standard systems.Supported devices: Huawei phones, tablets, and 2in1.
2. The DevEco Studio version used in this sample must be DevEco Studio NEXT Developer Beta1.
3. The HarmonyOS version must be  HarmonyOS NEXT Beta1 or later.
4. The HarmonyOS SDK version must be HarmonyOS 5.1.0 Release SDK or later.
5. The sample code requires packets signed by the IIFAA central server for correct results.
