# 多设备便捷生活界面

### 简介

本篇Sample基于自适应布局和响应式布局，实现一次开发，多端部署的便捷生活页面，并根据手机、折叠屏、平板以及PC/2in1不同的设备尺寸实现对应页面。

手机运行效果图如下：

![](screenshots/device/phone.png)

折叠屏运行效果图如下：

![](screenshots/device/foldable.png)

平板、PC/2in1运行效果图如下：

![](screenshots/device/2in1.png)

## 工程目录结构

```
├──entry/src/main/ets                               // 代码区
│  ├──constants  
│  │  ├──BreakpointConstants.ets                    // 断点常量类
│  │  ├──CommonConstants.ets                        // 公共常量类 
│  │  ├──DishDetailConstants.ets                    // 商品详情页常量类
│  │  ├──FoodListConstants.ets                      // 美食列表页常量类                                  
│  │  └──ShopDisplayConstants.ets                   // 店铺页常量类
│  ├──entryability  
│  │  └─EntryAbility.ets 
│  ├──pages  
│  │  ├──DishDetails.ets                            // 商品详情页
│  │  ├──FoodList.ets                               // 美食列表页
│  │  ├──GraphicText.ets                            // 图文详情页
│  │  ├──Index.ets                                  // 首页 
│  │  ├──Living.ets                                 // 直播页                                  
│  │  └──ShopDisplay.ets                            // 店铺页
│  ├──utils  
│  │  ├──BreakpointType.ets                         // 断点类型类                                  
│  │  └──Logger.ets                                 // 日志打印类
│  ├──view  
│  │  ├──DishComments.ets                           // 商品评论视图
│  │  ├──DishDetailsView.ets                        // 商品详情视图
│  │  ├──DishInformation.ets                        // 商品信息视图       
│  │  ├──FoodItem.ets                               // 美食列表视图
│  │  ├──FoodListHeader.ets                         // 美食列表头部视图 
│  │  ├──GraphicTextComments.ets                    // 图文评论视图
│  │  ├──GraphicTextDescriptions.ets                // 图文描述视图
│  │  ├──GraphicTextFooter.ets                      // 图文详情底部视图
│  │  ├──GraphicTextHeader.ets                      // 图文详情头部视图
│  │  ├──GraphicTextSwiper.ets                      // 图文详情轮播图视图
│  │  ├──LivingComments.ets                         // 直播评论视图
│  │  ├──LivingHome.ets                             // 直播主视图
│  │  ├──ShopDish.ets                               // 店铺页主视图
│  │  ├──ShopInformation.ets                        // 店铺信息视图
│  │  ├──ShopMenu.ets                               // 店铺菜单视图
│  │  ├──ShopOrderList.ets                          // 店铺列表视图
│  │  ├──ShopPop.ets                                // 店铺弹窗视图
│  │  └──TakeOutDetails.ets                         // 详情视图
│  └──viewmodel  
│     ├──DishDetailViewModel.ets                    // 商品详情类
│     ├──FoodListViewModel.ets                      // 美食列表类
│     ├──LivingCommentsViewModel.ets                // 直播评论类                                   
│     └──ShopDisplayViewModel.ets                   // 店铺类        
└──entry/src/main/resources                         // 应用资源目录
```

### 相关概念

- 一次开发，多端部署：一套代码工程，一次开发上架，多端按需部署。支撑开发者快速高效的开发支持多种终端设备形态的应用，实现对不同设备兼容的同时，提供跨设备的流转、迁移和协同的分布式体验。
- 自适应布局：当外部容器大小发生变化时，元素可以根据相对关系自动变化以适应外部容器变化的布局能力。相对关系如占比、固定宽高比、显示优先级等。
- 响应式布局：当外部容器大小发生变化时，元素可以根据断点、栅格或特定的特征（如屏幕方向、窗口宽高等）自动变化以适应外部容器变化的布局能力。
- GridRow：栅格容器组件，仅可以和栅格子组件（GridCol）在栅格布局场景中使用。
- GridCol：栅格子组件，必须作为栅格容器组件（GridRow）的子组件使用。
- 画中画：应用在视频播放、视频会议、视频通话等场景下，可以使用画中画能力将视频内容以小窗（画中画）模式呈现。

### 相关权限

不涉及。

### 使用说明

1. 分别在手机、折叠屏、平板安装并打开应用，不同设备的应用页面通过响应式布局和自适应布局呈现不同的效果。
2. 打开应用，查看首页内容。
3. 点击‘FoodList’按钮，查看美食列表页内容。
4. 点击‘GraphicText’，查看图文详情页内容。
5. 点击‘Living’，查看直播页内容。
6. 点击美食列表页任意美食，查看店铺页内容。
7. 点击店铺页页任意商品，查看商品详情页内容。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机、平板、PC/2in1。
2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。