# Smooth Page Slipping
## Overview
This sample shows how to complex, smooth scrolling pages that ensure no frame drops during page transitions or scrolling.
## Preview
![](./screenshots/device/page_slip.en.gif)
## Project Directory
```
├──ets
│  ├──constants
│  │  ├──BreakpointConstants.ets       // Breakpoint constants.
│  │  ├──CommonConstants.ets           // Common constants.
│  │  └──HomeConstants.ets             // Constants for the home page.
│  ├──entryability
│  │  └──EntryAbility.ets
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  ├──model
│  │  ├──FooterTabData.ets             // Data related to the footer tab
│  │  ├──FunctionEntryData.ets         // Data for function entries
│  │  ├──FunctionEntryListData.ets     // List in the function entry
│  │  ├──WaterFlowData.ets             // Data related to water flow
│  │  ├──WaterFlowDescriptionData.ets  // Descriptive data for water flow
│  │  ├──WaterFlowHeadData.ets         // Header information for water flow data
│  │  └──WaterFlowListData.ets         // List of water flow data entries
│  ├──pages
│  │  └──Index.ets                     // Page entry
│  ├──utils
│  │  ├──BreakpointSystem.ets          // Utility for listening for breakpoints
│  │  ├──BreakpointType.ets            // Utility for managing breakpoint types
│  │  ├──CollectionsCountModifier.ts   // Utility for updating data on demand
│  │  ├──Logger.ts                     // Logging utility
│  │  └──NetworkUtil.ets               // Utility for network requests
│  └──view
│     ├──FunctionView.ets              // View for the functional area of the app
│     ├──HomeContent.ets               // Main content view for the home page
│     ├──IndexNavDestination.ets       // Entry to the navigation bar
│     ├──NavigationBarView.ets         // View for the navigation bar
│     ├──SearchBarView.ets             // View for the search bar
│     ├──WaterFlowDescriptionView.ets  // View for the description at the bottom of a waterfall flow item
│     ├──WaterFlowImageView.ets        // View for the image description of a waterfall flow item
│     ├──WaterFlowLivingView.ets       // View for the live description of a waterfall flow item
│     ├──WaterFlowVideoView.ets        // View for the video description of a waterfall flow item
│     └──WaterFlowView.ets             // Main view for the waterfall flow
└──resources                            // Resources of the app
```
## How to Implement
1. Implement waterfall flows by using lazy loading and caching list items. This approach avoids the performance bottleneck caused by loading and rendering a large amount of data at once when using a list as the data source, and also prevents the white blocks that may occur when scrolling too quickly.
2. The components for the cards in the waterfall flow model are reused, eliminating the performance loss caused by frequent creation and destruction of a large number of components with the same structure.
3. During card placement, calculate the card height with a fixed aspect ratio. This prevents the card height from being measured twice after the component is rendered.
## How to Use
1. Swipe left and right on the function area.
2. The waterfall flow supports pull-down refresh and loads data in pages, ensuring no frame drops during scrolling.
## Required Permissions
- **ohos.permission.INTERNET**: allows an app to access Internet.
- **ohos.permission.GET_NETWORK_INFO**: allows an app to obtain network connection status.
## Constraints
1. The sample app is supported only on Huawei phones running the standard system.
2. The HarmonyOS version must be HarmonyOS 5.0.0 Release or later.
3. The DevEco Studio version must be DevEco Studio 5.0.0 Release or later.
4. The HarmonyOS SDK version must be HarmonyOS 5.0.0 Release or later.
