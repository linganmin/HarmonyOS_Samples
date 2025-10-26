# Component Stacking

### Overview

This sample describes how to use component stacking to build multi-layer stack visual effects. You can use the onScrollFrameBegin event callback function of the Scroll component to accurately capture the scrolling action. During scrolling, attributes such as transparency and height of the component are adjusted in real time, to implement nested scrolling effects, dynamic changing of transparency, and smooth component switching.

### Preview

![image](./screenshots/phone.eng.gif)

### How to Use

1. After the loading is complete, the entire page is displayed. You can swipe up or down to view the stacking effect.

### Project Directory

```
componentstack
├──entry/src/main/ets
│  ├──constant
│  │  └──StackConstant.ets                        // Constant class
│  ├──entryability
│  │  └──EntryAbility.ets                         // Application lifecycle class
│  ├──model
│  │  └──IconModel.ets                            // Local data source
│  ├──pages
│  │  └──Index.ets                                // Home page of component stacking
│  ├──view
│  │  ├──IconView.ets                             // Custom component of the icon shortcut 
│  │  └──ProductList.ets                          // Custom component of the product list
│  └──viewmodel
│     ├──DataSource.ets                           // List data model
│     └──IconViewModel.ets                        // Data type definition
└────entry/src/main/resources 
```

### How to Implement

1. During the upward sliding process,the head component is at the bottom of the hierarchy. Therefore, the stack component is selected to obtain the stacking effect.
2. In the scrollable area on the top, use the Scroll component to obtain the stacking effect.
3. To dynamically adjust the height of the text box during scrolling, use the scroll event callback function **onScrollFrameBegin** of the Scroll component to change the height of the text box and the transparency of the component during scrolling.
4. When multiple layers of components are nested, the parent component should be scrolled before the component itself. In the **nestedScroll** attribute of the inner Scroll component, you only need to set the nested scrolling mode in the forward and backward directions to implement the scrolling association with the parent component.
5. In the product list area, the WaterFlow container is used for layout. Product information is dynamically distributed and displayed in two columns. Products in each column are arranged from top to bottom.

### Required Permissions
N/A

### Dependencies
N/A

### Constraints

1. The sample app is supported only on Huawei phones running the standard system.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release or later.
