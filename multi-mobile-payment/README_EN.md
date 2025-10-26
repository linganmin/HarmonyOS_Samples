# One development, multiple deployment-Mobile Payment

## Overview

Based on the default UI scanning capability and barcode image generation capability of Scan Kit, this sample implements the common scanning and acceptance and payment functions in mobile payment apps.

## Preview
The following figure shows the running effect on a mobile phone.

<img src="screenshots/device/phone_EN.png" width="320"/>

The following figure shows the running effect on a foldable phone.

<img src="screenshots/device/foldable_EN.png" width="480"/>

The following figure shows the running effect on a tablet.

<img src="screenshots/device/tablet_EN.png" width="800"/>


## Project Directory

```
├──entry/src/main/ets                                   // Code area
│  ├──common
│  |  └──Constants.ets                                  // Constants
│  ├──entryability
│  |   └──EntryAbility.ets
│  ├──pages
│  |  ├──Home.ets                                       // Home page
│  |  ├──Index.ets                                      // Entry page
│  |  ├──ReceivePaymentPage.ets                         // Acceptance and payment page
│  |  └──ScanQRCodePage.ets                             // Custom QR scanning page
│  ├──view
│  |  ├──CashFlowCenterCard.ets                         // Function bar at the bottom of the acceptance and payment page
│  |  ├──FunctionCard.ets                               // Function widget
│  |  ├──QuickFunctionCardCircle.ets                    // Shortcut function (circular)
│  |  ├──QuickFunctionCardSquare.ets                    // Shortcut function (rectangle)
│  |  ├──ScanQRCodeDialog.ets                           // Custom QR code scanning pop-up window
│  |  └──XComponentView.ets                             // Component that encapsulates the QR scanning capability
│  └──viewmodel
│     ├──FortunePicksViewModel.ets                      // Featured fortune data
│     ├──PayHubViewModel.ets                            // Payment center data
│     ├──QuickFunctionsViewModel.ets                    // Quick function data
│     ├──ReceiveMoneyServiceCardViewModel.ets           // Acceptance and payment data
│     └──ServiceCardViewModel.ets                       // Service widget data
└──entry/src/main/resources                             // App resource directory
```

## How to Implement
The scanning function is implemented using the custom UI scanning capability of Scan Kit. You need to call APIs such as **init**, **start**, and **release** to customize the scanning process.

The acceptance and payment service mainly uses the barcode generation capability of Scan Kit. The key is to use the **createBarcode** API to generate a payment QR code based on the information required for acceptance and payment. Required information can be obtained by scanning the QR code, followed by the corresponding logic operations.

## Required Permissions

N/A

## Constraints

1. The sample app is supported on Huawei phones or tablets running the standard system.
2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.
3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.
4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release or later.
