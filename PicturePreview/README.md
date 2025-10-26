# 基于ArkUI实现图片预览功能

### 简介
本示例是基于ArkUI接口和swiper组件实现的图片预览应用，其功能包括图片的切换、图片的缩放，同时支持通过双击图片实现放大或缩小的效果，并且在图片被放大后，可以对图片进行滑动查看，当图片滑动到边界时，可切换图片。

### 效果预览
![image](screenshots/device/PicturePreview_CN.gif)

### 工程目录
```
├──entry/src/main/ets                            // 代码区
│  ├──entryability
│  │  └──EntryAbility.ets                        // 本地启动ability      
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets                     
│  ├──model
│  │  └──CommonModel.ets                         // 公共实体类        
│  ├──pages
│  │  └──HomePage.ets                            // 主页面    
│  ├──utils
│  │  └──CommonUtils.ets                         // 公共工具类
│  └──view
│     ├──ImageItemView.ets                       // 主图模块
│     └──ThumbnailView.ets                       // 缩略图模块
└──entry/src/main/resources                      // 资源文件目录
```

### 使用说明
1. 左右滑动/点击页面下方缩略图，主图图片会随之变化。
2. 轻触页面，开启图片预览模式。
3. 双击图片可切换其大小，在预览模式下再次双击，图片恢复至默认尺寸。
4. 双指轻捏图片，即可轻松实现缩放操作。
5. 在图片预览模式下，左右滑动页面中的图片，即可切换至下一张或上一张图片。

### 具体实现
1. 使用matrix实现图片的缩放。

   ```
   @State matrix: matrix4.Matrix4Transit = matrix4.identity().copy();
   
   Image(this.imageData)
     .transform(this.matrix)
   ```

2. 使用translate属性对图片进行偏移。

   ```
   @State curOffsetX: number = 0;
   @State curOffsetY: number = 0;
   
   Image(this.imageData)
     .translate({
       x: this.imageModel.curOffsetX,
       y: this.imageModel.curOffsetY
     })
   ```

3. Image的objectFit属性设置为Cover，锁定图片宽高比，并使其能够超出父组件边界显示。

   ```
   Image(this.imageData)
     .objectFit(ImageFit.Cover)
   ```

4. Swiper组件实现页面图片的左右滑动。

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
   
### 相关权限
不涉及

### 约束与限制
1. 本示例仅支持标准系统上运行，支持设备：华为手机。
2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。