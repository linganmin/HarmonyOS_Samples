# 实现查询应用包信息功能

### 简介

本示例主要介绍如何获取应用包相关信息并展示，主要包括在ArkTS侧分别获取应用图标、名称等resource资源信息和应用包签名信息以及在Native侧获取应用包名和签名信息。基于本示例，开发者可以掌握应用包管理相关的使用能力。

### 效果预览
![](screenshots/device/QueryAppPackageInfo.gif) 

### 使用说明

在主页面中点击对应按钮会分别跳转到不同场景的页面。在每个场景页面中都包含了一个信息展示区域和一个按钮，点击按钮会调用接口将相关信息显示到信息展示区域上。

#### 提醒

模拟器中不包含应用包签名相关信息，所以如果在模拟器中运行代码，获取签名相关信息时可能会显示为空。

### 工程结构
```
├──entry/src/main/cpp                   // C++代码区
│  ├──types
│  │  └──libentry                       // C++接口导出
│  │     ├──Index.d.ts                
│  │     └──oh-package.json5           
│  ├──CMakeLists.txt                    // Cmake配置文件 
│  └──napi_init.cpp                     // Native侧代码区
├──entry/src/main/ets                   // ArkTS代码区                  
│  ├──common        
│  │  └──CommonConstants.ets            // 常量定义文件
│  ├──entryability        
│  │  └──EntryAbility.ets                                
│  ├──entrybackupability 
│  │  └──EntryBackupAbility.ets                           
│  ├──model                
│  │  ├──AppInfoData.ets                // 应用包信息初始数据 
│  │  ├──AppInfoItem.ets                // 应用包信息通用类 
│  │  ├──AppSignatureInfoData.ets       // 应用包签名信息初始数据
│  │  └──NativeAppInfoData.ets          // Native侧应用包信息初始数据
│  ├──pages     
│  │  ├──GetAppInfo.ets                 // ArkTS侧获取应用包信息页面 
│  │  ├──GetSignatureInfo.ets           // ArkTS侧获取应用包签名信息页面 
│  │  ├──MainPages.ets                  // 主页面 
│  │  └──NativeGetAppInfo.ets           // Native侧获取应用包信息页面           
│  └──view    
│     └──AppInfoComponent.ets           // List组件        
└──entry/src/main/resources             // 应用资源文件
```

### 相关权限

**不涉及**

### 参考资料

**不涉及**

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。
2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。