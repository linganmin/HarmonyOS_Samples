## Grid-based Nested Hybrid Layout

### Overview

This sample implements the nested hybrid layout of the Grid, List, and Swiper components.

### Preview

Below shows the preview effects.
#### Scenario 1: Grid and List nesting
![running](screenshots/Devices/image1_EN.gif)

#### Scenario 2: Grid and Swiper nesting
![running](screenshots/Devices/image2_EN.gif)

### How to Use

1. You can view the page effect in the previewer or on the corresponding device.

### Project Directory

```
├──entry/src/main/ets                              // Code area
│  ├──constants                                  
│  │  ├──CommonConstants.ets                       // Common constants
│  │  └──ListDataConstants.ets                     // List data constants
│  ├──entryability  
│  │  └──EntryAbility.ets 
│  ├──model  
│  │  ├──GridListDataSources.ets                   // Grid component data in scenario 1
│  │  ├──WaterFlowDataSource.ets                   // Waterfall data
│  ├──pages  
│  │  ├──GridNestListIndex.ets                     // Hybrid layout of the Grid and List components
│  │  ├──GridNestSwiperIndex.ets                   // Hybrid layout of the Grid and Swiper components                            
│  │  └──Index.ets                                 // Home page 
│  └──view
│     ├──GridComponent.ets                         // Vertical subcomponent of List in scenario 1
│     ├──GridItemComponent.ets                     // GridItem subcomponent
│     └──MenuItemComponent.ets                     // Subcomponent of Swiper in scenario 2       
└──entry/src/main/resources                        // App resource directory

```

### How to Implement

#### Scenario 1: Hybrid layout of grid and list nesting

* Set the height of each component properly. When the home page slides to the bottom, the horizontal list component is pinned to the top.
* Use two swipers to control the vertical and horizontal lists to implement association between the two lists.

#### Scenario 2: Hybrid layout of grid and swiper nesting

* Dynamically change the height of the Swiper component during sliding.


### Required Permissions

N/A

### Dependencies

N/A

### Constraints

1. The sample app is supported only on Huawei phones running the standard system.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release or later.
