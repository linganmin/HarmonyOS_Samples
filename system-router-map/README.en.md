# Navigation System Route

## Overview

This sample provides system route verification. The system route table redirects to the page of a module (HSP/HAR), without the need to configure the dependency between different modules to jump. When a page is redirected, the page not redirected and loaded page will not be loaded. This resolves the dependency and coupling issues across different modules and the excessive loading time of the home page.

Due to environment differences, you are not advised to compile the code after downloading it. Instead, you need to create a project and compile the code by referring to the sample code.

## Preview

![image](screenshots/device/navigation_router.gif)

## How to Use

1. The home page provides a **NavIndex** navigation page. You can tap buttons to go to different pages from HARs and HSPs.

2. Each HAR or HSP page also provides buttons for jumping to other pages.

## Project Directory

```
├──entry/src/main/ets/
│  ├──common
│  │  └──utils
│  │     └──Logger.ets                          // Log printing encapsulation
│  ├──entryability
│  │  └──EntryAbility.ets                       // Program entry 
│  └──pages
│     ├──EntryPageOne.ets                       // Page 2
│     ├──EntryPageTwo.ets                       // Page 1
│     └──Index.ets                              // Page implementation
├──entry/src/main/resources                     // App resources
├──harA
├──harB
├──hspA
└──hspB
```

## How to Implement

1. Create hapA, harA, hspA, and hspB.

2. Add the route table configuration to the **module.json5** file of the target module to redirect to.

3. Create the **route_map.json** file in **resources/base/profile** of the project directory.

4. On the target page, configure the @Builder decorated entry function. The function name must be the same as the value of** buildFunction** in the **router_map.json** configuration file.

5. The application can call **pushDestinationByName** to obtain the error information about the target page.

## Required Permissions

N/A

## Constraints

1. The sample is only supported on Huawei phones with standard systems.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.

## Note

All HSP modules need to be referenced during running. Tap **Run** > **entry** to start building your app or service after completing running settings.
