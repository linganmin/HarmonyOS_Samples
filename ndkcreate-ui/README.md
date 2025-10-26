# 通过NDK方式构建UI界面

## 介绍

ArkUI开发框架提供了一系列NDK接口，能够在应用中使用C和C++代码构建UI界面，这些接口包括UI组件创建、UI树操作、属性设置和事件监听等。
用户可以通过本工程学习相关NDK接口的用法。

## 效果预览

<img src="./screenshots/device/1.gif" width="320">


## 工程目录

```
|──entry/src/main/cpp
|  |──classdef
|  |  |──include
|  |  |  |──ArkUIBaseNode.h                          // 组件树操作的基类
|  |  |  |──ArkUICustomContainerNode.h               // 实现自定义容器组件的封装类
|  |  |  |──ArkUICustomNode.h                        // 实现自定义UI组件的封装类
|  |  |  |──ArkUIListItemAdapter.h                   // 懒加载封装类
|  |  |  |──ArkUIListItemGroupNode.h                 // 懒加载文本
|  |  |  |──ArkUIListItemNode.h                      // 列表项的封装
|  |  |  |──ArkUIListNode.h                          // 列表组件的封装
|  |  |  |──ArkUIMixedNode.h                         // 混合模式封装类
|  |  |  |──ArkUIMixedRefresh.h                      // Refresh组件的封装类
|  |  |  |──ArkUINode.h                              // 通用组件的封装
|  |  |  |──ArkUITextNode.h                          // 实现文本组件的封装类
|  |  |  └──NativeModuleInstance.h                   // ArkUI在Native侧模块的封装接口
|  |  └──src
|  |  |  |──ArkUIBaseNode.cpp                        // 组件树操作的基类
|  |  |  |──ArkUICustomContainerNode.cpp             // 实现自定义容器组件的封装类
|  |  |  |──ArkUICustomNode.cpp                      // 实现自定义UI组件的封装类
|  |  |  |──ArkUIListItemAdapter.cpp                 // 懒加载封装类
|  |  |  |──ArkUIListItemGroupNode.cpp               // 懒加载文本
|  |  |  |──ArkUIListItemNode.cpp                    // 列表项的封装
|  |  |  |──ArkUIListNode.cpp                        // 列表组件的封装
|  |  |  |──ArkUIMixedRefresh.cpp                    // Refresh组件的封装类
|  |  |  |──ArkUINode.cpp                            // 通用组件的封装
|  |  |  |──ArkUITextNode.cpp                        // 实现文本组件的封装类
|  |  |  └──NativeModuleInstance.cpp                 // ArkUI在Native侧模块的封装接口
|  |──function
|  |  |──include
|  |  |  |──AppearDisappearTransitions.h             // 动画出现消失转换
|  |  |  |──BuildingADialogBox.h                     // 构建弹窗
|  |  |  |──BuildingCustomComponents.h               // 构建自定义组件
|  |  |  |──CustomGestureJudgment.h                  // 自定义手势判断
|  |  |  |──EmbeddingArkTSComponents.h               // 嵌入ArkTS组件
|  |  |  |──IntegratingWithArkts.h                   // 接入ArkTS界面
|  |  |  |──ListeningForComponentEvents.h            // 注册监听事件
|  |  |  |──ListItemGroup.h                          // 创建文本组列表
|  |  |  |──ListWithLazyLoading.h                    // 懒加载列表
|  |  |  |──NativeEntry.h                            // 管理Native组件生命周期
|  |  |  |──SequentialRecognition.h                  // 顺序识别手势
|  |  |  |──UITimer.h                                // 创建一个Native定时器
|  |  |  └──UsingPropertyAnimations.h                // 使用动画属性
|  |  └──src
|  |  |  |──AppearDisappearTransitions.cpp            // 动画出现消失转换
|  |  |  |──BuildingADialogBox.cpp                    // 构建弹窗
|  |  |  |──BuildingCustomComponents.cpp              // 构建自定义组件
|  |  |  |──CustomGestureJudgment.cpp                 // 自定义手势判断
|  |  |  |──EmbeddingArkTSComponents.cpp              // 嵌入ArkTS组件
|  |  |  |──IntegratingWithArkts.cpp                  // 接入ArkTS界面
|  |  |  |──ListeningForComponentEvents.cpp           // 注册监听事件
|  |  |  |──ListItemGroup.cpp                         // 创建文本组列表
|  |  |  |──ListWithLazyLoading.cpp                   // 懒加载列表
|  |  |  |──SequentialRecognition.cpp                 // 顺序识别手势
|  |  |  |──UITimer.cpp                               // 创建一个Native定时器
|  |  |  └──UsingPropertyAnimations.cpp               // 使用动画属性
|  └──types
|  |  └──libentry
|  |  |  |──Index.d.ts                                 // Native侧接口导出声明文件
|  |  |  └──oh-package.json5
|  |──CMakeLists.txt                                   // cmake配置文件
|  └──napi_init.cpp                                    // 接口映射、模块注册
|──entry/src/main/ets
|  |──entryabilitity
|  |  └──EntryAblity.ets
|  |──entryBackupablity
|  |  └──entryBackupablity.ets
|  |──model
|  |  └──DataModel.ets
|  └──pages
|  |  └──common
|  |  |  |──scenery.PNG
|  |  |  └──sky.PNG
|  |  |──AppearDisappearTransitions.ets                // 动画出现消失转换
|  |  |──BuildingADialogBox.ets                        // 构建弹窗
|  |  |──BuildingCustomComponents.ets                  // 构建自定义组件
|  |  |──CombinedGestures.ets                          // 组合手势
|  |  |──CustomGestureJudgment.ets                     // 自定义手势判断
|  |  |──EmbeddingArkTSComponents.ets                  // 嵌入ArkTS组件
|  |  |──Index.ets                                     // 主页面
|  |  |──IntegratingWithArkts.ets                      // 接入ArkTS界面
|  |  |──ListeningForComponentEvents.ets               // 注册监听事件
|  |  |──ListItemGroup.ets                             // 创建文本组列表
|  |  |──ListWithLazyLoading.ets                       // 懒加载列表
|  |  |──MixedModule.ets                               // Refresh
|  |  |──SequentialRecognition.ets                     // 顺序识别手势
└──└──└──UsingPropertyAnimations.ets                   // 使用动画属性

```

## 使用说明

1. 点击应用图标会显示，显示使用NDK构建UI界面，会有相关功能按钮。
2. 点击“接入arkts页面”，会显示“ShowNativeUI”按钮，点击按钮会显示一个文本列表，点击“HideNativeUI”按钮会隐藏文本。
3. 点击“监听组件事件”按钮，会显示“ShowNativeUI”按钮，点击按钮会显示一个文本列表，点击文本列表会改变其背景颜色并输出日志，点击“HideNativeUI”按钮会隐藏文本。
4. 点击“懒加载列表”按钮，会显示“ShowNativeUI”按钮，点击按钮会显示一个文本列表，上下滑动会缓慢加载文本列表，点击“HideNativeUI”按钮会隐藏文本。
5. 点击“构建自定义组件”按钮，会显示“ShowNativeUI”按钮，点击按钮会自定义容器，点击“HideNativeUI”按钮会隐藏文本。
6. 点击“嵌入ArkTS组件”按钮，会显示“ShowNativeUI”按钮，点击按钮会显示一个文本列表，上下拉扯会刷新列表，点击“HideNativeUI”按钮会隐藏文本。
7. 点击“构建弹窗”按钮，会显示“点击弹窗”按钮，点击按钮会出现一个弹窗，点击“关闭弹窗”按钮弹窗会消失。
8. 点击“使用属性动画”按钮，点击“play”按钮会改变文本框的大小。
9. 点击“组件出现/消失转场”按钮，会显示“show”按钮，点击按钮会出现动画进场页面，点击“hide”按钮出现动画出场页面。
10. 点击“组合手势”按钮，会显示“组合手势-顺序识别”按钮和“组合手势-自定义手势判断”按钮，点击“组合手势-顺序识别”会有相关日志打印，点击“组合手势-自定义手势判断”按钮，长按界面会有相关日志打印。

## 实现说明

1.使用NDK接口构建UI界面时，需要在ArkTS页面创建用于挂载NDK接口创建组件的占位组件。占位组件类型为[ContentSlot](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-components-contentslot)，ContentSlot能够绑定一个[NodeContent](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-arkui-nodecontent)对象，该对象可通过Node-API传递到Native侧挂载显示Native组件。
2.NDK提供的UI组件能力如组件创建、树操作、属性设置、事件注册等是通过函数指针结构体（如[ArkUI_NativeNodeAPI_1](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/_ark_u_i___native_node_a_p_i__1)）进行暴露，该函数指针结构体可以通过[模块查询接口](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/_ark_u_i___native_module#oh_arkui_getmoduleinterface)获取。

## 相关权限

不涉及。

## 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机、平板、2in1。 
2. HarmonyOS系统：HarmonyOS 5.1.0 Release及以上。 
3. DevEco Studio版本：DevEco Studio 5.1.0 Release及以上。 
4. HarmonyOS SDK版本：HarmonyOS 5.1.0 Release SDK及以上。
