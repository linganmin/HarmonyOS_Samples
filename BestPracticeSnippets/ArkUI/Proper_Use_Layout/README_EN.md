# **Layout optimization guidance**
## Overview
This example uses Scroll to nest a List and compares the situations where the List width is set and not set.

## Preview

<img alt="img.png" src="./screenshots/Screenshot.jpeg" width="300"/>

## Project Directory
``` 
├──entry/src/main/ets                                   // Code
│  ├──entryability
│  │  └──EntryAbility.ets                               // Entry ability
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  ├──pages                              
│  │  └──Index.ets                                      // Home page
│  └──segment
│     ├──segment1.ets                       
│     ├──segment2.ets                       
│     └──segment3.ets                              
└──entry/src/main/resources                             // Application resources
```
## Required Permissions
N/A

## Constraints
1. This sample is supported only on Huawei phones running the standard system.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.

## Download

To download this project separately, execute the following command:
```
git init
git config core.sparsecheckout true
echo Proper_Use_Layout/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```
