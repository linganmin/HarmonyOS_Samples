# **Optimization for Time-Consuming Operations in the Main Thread**
## Overview
In application development practices, it is important to effectively prevent the main thread from performing redundant and time-consuming operations. This can effectively reduce the load of the main thread and speed up the UI response. In scenarios where high-frequency callbacks are frequently triggered in a short period of time, time-consuming operations in the APIs need to be avoided to ensure that the main thread is not occupied for a long time. This prevents UI rendering from being blocked to avoid frame freezing or frame loss.
This sample describes common redundant operations, common high-frequency callback scenarios, and other main thread optimization methods during development.

## Project Directory
``` 
├──entry/src/main/ets                                   // Code
│  ├──common
│  │  └──Item.ets                                       // Common items
│  ├──entryability
│  │  └──EntryAbility.ets                               // Entry ability
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  ├──pages                              
│  │  └──Index.ets                                      // Home page
│  └──views.ets
│     ├──ConditionalRendering.ets                       // Conditional rendering
│     ├──GetStrOfId.ets                                 // ID resources
│     ├──GetStrOfResource.ets                           // Resources
│     ├──NegativeOfGrid.ets                             // Negative example of component reuse
│     ├──NegativeOfLazyForEach.ets                      // Negative example of repeated rendering
│     ├──NegativeOfOnScroll.ets                         // Time-consuming operations in the high-frequency callback
│     ├──NegativeOfProperty.ets                         // Negative example of component properties
│     ├──NoRedundantOperation.ets                       // No redundant operations
│     ├──PositiveOfGrid.ets                             // Positive example of component reuse
│     ├──PositiveOfLazyForEach.ets                      // Positive example of repeated rendering
│     ├──PositiveOfOnScroll.ets                         // No time-consuming operations in the high-frequency callback
│     ├──PositiveOfProperty.ets                         // Positive example of component properties
│     ├──RedundantOperation.ets                         // Redundant operations
│     ├──UseAsync.ets                                   // Using asynchronous mode
│     ├──UseTaskPool.ets                                // Using multiple threads
│     └──WaterFlowDataSource.ets                        // Waterflow lazy loading data source
└──entry/src/main/resources                             // Application resources
``` 
## How to Use
The negative example of avoiding redundant operations includes printing redundant logs, tracing, and invoking callbacks without service code in the release version, reducing performance.

In the preceding examples, time-consuming operations should be avoided in the following common high-frequency callback scenarios:
* High-frequency event callback
* Component reuse callback
* Component lifecycle callback
* Repeated rendering
* Component properties

In the negative example, time-consuming operations are performed in the preceding high-frequency events, reducing performance.

The negative example of avoiding using time-consuming APIs uses APIs without specified resource IDs. As a result, the time consumption increases and the performance is affected.

In the positive example of using multiple threads, the page rendering speed is accelerated and the performance is improved.
## Required Permissions
N/A

## Constraints
* This sample is supported only on Huawei phones running the standard system.

* The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

* The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

* The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.

## Download

To download this project separately, execute the following command:
```
git init
git config core.sparsecheckout true
echo AvoidTimeComsume/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```
