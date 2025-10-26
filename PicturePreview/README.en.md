# Image Preview Based on ArkUI

### Introduction
This sample demonstrates how to use ArkUI APIs and the **Swiper** component to implement an image preview application, which features image switching and zoom functionalities, with the support for zooming in/out via double-tap gestures, panning capability to explore details in zoomed-in mode, and automatic image switching upon swiping to the edge during panning.

### Preview
![image](screenshots/device/PicturePreview_EN.gif)

### Project Directory
```
├──entry/src/main/ets                            // Code area 
│  ├──entryability 
│  │  └──EntryAbility.ets                        // Ability for local startup 
│  ├──entrybackupability 
│  │  └──EntryBackupAbility.ets                      
│  ├──model 
│  │  └──CommonModel.ets                         // Common entities 
│  ├──pages 
│  │  └──HomePage.ets                            // Home page 
│  ├──utils 
│  │  └──CommonUtils.ets                         // Common tools 
│  └──view 
│     ├──ImageItemView.ets                       // Main image module 
│     └──ThumbnailView.ets                       // Thumbnail module 
└──entry/src/main/resources                      // Resource files
```

### How to Use
This sample app enables users to:
1. Swipe left/right or tap the thumbnail at the bottom of the page to change the main image.
2. Tap the page to enter the image preview mode.
3. Double-tap an image to change its size, and double-tap the image again in preview mode to restore the image to the default dimensions.
4. Pinch an image with two fingers to zoom in or out.
5. Swipe left or right on an image to switch to the next or previous image in preview mode.


### How to Implement
1. Use **matrix** to resize an image.

   ```
   @State matrix: matrix4.Matrix4Transit = matrix4.identity().copy();
   
   Image(this.imageData)
     .transform(this.matrix)
   ```

2. Use the **translate** property to shift the image position.

   ```
   @State curOffsetX: number = 0;
   @State curOffsetY: number = 0;
   
   Image(this.imageData)
     .translate({
       x: this.imageModel.curOffsetX,
       y: this.imageModel.curOffsetY
     })
   ```

3. Set the **objectFit** property of the **Image** component to **Cover** to lock the image aspect ratio and allow the image to exceed the boundary of the parent component.

   ```
   Image(this.imageData)
     .objectFit(ImageFit.Cover)
   ```

4. Use the **Swiper** component to implement swipe-based image switch.

   ```
   PhotoSwiper() {
     Swiper(this.homeSwipeController) {
       ForEach(this.ImgData, (img: Resource) => {
         ImageItemView({
           imageData: img,
           isOverlay: this.isOverlay
         })
           .width('100%')
           .height('100%')
       }, (img: Resource, index: number) => JSON.stringify(img) + index)
     }
     ...
   }
   ```
   
### Required Permissions
N/A

### Constraints
1. The sample is only supported on Huawei phones with standard systems.
2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.
3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.
4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.
