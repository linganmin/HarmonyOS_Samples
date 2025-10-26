# **Drawing self drawing performance improvement**
## Overview
Canvas component is a component used to display self drawn content, which has the characteristics of preserving historical drawn content and incremental drawing. Canvas has two sets of APIs, CanvasRendering Context2D/Offscreen CanvasRendering Context2D and DrawingRendering Context2D. Content drawn by applications using both drawing APIs can be displayed on the bound Canvas component. CanvasRendering Context2D encapsulates the Native Drawing interface according to W3C standards, making it easy and fast to reuse the drawing logic of web applications. Therefore, it is very suitable for scenarios such as web applications and games, rapid prototyping, data visualization, online drawing boards, teaching tools, or creative applications.

## Preview

<img alt="img.png" src="./screenshots/Screenshot.png" width="300"/>

## Instructions for Use
- Click the "Begin Draw" button at the bottom of the page to draw a transparent hollow circle.

## Project Directory
``` 
├──entry/src/main/cpp
│  ├──common
│  │  └──log_common.h
│  ├──types/libndkDrawing
│  │  ├──Index.d.ts
│  │  └──oh-package.json5
│  ├──CMakeLists.txt
│  └──native_bridge.cpp                                 // The Native side exposes the drawing interface nativeOnDraw for the front end to call.
├──entry/src/main/ets                                   // Code
│  ├──entryability
│  │  └──EntryAbility.ets                               // Entry ability
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  ├──pages                              
│  │  └──Index.ets                                      // Home page
│  └──views
│     ├──GlassCoverView.ets                       
│     └──Index.ets                                 
└──entry/src/main/resources                             // Application resources
```
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
echo NdkDrawing/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```
