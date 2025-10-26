# Application UI Optimization Based on Frame-based Rendering

### Overview

During application development, the list structure on the page is complex, and each list item contains a large number of components. As a result, the nesting level is deep, the component load increases, and the drawing time increases.
This sample describes how to use frame-based rendering to improve performance in heavy-load transition and sliding scenarios. This project is used with [Frame-based Rendering in Heavy-load Scenarios](https://developer.huawei.com/consumer/en/doc/best-practices/bpta-dispose-highly-loaded-component-render).
The involved ArkUI API is [@ohos.graphics.displaySync (Variable Frame Rate)](https://developer.huawei.com/consumer/en/doc/harmonyos-references/js-apis-graphics-displaysync#displaysynccreate).

### Preview

| Transition Scenario                                            | Sliding Scenario                                         |
|--------------------------------------------------|-----------------------------------------------|
| ![image](screenshots/device/TransitionScene_EN.gif)| ![image](screenshots/device/SlidingScene_EN.gif)|

#### How to Use

1. Touch the **Transition scenario** button. After the transition animation is complete, the page is loaded and displayed.
2. Tap the **Sliding scenario** button to enter the calendar page. You can slide the page up and down smoothly.

## Project Directory

``` 
├──entry/src/main/ets                          
│  ├──common
│  │  ├──CommonConstants.ets            // Common constants
│  │  └──GlobalBuilderContext.ets       // Caching the global @Builder
│  ├──entryability
│  │  └──EntryAbility.ets               // Entry ability
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets         // Custom application data conversion and migration template
│  ├──model                              
│  │  ├──BasicDataSource.ets            // Basic data adapter
│  │  ├──MidListDataSource.ets          // MidList data adapter in the transition scenario
│  │  ├──MonthDataSource.ets            // Calendar data adapter
│  │  ├──ProductDetailSource.ets        // Bottom waterflow data adapter in the transition scenario
│  │  └──SwiperDataSource.ets           // Swiper data adapter in the transition scenario
│  ├──pages
│  │   └──Index.ets                     // Home page
│  ├──util
│  │   └──CalculationDateUtil.ets       // Calendar utility
│  └──view                        
│     ├──DateItemView.ets               // Monthly date data
│     ├──SlidingScene.ets               // Calendar UI
│     ├──TestCode.ets                   // test data
│     └──TransitionScene.ets            // Transition UI
└──entry/src/main/resources             // Application resources
``` 

### How to Implement

1. [Transition Scenario](https://developer.huawei.com/consumer/en/doc/best-practices/bpta-dispose-highly-loaded-component-render#section5987133112411)
2. [Sliding Scenario](https://developer.huawei.com/consumer/en/doc/best-practices/bpta-dispose-highly-loaded-component-render#section15195122915243)

### Required Permissions

N/A

## Constraints

* This sample is supported only on Huawei phones running the standard system.
* The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.
* The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.
* The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.

### Download

To download this project separately, execute the following command:
```
git init
git config core.sparsecheckout true
echo FramedRendering/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```
