# Application UI Optimization Based on Component Reuse

### Overview

The HarmonyOS application framework provides the component reuse capability. When a reusable component is removed from the component tree, it enters a recycling buffer. When a new component node is created, the node in the buffer is reused, saving the time for recreating the component.

### Preview

| Reducing Component Reuse Nesting                            | Precisely Controlling the Component Update Scope                             |
|-----------------------------------------|-----------------------------------------|
| ![image](screenshots/device/mode_1_EN.gif)| ![image](screenshots/device/mode_2_EN.gif)|

| Using reuseId to Mark Different Components                       | Using @State as Input Parameter for Reusable Components                       |
|-----------------------------------------|-----------------------------------------|
| ![image](screenshots/device/mode_3_EN.gif)| ![image](screenshots/device/mode_4_EN.gif)|

#### How to Use

#### Choose entry module to Run
1. Tap **Reducing component reuse nesting** to enter **Nearby people** on the level-2 page, and slide the list.
2. Tap **Precisely controlling the component update scope** to enter **Text list** on the level-2 page, and slide the list.
3. Tap **Using reuseId to mark different components** to enter **Image-text list** on the level-2 page, and slide the list.
4. Tap **Using @State as input parameter for reusable components** to enter **Username list** on the level-2 page, and slide the list.

#### Choose negative or positive module to Run
You can use the Tools-AppAnalyzer health check tool,
Verification Best Practices [Component Reuse Issue Diagnosis and Analysis](https://developer.huawei.com/consumer/cn/doc/best-practices/bpta-component-reuse-issue-diagnosis-and-analysis)
negative examples or positive examples in code.

### Project Directory

``` 
├──entry/src/main/ets                          
│  ├──common
│  │  ├──CommonConstants.ets            // Component reuse DataSource class
│  │  ├──Constants.ets                  // Common constants
│  │  └──GlobalBuilderContext.ets       // Caching the global @Builder
│  ├──entryability
│  │  └──EntryAbility.ets               // Entry ability
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets         // Custom application data conversion and migration template
│  ├──model                              
│  │  ├──BasicDataSource.ets            // Basic data adapter
│  │  ├──ColorData.ets                  // Data adapter of Text list on the level-2 page
│  │  └──FriendMomentData.ets           // Data adapter of Nearby people, Image-text list, and Username list on the level-2 page
│  ├──pages
│  │  ├──ImproveReuseHitRate.ets        // Improve reuse HitRate
│  │  ├──Index.ets                      // Home page
│  │  ├──ReuseNested.ets                // Reuse nested
│  │  └──UseComponentReuse.ets          // Use component reuse
│  └──view        
│     ├──OneMoment.ets                  // Each item UI in Nearby people on the level-2 page
│     ├──PageListSlideToHistory.ets     // Nearby people UI on the level-2 page                   
│     ├──UpdaterComponent.ets           // Text list UI on the level-2 page   
│     ├──WithFuncParam.ets              // Username list UI on the level-2 page
│     └──WithReuseId.ets                // Image-text list UI on the level-2 page
└──entry/src/main/resources             // Static resources
```

### Required Permissions

N/A

### Constraints

* This sample is supported only on Huawei phones running the standard system.
* The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.
* The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.
* The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.

### Download

To download this project separately, execute the following command:
```
git init
git config core.sparsecheckout true
echo ComponentReuse/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```
