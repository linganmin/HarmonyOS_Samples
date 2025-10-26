# Multi-Image Carousel
## Overview
The sample showcases a multi-image carousel feature using the Swiper component and a custom indicator.

On short video platforms, multi-image collections are commonly seen. Such a collection is composed of multiple images, which can be automatically rotated and manually switched. The progress bar at the bottom of the images adjusts accordingly as the images change.

This sample illustrates a typical UI effect.

* During automatic playback, the images transition automatically, with the progress bar at the bottom slowly advancing to match the display duration of each image.
* During manually playback, the progress bar below adjusts to indicate the incomplete or complete state of the viewing progress based on the image change.
## Preview
<img src="./screenshots/device/image_en.gif" width="320">

## Project Directory
````
├──entry/src/main/ets                                   // Core code
│  ├──common
│  │  └──CommonConstants.ets                            // Common constants
│  ├──entryability
│  │  └──EntryAbility.ets                               // Entry ability
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  ├──pages                              
│  │  └──Index.ets                                      // Multi-image carousel page
│  └──utils.ets
│     └──DataSource.ets                                 // Image data resource class
└──entry/src/main/resources                             // Static resources
````
## How to Use
Open the app. If you do not swipe on the screen, the images are automatically rotated, and the progress bar at the bottom slowly fills up to the complete state. When the playback finishes, it will continue to loop.

When you swipe on the screen, the images switch according to the direction of the swipe. In this case, the automatic rotation and looping effects are disabled, and the progress bar at the bottom instantly fills up to the complete state.

## How to Implement
The image carousel at the top is implemented using the Swiper component.

The lower indicator is implemented by disabling the native indicator and customizing an indicator (progress bar).

The progress bar is implemented by stacking Row containers in a cascading layout. Its gradual fill animation is controlled through the animation property. Its complete and incomplete states are determined by setting the respective background colors.

## Required Permissions
N/A

## Constraints
* The sample app is supported only on Huawei phones running the standard system.


* The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.


* The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.


* The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release or later.