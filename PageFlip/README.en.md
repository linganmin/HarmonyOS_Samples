# Page Flip Effect

## Overview

This sample implements the page effects of up-down flip, left-right flip, and simulated flip based on explicit animations, the **List** component, and drawing APIs.

## Effect

<img src="./screenshots/device/page_flip.en.webp" width="320">

### How to Use

- The simulated flip is set by default. Swipe the screen with your finger like flipping through a real book or tap the left or right side of the screen to flip pages. You can tap the middle of the screen to display filp options.
- Select up-down flip and swipe up or down to browse the content.
- Select left-right flip and swipe left or right or tap the left or right side of the screen to turn pages.

## Project Directory

```
├──entry/src/main/ets/ 
│  ├──common 
│  │  └──Constants.ets               // Common constants 
│  ├──entryability 
│  │  └──EntryAbility.ets            // Application entry 
│  ├──pages 
│  │  └──Index.ets                   // Home page 
│  ├──view 
│  │  ├──BottomView.ets              // Button dialog box 
│  │  ├──CoverFlipPage.ets           // Left-right flip 
│  │  ├──EmulationFlipPage.ets       // Simulated flip 
│  │  ├──ReaderPage.ets              // Text page 
│  │  └──UpDownFlipPage.ets          // Up-down flip 
│  └──viewmodel 
│     ├──BasicDataSource.ets         // List data 
│     └──PageNodeController.ets      // Node control 
└──entry/src/main/resource           // Static resources of the application
```

## How to Implement
1. Use the **List** component to implement up-down flip, and use component displacement and **animateTo** to implement left-right flip.
2. Use the **@ohos.graphics.drawing** API and the **NodeContainer** component of ArkGraphics 2D to render the simulated flip effect. That is, calculate the edge nodes of the simulated page based on the touch point position and fill the flip area.

## Required Permissions
N/A

## Constraints
1. This sample is only supported on Huawei phones and tablets with standard systems.
2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.
3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.
4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.

