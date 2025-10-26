# Jump Between Applications

## Overview

This sample demonstrates how to start and jump between applications. It covers starting an application, starting a specified application, and starting an application with a specified intent. After the application is started, parameters are returned.

## Preview
The figure shows the effect on a smartphone.

![image](screenshots/device/phone_EN.gif)

## Project Directory

```  
├──entry/src/main/ets                         // Code  
│  ├──pages  
│  │  └──Index.ets                            // Home page  
│  ├──entryability  
│  │  └──EntryAbility.ets                     
│  ├──entrybackupability  
│  │  └──EntryBackupAbility.ets               
│  ├──view  
│  │  ├──CommunicationArea.ets                // Communication area  
│  │  ├──FooterBar.ets                        // Footer function area  
│  │  ├──HeaderBar.ets                        // Header info area  
│  │  ├──MessageItem.ets                      // Single message  
│  │  └──WarningBox.ets                       // Warning  
│  └──viewmodel  
│     └──MessageViewModel.ets                 // Info data  
└──entry/src/main/resources                   // App resource directory  
```  

## How to Implement

Use **openLink()** to start the app with the specified App Linking.

Use **startAbilityByType()** to start applications of a specified type and configure the parameters of the applications to be started. The system prompts the user to select an application to continue the operation. After the user selects an application, the operation continues in the application.

**NOTE**:
1. You need to modify the App Linking in line 67 of `src/main/ets/viewmodel/MessageViewModel.ets`.
2. To start a self-developed app, you need to configure App Linking in the dependence/AppLinkingTestDemo app. It covers applying for a link, certificate, and profile signature.

## Required Permissions

N/A

## Constraints

1. The sample is supported only on Huawei phones with standard systems.
2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.
3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.
4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.
