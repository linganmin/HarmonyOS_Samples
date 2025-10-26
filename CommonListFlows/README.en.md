# Implementing Common List Stream Scenarios Using the List Component

## Overview
The list stream is a layout form that arranges content in units of rows. Each row of list items efficiently displays structured information through combinations of text, images, and other forms. List streams feature neat typesetting, highlighted key points, convenient comparison, and fast browsing. The List component is used to linearly arranges child components such as ListItemGroup or ListItem in the vertical direction. It can render a mix of unlimited text and image views to build the list content.

This topic showcases the following four common list stream scenarios:
* Multi-type list item pinning
* Tab pinning
* Group-based pinning
* Linked scrolling lists

## Preview
| Multi-type List Item Pinning           | Tab Pinning                              |
|----------------------------------------|------------------------------------------|
| ![](screenshots/divice/homePageEN.gif) | ![](screenshots/divice/managerPageEN.gif)  |
| Group-based Pinning                    | Linked Scrolling Lists                   |
| ![](screenshots/divice/cityListEN.gif)   | ![](screenshots/divice/categoryPageEN.gif) |


## Project Directory
```
├──entry/src/main/ets                                   // Code area
│  ├──entryability
│  │  └──EntryAbility.ets                               // Entry ability
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  ├──pages                              
│  │  ├──Index.ets                                      // Home page 
│  │  ├──CategoryPage.ets                               // Page with Linked scrolling lists
│  │  ├──CityList.ets                                   // Group-based pinning page 
│  │  ├──CustomListItem.ets                             // List items with tab pinning
│  │  ├──HomePage.ets                                   // Multi-type list item pinning page
│  │  └──ManagerPage.ets                                // Tab pinning page
│  └──model 
│     └──LinkDataModel.ets                              // Data of the dual-level linkage
└──entry/src/main/resources                             // Application resources
```

## How to Use

The sample code involves the following scenarios:

* Multi-type list item pinning: Enter the page and swipe down to refresh the page. Continuously swipe down the page content, title of each list item is pinned to the top in sequence. Swipe up the bottom of the page to request for loading list data.
* Tab pinning: Swipe down the page and tabs Follow, Recommended, Hot, or More are pinned on the top of the screen.
* Group-based pinning: Swipe the city list on the left, and each item title is pinned on the top and highlighted together with the corresponding initial letter in the alphabetical navigation list on the right. Tap any letter on the alphabetical navigation bar and the corresponding city content is displayed.
* Linked scrolling lists: Tap any item on the navigation bar on the left and the corresponding content is displayed on the right. Swipe the item list on the right, and each product category title is pinned on the top and highlighted together with the corresponding item on the navigation bar.

## Permissions

N/A

## Constraints

* The sample is only supported on Huawei phones with standard systems.
* The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.
* The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.
* The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.