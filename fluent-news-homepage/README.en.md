# Smooth Homepage News Feeds

### Overview
This sample guides news page developers in building a news home page from scratch, including common functions such as address selection, dynamic icons and smooth animations for switching between tabs and tab content, pull-down refresh and pull-up loading, and feed stream on the home page.

### Preview

<img src='screenshots/device/NewsDemo.en.gif' width='320'>

How to Use

1. Obtain the permission to read the geographical location.
2. Tap the location information to go to the address page and modify the current location.
3. Tap a tab on the top or swipe to switch between pages. The tabs are switched synchronously.
4. Tap the tab at the bottom to switch between tabs. 
5. Pull down to refresh the page.
6. Pull up to load page information.
7. Tap the button in the lower right corner to return to the top.


### Project Directory
```
├──entry/src/main/ets/
│  ├──common
│  │  └──lottie                    // Animation
│  ├──constants
│  │  ├──BreakpointConstants.ets   // Breakpoint constants
│  │  ├──CommonConstants.ets       // Common constants
│  │  └──HomeConstants.ets         // Home page constants
│  ├──entryability
│  │  └──EntryAbility.ets          // Lifecycle callback content of an ability
│  ├──pages
│  │  ├──CitySearch.ets            // City search
│  │  └──Index.ets                 // Home page
│  ├──util                  
│  │  ├──BreakpointType.ets        // Breakpoint type
│  │  └──ResourceUtil.ets          // Route data
│  ├──view                  
│  │  ├──CityView.ets              // City list component
│  │  ├──Home.ets                  // Home page component
│  │  ├──HomeContent.ets           // Tab content component
│  │  ├──HomeHeader.ets            // Home page header component
│  │  ├──NewsChannel.ets           // News channel component
│  │  ├──PullToRefreshNews.ets     // Pull to refresh the news component.
│  │  ├──SearchView.ets            // Search component
│  │  └──TabBar.ets                // Tab bar component
│  └──viewmodel                  
│     ├──CityDetailData.ets        // Detailed city data
│     ├──NewsData.ets              // News data
│     ├──NewsDataSource.ets        // News data source
│     ├──NewsTypeModel.ets         // News type model
│     └──NewsViewModel.ets         // News view model
└──entry/src/main/resources        // Static resources of the app
```

### Dependencies
This sample uses the third-party libraries lottie and pulltorefresh. If either of them is missing, you can download the libraries in CLI mode.<br>
ohpm install @ohos/pulltorefresh<br>
ohpm install @ohos/lottie<br>


### Required Permissions

Obtain location permissions: ohos.permission.APPROXIMATELY_LOCATION and ohos.permission.LOCATION.

### Constraints

1. The sample app is supported only on Huawei phones running the standard system.

2. The HarmonyOS version must be HarmonyOS 5.1.0 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.1.0 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.1.0 Release or later.
