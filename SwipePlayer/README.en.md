# Realize smooth on-demand of short videos
## Brief introduction
This scenario mainly focuses on smooth on-demand switching of short videos, providing the ability to slide up and down of short videos, quickly start playback, dynamically add data sources, customize components to follow the video slide, customize sliding component switching, full screen and pop-up, etc. At the same time, through the opening of customization capabilities, it meets the business needs of different short video sliding scenarios for applications. Developers can use SwipePlayer to support this feature
The library quickly realizes a smooth sliding scene development experience for short videos, which can focus more on the development of practical scene businesses.

## Preview image effect

| Vertical screen page                              | Comment page                                      | Landscape page                                 |
|---------------------------------------------------|---------------------------------------------------|------------------------------------------------|
| <img src="./screenshots/display.gif" width="320"> | <img src="./screenshots/comment.gif" width="320"> | <img src="./screenshots/full.gif" width="320"> | 


## Main module structure of the project
```typescript
├──entry/src/main/ets/
│  │──constants                        // constants
│  │  ├──AdvertConstants.ets           // Advertising page resource constant
│  │  ├──CommonConstant.ets            // Resource constant
│  │  └──TabConstants.ets              // Tag Bar Resource Constants
│  ├──entryability
│  │  └──EntryAbility.ets              // Ability's lifecycle callback content
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets        // The lifecycle callback content of ExitBackupAbility
│  ├──model
│  │  ├──CommonModel.ets               // Page public methods
│  │  └──CommonUtils.ets               // Component Common Method
│  ├──pages
│  │  └──Index.ets                     // Main page
│  └──screen                           // page
│     ├──Advert.ets                    // Advertising page
│     ├──CommentsDetails.ets           // Comment section list page
│     ├──Comments.ets                  // Comment page
│     ├──FastSpeed.ets                 // Double speed pop-up page
│     ├──FullScreenComponent.ets       // Landscape page
│     ├──TabButton.ets                 // Button tab
│     ├──TopTabButton.ets              // Top tab
│     └──ViewScreenComponent.ets       // Vertical screen page
└──entry/src/main/resources            // Application static resource directory
```

## Related permissions
Network permission: ohos. permission Internet, used to load network video scenes.

## Rely on
This solution uses the third-party library swipePlayer. In case of missing dependencies, you can download ohpm i @ hadss/swipeplayer through the command

## Constraints and limitations
1.This example only supports running on standard systems and supports devices such as Huawei phones.

2.HarmonyOS system: HarmonyOS NEXT Release and above.

3.DevEco Studio version: DevEco Studio NEXT Release and above.

4.HarmonyOS SDK version: HarmonyOS NEXT Release SDK or above.