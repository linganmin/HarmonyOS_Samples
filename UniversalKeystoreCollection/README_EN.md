# Universal Keystore Collection

### Overview

This sample shows how to use the APIs provided by @ohos.security.huks to perform basic keystore operations, such as encryption, decryption, signing, signature verification, and key agreement.

### Preview
![](screenshots/Devices/UniversalKeystoreCollection_en.gif)

### How to Use

1. On the home page, tap **Encryption/Decryption**, **Signing & signature verification**, or **Key agreement** to go to the corresponding page.

2. Perform encryption and decryption.

  Tap **Encryption/Decryption** on the home page, select the encryption algorithm, enter the text to be encrypted, and tap the **Encrypt** button.

  If the encryption is successful, a message is displayed and the ciphertext is displayed in the **Encrypted text**  box. 

  Tap **Decrypt**. If the decryption is successful, a message is displayed and the plaintext is displayed in the **Decrypted text**  box.

3. Generate and verify a digital signature.

  Tap **Signing & signature verification** on the home page, select the algorithm, and tap the **Sign** button. If the signing is successful, a message is displayed, showing the signing result.

  Tap **Verify** to verify the signature. If the verification is successful, a message is displayed, showing the verification result. If you tap **Verify** but the text has not been signed, a message is displayed, indicating that the signature is empty and the signature verification fails.

4. Perform key agreement.

  Tap **Key agreement** on the home page, select the algorithm, tap **Generate asymmetric Key A** and **Generate asymmetric key B** to generate a key pair, and tap **Key agreement**. If both keys A and B exist, a message is displayed, indicating that the key agreement is successful. Otherwise, a dialog is displayed, indicating that the key is missing and the key agreement fails.

### Project Directory
```
├──entry/src/main/ets                             
│  ├──common
│  │  ├──constants                                
│  │  │  ├──CommonConstants.ets                   // Common constants
│  │  │  └──HuksPropertiesConstants.ets           // Huks Properties Constants
│  │  └──utils
│  │     ├──EncodingUtils.ets                     // Encoding Utils
│  │     ├──EncryptAndDecryptUtils.ets            // Encrypt And Decrypt Utils
│  │     ├──KeyNegotiationUtils.ets               // Key Negotiation Utils
│  │     ├──Logger.ets                            // Logger
│  │     └──SignatureVerificationUtils.ets        // Signature Verification Utils
│  ├──entryability
│  │  └──EntryAbility.ets                         // Entry ability
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  ├──pages
│  │  ├──EncryptionDetailPage.ets                 // Encryption Detail Page
│  │  ├──EncryptionPage.ets                       // Encryption Page
│  │  ├──Index.ets                                // Index
│  │  ├──KeyNegotiationDetailPage.ets             // Key Negotiation Detail Page
│  │  ├──KeyNegotiationPage.ets                   // Key Negotiation Page
│  │  ├──SignatureVerificationDetailPage.ets      // Signature Verification Detail Page
│  │  └──SignatureVerificationPage.ets            // Signature Verification Page
│  └──viewmodel
│     └──RouterParam.ets                          // RouterParam
└──entry/src/main/resources                       // resources
```

### Required Permissions

N/A

### Dependencies

N/A

### Constraints

1. The sample app is supported only on Huawei phones running the standard system.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release or later.
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          