# 多API版本兼容示例

### 介绍
通过@ohos.deviceInfo(设备信息)模块deviceInfo.sdkApiVersion和deviceInfo.distributionOSApiVersion获取系统SDK版本，以Text、Scroll和HdsActionBar组件在API 18和API 20的兼容为例，介绍多版本适配的实现方法。在Native侧，通过deviceinfo的OH_GetSdkApiVersion获取系统SDK版本，以Button组件为例介绍多版本适配的实现方法。

### 工程目录

```
|──entry/src/main/cpp
|  |──classdef
|  |  |──include
|  |  |  |──ArkUIBaseNode.h                      // 组件树操作的基类
|  |  |  |──ArkUINode.h                          // 通用组件的封装
|  |  |  |──ArkUIButtonNode.h                    // 实现按钮组件的封装类
|  |  |  └──NativeModuleInstance.h               // ArkUI在Native侧模块的封装接口
|  |  └──src
|  |  |  |──ArkUIBaseNode.cpp                    // 组件树操作的基类
|  |  |  |──ArkUINode.cpp                        // 通用组件的封装
|  |  |  |──ArkUIButtonNode.cpp                  // 实现按钮组件的封装类
|  |  |  └──NativeModuleInstance.cpp             // ArkUI在Native侧模块的封装接口
|  |──function
|  |  |──include
|  |  |  |──IntegratingWithArkts.h               // 接入ArkTS界面
|  |  |  └──NativeEntry.h                        // 管理Native组件生命周期
|  |  └──src
|  |  |  └──IntegratingWithArkts.cpp             // 接入ArkTS界面
|  └──types
|  |  └──libentry
|  |  |  |──Index.d.ts                           // Native侧接口导出声明文件
|  |  |  └──oh-package.json5
|  |──CMakeLists.txt                             // cmake配置文件
|  └──napi_init.cpp                              // 接口映射、模块注册
├──entry/src/main/ets                            // 代码区
│  ├──components                                 // 自定义组件
│  │  ├──ActionBarAdapter.ets                    // HdsActionBar组件版本兼容示例   
│  │  ├──NativeButtonAdapter.ets                 // Button组件版本兼容示例                           
│  │  ├──ScrollComponentAdapter.ets              // Scroll组件版本兼容示例                           
│  │  └──TextComponentAdapter.ets                // Text组件版本兼容示例
│  ├──entryability
│  │  └──EntryAbility.ets                        // 程序入口类
│  ├──entrybackupability                  
│  │  └──EntryBackupAbility.ets                  // 应用数据备份和恢复类
│  └──pages 
│     └──Index.ets                               // 应用主界面
```

### 使用说明
安装应用之后，进入首页。

### 实现说明
* 通过@ohos.deviceInfo(设备信息)模块deviceInfo.sdkApiVersion和deviceInfo.distributionOSApiVersion属性来获取当前设备SDK版本，然后和目标版本进行比对。
* 以Text组件的marqueeOptions属性使用为例来展示API18的兼容，实现了跑马灯效果
* 以Scroll组件的maxZoomScale、minZoomScale和enableBouncesZoom为例子来展示API20的兼容，实现了图片缩放效果。
* 以HdsActionBar组件的使用例子来展示API20的兼容，实现可以展开和收起的ActionBar效果。
* 以Native侧的Button组件为例，展示API20的兼容。

### 相关权限
不涉及

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。
2. HarmonyOS系统：HarmonyOS 6.0.0 Beta2及以上。
3. DevEco Studio版本：DevEco Studio 6.0.0 Beta2及以上。
4. HarmonyOS SDK版本：HarmonyOS 6.0.0 Beta2 SDK及以上。
