# 实现Grid网格元素拖拽交换排序能力

## 介绍

Grid网格元素拖拽交换功能是通过Grid容器组件、组合手势、显式动画结合来实现的。Grid容器组件用来构建网格元素布局、组合手势用来实现元素拖拽交换的效果、显式动画用来给元素拖拽交换过程中，添加动画效果。
本示例主要实现了四种网格元素拖拽交换的场景：网格元素相同大小时拖拽交换、网格元素不同大小时拖拽交换、网格元素直接拖拽交换、网格元素抖动。

## 预览效果
![](/screenshots/device/phone.gif)

## 工程目录

``` 
├──entry/src/main/ets                                   // 代码区
│  ├──entryability
│  │  └──EntryAbility.ets                               // 程序入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  └──pages                              
│     ├──DifferentItemDrag.ets                          // 不同大小item拖拽交换页
│     ├──DirectDragItem.ets                             // 直接拖拽交换页
│     ├──Index.ets                                      // 首页
│     ├──JitterAnimation.ets                            // 抖动动画页
│     └──SameItemDrag.ets                               // 相同大小item拖拽交换页
└──entry/src/main/resources                             // 应用资源目录
``` 

## 使用说明
示例代码包含四个场景：
* 网格元素相同大小时拖拽交换

  在编辑九宫格等多图的场景中，长按图片（网格元素）可以拖拽交换排序，拖拽图片的过程中，旁边的图片也会即时移动，以产生新的宫格排布。
* 网格元素不同大小时拖拽交换

  在一些展示设备的场景中，会有大小不同的网格元素。当用户想改变设备排序时，可以长按设备图片（网格元素）拖拽交换排序，拖拽的过程中，也会改变排列顺序，以产生新的宫格排布。
* 网格元素直接拖拽交换

  在不需要长按拖拽的场景下，开发者可以将元素设置成直接拖拽，无需长按，即可完成元素的拖拽交换。
* 网格元素抖动

  在设备列表页面时，如果想要移除设备，在选中设备并长按后，可对网格元素进行编辑。此时，设备图片会有抖动的效果。

## 相关权限

无

## 约束与限制

* 本示例仅支持标准系统上运行，支持设备：华为手机。

* HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

* DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

* HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。