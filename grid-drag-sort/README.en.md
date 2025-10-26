# Dragging Grid Items

## Overview

The dragging of grid items is implemented using the **Grid** container component, combined gestures, and explicit animation. The **Grid** container component constructs the layout of grid items, combined gestures implement the dragging effect, and explicit animation adds an animation effect for dragging.
This sample implements four grid item dragging scenarios: dragging grid items of the same size, dragging grid items of different sizes, direct dragging of grid items, and jittering of grid items.

## Preview
![](/screenshots/device/phone_en.gif)

## Project Directory

```
├──entry/src/main/ets                                   // Code area
│  ├──entryability
│  │  └──EntryAbility.ets                               // Entry ability
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  └──pages
│     ├──DifferentItemDrag.ets                          // Page for dragging items of different sizes
│     ├──DirectDragItem.ets                             // Page for directly dragging items
│     ├──Index.ets                                      // Home page
│     ├──JitterAnimation.ets                            // Jitter animation page
│     └──SameItemDrag.ets                               // Page for dragging items of the same size
└──entry/src/main/resources                             // App resource directory
```

## How to Use
The sample code involves the following scenarios:
* Dragging grid items of the same size

When editing 9-square grid items, you can long press an image (grid item) to change its order. During dragging, adjacent images are moved in real time, and a new grid is generated.
* Dragging grid items of different sizes

In some scenarios of displaying devices, there are grid items of different sizes. If you want to reorder the devices, you may long press and drag a device image (grid item). During dragging, the device order is changed, and a new grid layout is generated.
* Direct dragging of grid items

In certain scenarios, you can enable direct dragging to drag an item without long pressing it.
* Jittering of grid items

On the device list page, if you want to remove a device, select the device and long press it to edit the grid item. In this case, the device image jitters.

## Permissions

N/A

## Constraints

* The sample is only supported on Huawei phones with standard systems.

* The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

* The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

* The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.