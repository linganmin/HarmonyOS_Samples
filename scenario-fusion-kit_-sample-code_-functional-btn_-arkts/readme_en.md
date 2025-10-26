# Scenario-specific Components Built Based on Scenario Fusion Kit

## Overview

This sample code illustrates how to use scenario-specific components provided by Scenario Fusion Kit to implement relevant functions, including the button for verifying a mobile number quickly, button for selecting a location on the map, button for selecting an avatar, button for launching an app, button for selecting a shipping address, button for selecting an invoice title, button for setting permissions, and province/city/district selector input component.

The APIs that you need to use are packaged into **@kit.ScenarioFusionKit**.

## Preview

| Home Page                                     | Button for Verifying a Mobile Number Quickly           |      Button for Selecting a Location on the Map       |
|-----------------------------------------------|--------------------------------------------------------|-------------------------------------------------------|
| <img src=screenshots/main_en.jpg width="250"> | <img src=screenshots/get_phone_number_en.jpg width="250"> | <img src=screenshots/choose_location_en.jpg width="250"> |

| Button for Selecting an Avatar                 | Button for Selecting an Invoice Title                   | Button for Launching an App                       |
|------------------------------------------------|-----------------------------------------------------------|------------------------------------------------|
| <img src=screenshots/choose_avatar_en.jpg width="250"> | <img src=screenshots/choose_invoice_title_en.jpg width="250"> | <img src=screenshots/open_app_en.jpg width="250"> |

| Button for Selecting a Shipping Address                                       | Button for Permission Settings      | Province/City/District Selector Input Component    |
|------------------------------------------------------|-------------------------------------------------|----------------------------------------------------|
| <img src=screenshots/choose_address_en.jpg width="250"> | <img src=screenshots/PermissionSetting_en.jpg width="250"> | <img src=screenshots/selector_input_en.jpg width="250"> |

Instructions

1. On the home page, tap the button for verifying a mobile number quickly, button for selecting a location on the map, button for selecting an avatar, button for launching an app, button for selecting a shipping address, button for selecting an invoice title, button for setting permissions, and province/city/district selector input component to test corresponding functions.
2. Configure the basic style of a button by setting **styleOption**.
3. Define more style settings in **styleConfig** of **styleOption**.

## How to Configure and Use

### Configuring the Codelab Project in DevEco Studio

1. [Create a project](https://developer.huawei.com/consumer/en/doc/app/agc-help-create-project-0000002242804048). Under the project, [create an app](https://developer.huawei.com/consumer/en/doc/app/agc-help-create-app-0000002247955506).
2. For details, please refer to relevant sections in the development guide: [Preparations](https://developer.huawei.com/consumer/en/doc/harmonyos-guides/scenario-fusion-preparations), and the "Prerequisites" part in [Scenario-Specific Buttons](https://developer.huawei.com/consumer/en/doc/harmonyos-guides/scenario-fusion-button) and [Scenario-specific Input Component](https://developer.huawei.com/consumer/en/doc/harmonyos-guides/scenario-fusion-input).

## Project Directory
```
entry
  └─src                     
    ├─main                
    │  ├─ets              
    │  │  ├─entryability          // Entry point class
    │  │    ├──EntryAbility.ets   // Ability for local startup
    │  │  └─pages
    │  │    ├──Index.ets                     // Basic preview page
    │  └─resources        
    │      ├─base         
    │      │  ├─element       // Resources such as color, font, and character strings
    │      │  ├─media         // Resources such as images 
    │      │  └─profile       // Page configuration
```

## How to Implement

The scenario-specific components of the button for verifying a mobile number quickly, button for selecting a location on the map, button for selecting an avatar, button for launching an app, button for selecting a shipping address, button for selecting an invoice title, and button for permission settings are all packaged in **\entry\src\main\ets\pages**. When any of these buttons is tapped, the corresponding function of the FunctionalButton component is triggered.
The scenario-specific component of the province/city/district selector input button is encapsulated in **\entry\src\main\ets\pages**. When the button is tapped, the corresponding function of the FunctionalInput component is triggered.

## Required Permissions

For details, please refer to relevant sections in the development guide: [Preparations](https://developer.huawei.com/consumer/en/doc/harmonyos-guides/scenario-fusion-preparations), and the "Prerequisites" part in [Scenario-Specific Buttons](https://developer.huawei.com/consumer/en/doc/harmonyos-guides/scenario-fusion-button) and [Scenario-specific Input Component](https://developer.huawei.com/consumer/en/doc/harmonyos-guides/scenario-fusion-input).

## Dependencies

None

## Constraints

1. This sample is only supported on phones, tablets, and 2-in-1 devices with standard systems. Note that, only some components support TVs currently. For details, please refer to the constraints of [each component](https://developer.huawei.com/consumer/en/doc/harmonyos-guides/scenario-fusion-guide).
2. The HarmonyOS version must be HarmonyOS 5.0.0 Release or later.
3. The DevEco Studio version must be DevEco Studio 5.0.0 Release or later.
4. The HarmonyOS SDK version must be HarmonyOS 5.0.0 Release SDK or later.
