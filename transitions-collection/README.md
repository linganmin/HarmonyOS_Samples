# 实现转场动效功能合集

### 介绍

本示例基于基础组件、通用属性、显式动效，实现多模态页面转场动效以及多种常见一镜到底转场动效，便于用户进行常见的转场动效场景开发。

### 效果预览

|               多模态页面转场动效                |               搜索一镜到底转场动效                |              卡片一镜到底转场动效               |
|:--------------------------------------:|:---------------------------------------:|:-------------------------------------:|
| ![image](screenshots/device/model.gif) | ![image](screenshots/device/search.gif) | ![image](screenshots/device/card.gif) |
|             **图片一镜到底转场动效**             |             **视频一镜到底转场动效**              |            **列表一镜到底转场动效**             |
| ![image](screenshots/device/image.gif) | ![image](screenshots/device/video.gif)  | ![image](screenshots/device/list.gif) |
|            **图书翻页一镜到底转场动效**            |
| ![image](screenshots/device/book.gif)  |

**使用说明**

点击各个模块下的选项进行跳转，进入到对应的转场动效场景：
1. 点击多模态页面转场动效实现案例，跳转半模态登录页面。在半模态窗口中选中同意协议键，并点击获取验证码按钮，跳转至手机验证码登录页面。通过点击手机验证码登录页面中的"账号密码登录"，向右切换跳转至账号密码登录页面，通过点击账号密码登录页面中的"手机验证码登录"，向左切换跳转至手机验证码登录页面。
2. 点击搜索一镜到底，进入搜索页面。点击搜索框后进行一镜到底的动效进入搜索页。
3. 点击卡片一镜到底，进入卡片页面。点击页面中的卡片后进行一镜到底的动效进入详情页。
4. 点击图片一镜到底，会弹出菜单选项：双指放大、查看大图和半模态。点击双指放大进入页面，在图片使用双指外扩的手势，图片会放大。点击查看大图进入页面会看到9张图片，点击图片后可以查看大图。点击半模态进入页面，点击页面中的图片会进入到半模态弹窗内。
5. 点击视频一镜到底，进入视频页面。点击视频进入到视频详情页，播放视频。
6. 点击列表一镜到底，进入列表页面。点击列表中的某一项进入详情页。
7. 点击图书翻页一镜到底，进入书架页面。点击书籍进入书籍详情页。

### 具体实现
```
├──entry/src/main/ets/
│  ├──common
│  │  ├──Constants.ets                                     // 公共常量类
│  │  └──CustomExceptions.ets                              // 自定义异常类
│  ├──entryability
│  │  └──EntryAbility.ets                                  // 程序入口类
│  ├──feature
│  │  ├──BookFlipLongTakeTransition                        // 图书翻页一镜到底转场
│  │  │  ├──BookFlipLongTakeTransitionPageOne.ets
│  │  │  └──BookFlipLongTakeTransitionPageTwo.ets
│  │  ├──CardLongTakeTransition                            // 卡片一镜到底转场
│  │  │  ├──CardComponent.ets
│  │  │  ├──CardLongTakeTransitionPageOne.ets
│  │  │  ├──CardLongTakeTransitionPageTwo.ets
│  │  │  └──DetailPageContent.ets
│  │  ├──ImageLongTakeTransition                           // 图片一镜到底转场
│  │  │  ├──PinchToShareImage                              // 双指缩放图片一镜到底转场
│  │  │  │  ├──ImageGalleryNode.ets
│  │  │  │  ├──ImageWithGesture.ets
│  │  │  │  ├──PinchToShareImagePageOne.ets
│  │  │  │  └──PinchToShareImagePageTwo.ets
│  │  │  ├──SemiModalImage                                 // 半模态图片一镜到底转场
│  │  │  │  ├──CustomComponent.ets
│  │  │  │  └──Index.ets
│  │  │  └──ShowLargeImageWithGesture                      // 点击查看大图一镜到底转场
│  │  │     ├──MyComponent.ets
│  │  │     ├──ShowLargeImageWithGesturePageOne.ets
│  │  │     └──ShowLargeImageWithGesturePageTwo.ets
│  │  ├──ListLongTakeTransition                            // 列表一镜到底转场
│  │  │  ├──ListLongTakeTransitionPageOne.ets
│  │  │  └──ListLongTakeTransitionPageTwo.ets
│  │  ├──MultiModalTransition                              // 多模态一镜到底转场
│  │  │  ├──AccountLogin.ets
│  │  │  ├──CaptchaLogin.ets
│  │  │  └──HalfModalWindow.ets
│  │  ├──SearchLongTakeTransition                          // 搜索框一镜到底转场
│  │  │  ├──SearchLongTakeTransitionPageOne.ets
│  │  │  └──SearchLongTakeTransitionPageTwo.ets
│  │  └──VideoLongTakeTransition                           // 视频一镜到底转场
│  │     ├──CustomNavigation
│  │     │  ├──CustomNavigationPageOne.ets
│  │     │  ├──CustomNavigationPageTwo.ets
│  │     │  └──VideoCard.ets
│  │     ├──AVPlayerManager.ets
│  │     ├──NodeController.ets
│  │     └──VideoNode.ets
│  ├──pages                  
│  │  └──Index.ets                                         // 首页
│  ├──utils
│  │  ├──commonutils                                       // 公用工具方法
│  │  │  ├──CardUtil.ets 
│  │  │  ├──ComponentAttrUtils.ets 
│  │  │  ├──ExtraInfo.ets 
│  │  │  ├──ResourceString.ets 
│  │  │  └──WaterFlowDataSource.ets
│  │  ├──customtransition                                  // 自定义过度动画
│  │  │  ├──BookFlipLongTakeTransitionProperties.ets 
│  │  │  ├──CustomNavigationUtils.ets 
│  │  │  ├──LongTakeAnimationProperties.ets
│  │  │  ├──PrePageInteractiveTransitionProperties.ets
│  │  │  ├──SnapShotImage.ets
│  │  │  └──VideoLongTakeAnimationProperties.ets
│  │  └──windowutils                                       // 页面相关方法类
│  │     ├──WindowUtility.ets
│  │     └──WindowUtils.ets
│  └──viewmodel
│     └──ListItemProp.ets                                  // 首页数据模型
└──entry/src/main/resources                                // 应用静态资源目录
```

### 具体实现

1. 多模态页面转场动效实现案例：通过bindSheet属性为主页无样式的Text绑定半模态页面，再通过bindContentCover属性为主页无样式的Text绑定全屏模态页面。通过点击半模态中的按钮跳转到全屏模态组件(CaptureLogin)，并通过isDefaultLogin控制两种登录组件的条件渲染：true(手机验证码登录)，false(账号密码登录)，同时通过TransitionEffect.asymmetric()和TransitionEffect.move()实现组件间转场，从而实现组件转场类似页面转场的效果。
2. 搜索一镜到底：将搜索框首页与搜索框页面的Search组件同时设置geometryTransition属性，并绑定同一id值。设置显式动画和transition属性的过渡效果，实现搜索框的一镜到底效果。
3. 卡片一镜到底：使用WaterFlow和LazyForEach实现卡片列表瀑布流。利用Navigation的自定义导航转场动画能力，通过customNavContentTransition配置列表页与详情页的自定义导航转场动画，结合componentSnapshot将卡片进行截图避免跳转页面白屏。
4. 图片一镜到底：
   * 双指放大：通过NodeContainer自定义占位节点，利用NodeController实现组件的跨节点迁移，配合属性动画给组件的迁移过程赋予一镜到底效果。
   * 查看大图：设置geometryTransition属性将图片首页和大图页面的图片绑定同一id值，结合动画效果实现一镜到底效果。
   * 半模态：利用NodeController实现组件的跨节点迁移，将半模态SheetOptions中的mode设置为SheetMode.EMBEDDED。通过属性动画，展示组件从初始界面至半模态页面的一镜到底动效，并在动画结束时关闭页面，并将该组件迁移至半模态页面。
5. 视频一镜到底：使用WaterFlow和LazyForEach实现卡片列表瀑布流。利用NodeController实现组件的跨节点迁移，通过customNavContentTransition配置视频与详情页的自定义导航转场动画，给节点的迁移过程赋予一镜到底效果。
6. 列表一镜到底：将列表项与详情页面同时设置geometryTransition属性，并绑定同一id值。每个列表项设置显式动画和transition属性的过渡效果，实现列表展开的一镜到底效果。
7. 图书翻页一镜到底：利用Navigation的自定义导航转场动画能力，通过customNavContentTransition配置书籍页与详情页的自定义导航转场动画实现图书翻页一镜到底效果。

### 相关权限

不涉及。

### 约束与限制

1.本示例仅支持标准系统上运行，支持设备：华为手机。

2.HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3.DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4.HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。