# Posting an Image Comment

### Overview

This sample shows how to post a comment on an image by starting the system camera.

### Preview
<img src="screenshots/ImageComment.en.png" width="300px">

### How to Use

1. Open the app. Touch the text box, and then touch the camera button to start the system camera.

2. Take a photo, return the app page, and touch the button to post it.

### Project Directory
```
├──entry/src/main/ets
│  ├──commmon
│  │  └──CommonConstants.ets       // Common constants                            
│  ├──entryability  
│  │  └──EntryAbility.ets          // Entry ability
│  ├──model
│  │  ├──CommentModel.ets          // Comment class
│  │  └──MockCommentData.ets       // Comment data
│  ├──pages                                     
│  │  └──Index.ets                 // Home page
│  ├──utils                                 
│  │  └──CameraUtils.ets           // Start the camera
│  └──view
│     ├──CommentInputDialog.ets    // Post comment dialog box
│     ├──CommentItemView.ets       // Comment components
│     └──ImageListView.ets         // Comment image list
└──entry/src/main/resources        // Static resources
```

### Required Permissions

N/A

### Constraints

1. The sample app is supported only on Huawei phones running the standard system.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.
