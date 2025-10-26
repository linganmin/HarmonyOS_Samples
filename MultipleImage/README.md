# 使用Swiper组件实现轮播布局
## 介绍
本示例介绍了两个案例，第一个是如何使用Swiper组件实现图片轮播效果，以及如何自定义Swiper组件的指示器，来实现图片的切换效果；
第二个是如何使用Stack组件实现轮播图层叠效果。

在短视频平台上，经常可以见到图文合集。它的特点是：由多张图片组成一个合集，图片可以自动进行轮播，也可以手动去进行图片切换。图片下方的进度条
会跟随图片的切换而切换；在各类应用和网站中，轮播图的使用非常广泛，而轮播图的叠加效果，也能创造独特的视觉层次和交互体验。

## 预览效果
<img src="./screenshots/device/image.gif" width="320">

## 工程目录
``` 
├──entry/src/main/ets                                   // 代码区
│  ├──common
│  │  └──CommonConstants.ets                            // 常量
│  ├──entryability
│  │  └──EntryAbility.ets                               // 程序入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  ├──pages 
│  │  ├──ImageSwitch                                    // 多图片合集页
│  │  ├──Index.ets                                      // 首页
│  │  └──StackSwitch.ets                                // 层叠布局页
│  └──utils.ets
│     └──DataSource.ets                                 // 图片数据资源类
└──entry/src/main/resources                             // 应用资源目录
``` 
## 使用说明
* 运行应用后，点击首页的ImageSwitch按钮跳转至多图片合集页面，不滑动屏幕时，图片自动轮播，且下方进度条缓慢增长至已完成状态，播放完成时，会继续循环播放。
滑动屏幕时，图片跟随滑动方向而进行切换，此时会关闭自动轮播和循环播放的效果，且下方进度条瞬间增长至已完成状态。

* 运行应用后，点击首页的StackSwitch按钮跳转至轮播图层叠布局页面，左右滑动可进行轮播图切换。
## 实现说明
* 多图片合集页

  上面图片的轮播部分使用Swiper组件实现。

  下面的指示器，需要关闭原生指示器，自定义指示器（进度条）来实现。

  进度条可以使用Row容器来实现对应的效果，通过层叠布局方式将Row容器叠放在一起。进度条缓慢增长，可以通过animation属性来设置对应的动画效果。进度条的完成态和未完成态的实现，
只需要设置对应的背景颜色即可。

* 层叠布局页

  使用Stack组件进行层叠布局，通过给组件添加zIndex属性来设置组件的堆叠顺序，添加visibility属性来控制显示或隐藏，添加scale属性来控制是否缩放。

## 相关权限
无

## 约束与限制
* 本示例仅支持标准系统上运行，支持设备：华为手机。

* HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

* DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

* HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。