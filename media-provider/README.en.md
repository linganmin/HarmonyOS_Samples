# AVSession Provider

## Overview

This sample demonstrates an app that functions as an AVSession provider. It uses @ohos.multimedia.avsession to implement custom information exchange between the provider and Media Controller.

> **NOTE**
> 
> If you want to experience E2E custom information interaction provided by AVSession, use this sample together with the system's Media Controller.

## Preview

![Index](screenshot/device/media_provider.en.gif) 

## How to Use

### Basic Operations

1. Open the sample app.
2. Touch the play button. The playback status of the app changes and the progress starts to refresh.
3. Touch the pause button. The playback status of the app changes and the progress stops refreshing.
4. Tap the previous button. The information about the previous song in the playlist is displayed.
5. Tap the next button. The information about the next song in the playlist is displayed.
6. Touch the play button and drag the progress bar. The playback progress changes.
7. Touch the favorite button. It is highlighted.
8. Touch the playback mode to switch between different playback modes. (Note: Synchronization of the playback mode with the Media Controller is implemented, but the actual playback mode feature is not.)

### Advanced Operations (Used with the Media Controller)

1. Touch the play, pause, previous, and next buttons on the sample app in sequence. The AVSession status in the Media Controller changes synchronously.
2. Touch these buttons in the Media Controller. The button status in the sample app changes synchronously.
3. Within the Media Controller, view the currently playing content, playback mode, lyrics, progress, favorite status, media asset display tag, and historical playlists of the app.

## Project Directory



```
├──entry/src/main/ets/
│  ├──common
│  │  ├──constants
│  │  │  └──Constants.ets                       // Constants
│  │  └──utils
│  │     ├──GlobalContextUtils.ets              // Global context encapsulation
│  │     ├──Logger.ets                          // Log utility
│  │     └──MediaData.ets                       // Song information
│  ├──entryability
│  │  └──EntryAbility.ets  
│  ├──model
│  │  ├──IntentExecutorImpl.ets                 // Intent execution implementation
│  │  └──mediaData.ets                          // Media data types 
│  ├──pages
│  │  └──Index.ets                              // Page implementation
│  └──viewmodel
│     └──ProviderManager.ets                    // AVSession provider status management
└───entry/src/main/resources                    // Static resources
```

## How to Implement

* The UI-related implementation is encapsulated in **pages/Index.ets**. For details about the source code, see [pages/Index.ets] (./entry/src/main/ets/pages/Index.ets).
  
  * Use `@StorageLink` to set variables that are updated synchronously with the logic code. When a variable in the logic code is updated, the UI is refreshed synchronously.
  
  * Create an object by importing the class corresponding to the logic code to respond to the **onClick** event. The key code snippet is as follows:
    
    ```ets
    import { ProviderFeature } from '../feature/ProviderFeature';
    this.providerFeature = await ProviderFeature.getInstance(); // Create a singleton.
    
    Button() {
      // Content of the button
    }
    .onClick(async () => {
      this.providerFeature.play (); // Invoke the logic code through the object of the class.
    })
    ```

* The logic-related implementation is encapsulated in **viewmodel/ProviderManger.ets**. For details about the source code, see [viewmodel/ProviderManager.ets](entry/src/main/ets/viewmodel/ProviderManager.ets).
  **App Initialization Operations**
  
  * Linking to a Variable
    Use `AppStorage.SetAndLink()` to link the variables in the logic code to the variables declared using `@StorageLink` in the UI code, and use `set()` and `get()` to modify or obtain the variable values. The key code snippet is as follows:
    
    ```ets
    private isPlayLink: SubscribedAbstractProperty<boolean> = null;
    this.isPlayLink = AppStorage.SetAndLink('IsPlaying', false);
    this.isPlayLink.set (false); // Set the value of a variable.
    let currentState: boolean = this.isPlayLink.get (); // Obtain the value of a variable.
    ```

* Creating and Setting an AVSession
  Use `createAVSession()` to create an AVSession.
  Use `activate()` to activate the AVSession.
  Use `setAVMetadata()` to set the metadata of the current media asset. After the setting, the Media Controller can read and use the metadata.
  Use `setAVPlaybackState()` to set the playback information about the current media asset, including the playback status and progress. After the setting, the Media Controller can read and use the information.
  Use `on()` to listen for control commands delivered by the Media Controller. Activate the AVSession before invoking this method.
  **App Running Operations**

* Switching Songs
  When switching songs, set the AVSession provider status and use `setAVPlaybackState()` and `setAVMetadata()` to synchronize the current playback status and metadata to the Media Controller.

* Sending Custom Data
  Use `dispatchSessionEvent()` and `setExtras()` to send custom data packets.

## Required Permissions

1. **ohos.permission.KEEP_BACKGROUND_RUNNING**: allows an app to run in the background.
   To enable the app to run or respond to commands in the background, you must request the permission **ohos.permission.KEEP_BACKGROUND_RUNNING** as follows.
   Add the following configuration to `module.json5` of the ability that needs to run in the background:
   
   ```json5
   {
      "module": {
         "requestPermissions": [
           {
              "name": "ohos.permission.KEEP_BACKGROUND_RUNNING"
           }
         ]
      }
   }
   ```
   
   Then add the code for requesting a continuous task. The sample code is as follows:
   
   ```ets
   async startContinuousTask(){
     let wantAgentInfo = {
       wants:[
         {
           bundleName: "com.samples.mediaprovider",
           abilityName:"EntryAbility"
         }
       ],
       operationType : WantAgent.OperationType.START_ABILITY,
       requestCode: 0,
       wantAgentFlags: [WantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
     };
     let want = await WantAgent.getWantAgent(wantAgentInfo);
     await backgroundTaskManager.startBackgroundRunning(globalThis.context, backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK,want);
   }
   ```

## Dependencies

If you want to experience E2E custom information interaction provided by AVSession, use this sample together with the Media Controller.

## Constraints

1. The sample is only supported on Huawei phones with standard systems.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.


