# Intelligent input suggestions and filling based on Scenario Fusion Kit

## Overview

This sample code illustrates how to use SmartFill to offer scenario-specific input suggestions to realize one-tap filling of complex forms for users.

The APIs that you need to use are packaged into **@kit.AbilityKit**.

## Preview


| **Home Page**                                    | **Clipboard-based Input Suggestion**                                      | **Account Kit-based Input Suggestion**                                   |
|--------------------------------------------|-------------------------------------------------|-----------------------------------------------|
| <img src=screenshots/main_en.jpg width="250"> | <img src=screenshots/clipboard_en.jpg width="250"> | <img src=screenshots/account_en.jpg width="250"> |

| **Historical Form Input Saving**                                      | **Historical Form Input Update**                                        | **Input Suggestion Based on Historical Form Input**                                      |
|----------------------------------------------------|------------------------------------------------------|----------------------------------------------------|
| <img src=screenshots/history_save_en.jpg width="250"> | <img src=screenshots/history_update_en.jpg width="250"> | <img src=screenshots/history_form_en.jpg width="250"> |

## Prerequisites

1. The SmartFill function has been enabled on the device. To enable the function, go to **Settings** > **Privacy and security** > **SmartFill**.
2. Configure the scenario in the [ContentType](https://developer.huawei.com/consumer/en/doc/harmonyos-guides/scenario-fusion-intelligentfilling-appendix) attribute of the input component of your app or atomic service to trigger SmartFill. 
3. To integrate SmartFill, submit an application and wait for approval. For details, please refer to the [integration guide](https://developer.huawei.com/consumer/en/doc/harmonyos-guides/scenario-fusion-introduction-to-smart-fill#section1167564853816).
4. For details about the supported data sources, please refer to [Data Sources and Logic of Suggestions](https://developer.huawei.com/consumer/en/doc/harmonyos-guides/scenario-fusion-intelligentfilling-explain).

## Project Directory
```
entry
  └─src                     
    ├─main                
    │  ├─ets              
    │  │  ├─entryability         // Entry point class
    │  │    ├──EntryAbility.ets   // Ability for local startup
    │  │  └─pages
    │  │    ├──Index.ets         // Main UI
    │  │    ├──Demo.ets          // Demo
    │  │    ├──ShipToAddress.ets // Shipping address
    │  │    └──PurchaseTicket.ets// Ticket purchase
    │  └─resources        
    │      ├─base         
    │      │  ├─element          // Resources such as color, font, and character strings
    │      │  ├─media            // Resources such as images 
    │      │  ├─media            // Page configuration
```  

## How to Implement

The SmartFill demo is provided in **\entry\src\main\ets\pages\Index.ets**. The **contentType** attribute has been set for these input components. When any of these buttons is tapped, SmartFill will be triggered.

## Required Permissions

None

## Dependencies

For details, please refer to the [development guide](https://developer.huawei.com/consumer/en/doc/harmonyos-guides/scenario-fusion-introduction-to-smart-fill).

## Constraints

1. The sample app is only supported on phones, 2-in-1 and tablets with standard systems.
2. This sample demonstrates the stage model.
3. This sample app needs to run in DevEco Studio 5.0.0 Release.