# HMRouter
## 简介
本示例展示了使用HMRouter路由框架在各种页面跳转场景中的使用，覆盖场景

- 一次开发多端部署
- 路由跳转及拦截跳转场景
- 生命周期配置使用场景
- 转场动画配置使用场景

## 效果预览

![img.png](screenshots/img.png)

## 工程目录
```
├─entry/src/main/ets                         // 代码区
├── animation                                // 自定义动画
|  └── CustomPageAnimator.ets
├── component                                // HMRouter页面代码
|  ├── common
|  |  ├── ConfirmDialog.ets
|  |  ├── ReturnHeader.ets
|  |  ├── constants
|  |  |  ├── BreakpointConstants.ets
|  |  |  ├── CommonConstants.ets
|  |  |  ├── DetailConstants.ets
|  |  |  ├── HomeConstants.ets
|  |  |  ├── LiveConstants.ets
|  |  |  ├── LoginConstants.ets
|  |  |  ├── MineConstants.ets
|  |  |  ├── PayConstants.ets
|  |  |  └── ShoppingBagConstants.ets
|  |  └── utils
|  |     ├── BreakpointType.ets
|  |     ├── ResourceUtil.ets
|  |     └── SelectAnimatorItem.ets
|  ├── home
|  |  ├── Categories.ets
|  |  ├── CommonView.ets
|  |  ├── HomeContent.ets
|  |  ├── HomeHeader.ets
|  |  ├── RecommendedProductView.ets
|  |  └── WelfareView.ets
|  ├── live
|  |  ├── Comment.ets
|  |  ├── CommentInput.ets
|  |  ├── Live.ets
|  |  ├── LiveCommentFooter.ets
|  |  ├── LiveComments.ets
|  |  ├── LiveCommentsHeader.ets
|  |  ├── LiveHome.ets
|  |  ├── LiveMaskLayer.ets
|  |  ├── LiveShopList.ets
|  |  ├── LiveVideo.ets
|  |  └── LiverHeader.ets
|  ├── login
|  |  └── LoginPage.ets
|  ├── mine
|  |  ├── AnimatorTransition.ets
|  |  ├── ExitLogin.ets
|  |  ├── MineContent.ets
|  |  └── MineSettings.ets
|  ├── pay
|  |  ├── PayCancel.ets
|  |  ├── PayCard.ets
|  |  ├── PayDialogContent.ets
|  |  └── PaySuccessPageComponent.ets
|  ├── privacy
|  |  ├── PrivacyDialogDetail.ets
|  |  └── PrivacyPageContent.ets
|  ├── product
|  |  ├── ProductContent.ets
|  |  └── elements
|  |     ├── ProductDetail.ets
|  |     └── ProductUtilView.ets
|  ├── shoppingBag
|  |  ├── ShoppingBagContent.ets
|  |  ├── ShoppingNavModifier.ets
|  |  └── components
|  |     ├── DetailShoppingBagView.ets
|  |     ├── ShoppingBagCard.ets
|  |     ├── ShoppingBagContentNavBar.ets
|  |     ├── ShoppingBagDiscounts.ets
|  |     ├── ShoppingBarView.ets
|  |     ├── ShoppingCardFoot.ets
|  |     └── ShoppingCardItem.ets
|  └── viewmodel
|     ├── FooterTabViewModel.ets
|     ├── IconInfoViewModel.ets
|     ├── LiveCommentsModel.ets
|     ├── LiveViewModel.ets
|     ├── PayCardViewModel.ets
|     ├── RecommendedProductViewModel.ets
|     ├── SectionProductsViewModel.ets
|     └── ShoppingBagListViewModel.ets
├── constant                                    // 页面常量
|  └── PageConstant.ets
├── entryability                                // 程序入口
|  └── EntryAbility.ets
├── entrybackupability
|  └── EntryBackupAbility.ets
├── interceptor                                 // 全局拦截器
|  ├── JumpInfoInterceptor.ets
|  ├── LoginCheckInterceptor.ets
|  └── LoginStatusInterceptor.ets
├── lifecycle                                   // 生命周期
|  ├── ExitAppLifecycle.ets
|  ├── PageDurationLifecycle.ets
|  ├── RemoveBackAnimation.ets
|  └── WelcomeLifecycle.ets
├── pages                                       // HMNavigation入口
|  └── Index.ets
|  └── MainPage.ets
└── service                                     // 服务路由
   └── ServiceSample.ets
```
## HMRouter简介

HMRouter作为HarmonyOS的页面跳转场景解决方案，聚焦解决应用内ArkUI页面的跳转逻辑。

HMRouter底层对系统Navigation进行封装，集成了Navigation、NavDestination、NavPathStack的系统能力，提供了可复用的路由拦截、页面生命周期、自定义转场动画，并且在跳转传参、额外的生命周期、服务型路由方面对系统能力进行了扩展。

目的是让开发者在开发过程中无需关注Navigation、NavDestination容器组件的相关细节及模板代码，屏蔽跳转时的判断逻辑，降低拦截器、自定义转场动画实现复杂度，更好的进行模块间解耦。

## 特性

- 基于注解声明路由信息
- 注解中页面路径支持使用字符串常量定义
- 支持Har、Hsp、Hap
- 支持Navigation路由栈嵌套
- 支持服务型路由
- 支持路由拦截器（包含全局拦截、单页面拦截、跳转时一次性拦截）
- 支持生命周期回调（包含全局生命周期、单页面生命周期、跳转时一次性生命周期、NavBar生命周期）
- 内置转场动画（页面、Dialog），可配置方向、透明度、缩放，支持交互式转场动画，同时支持配置某个页面的转场动画、跳转时的一次性动画
- 支持Dialog类型页面、支持单例页面

## 依赖版本

HarmonyOS NEXT Beta1及以上

> 手机版本：NEXT.0.0.60及以上

## HMRouter使用说明

[查看详情](https://gitee.com/hadss/hmrouter/blob/master/HMRouterLibrary/README.md)

## 应用内ArkUI页面跳转场景解决方案

[查看详情](https://gitee.com/hadss/hmrouter/blob/master/docs/Scene.md)

## 更多示例

[查看详情](https://gitee.com/hadss/hmrouter)

## FAQ

[查看详情](https://gitee.com/hadss/hmrouter/blob/master/docs/FAQ.md)

## 原理介绍

[查看详情](https://developer.huawei.com/consumer/cn/forum/topic/0207153170697988820?fid=0109140870620153026)

## 开源协议

本项目基于 [Apache License 2.0](https://gitee.com/hadss/hmrouter/blob/master/LICENSE) ，请自由地享受和参与开源。