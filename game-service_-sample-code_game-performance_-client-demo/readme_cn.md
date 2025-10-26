# 基于场景感知实现游戏与系统交互（ArkTS）

## 简介
本示例集成了Game Service Kit，实现了一个简单的场景感知功能，供您参考使用，请注意，订阅设备和取消订阅设备仅演示接口调用示例。

## 预览图
![](./image/indexPage_cn.png)

## 工程目录
```
├──entry/src/main/ets                      // 代码区    
│  ├──entryability    
│  │  └──EntryAbility.ets                  // 程序入口类    
│  └──pages     
│     └──Index.ets                         // 主界面       
│        ├──gamePerformanceInit()          // 初始化接口      
│        ├──subscribeDeviceState()         // 订阅设备信息接口    
│        ├──unSubscribeDeviceState()       // 取消订阅设备信息接口    
│        ├──updateGameSceneInfo()          // 更新游戏场景信息  
│        └──queryDeviceInfo()              // 查询设备信息     
└──entry/src/main/resources                // 资源文件目录   
```

## 使用说明
1. 使用DevEco Studio打开工程目录。
2. 替换AppScope中app.json5文件和Index.ets文件中的bundleName。
3. 在build-profile.json5的signingConfigs中配置签名信息。
4. 在HarmonyOS设备上运行示例代码。

## 约束与限制
1. 本示例仅支持标准系统上运行，支持设备：华为手机、平板和PC/2in1。
2. HarmonyOS系统：HarmonyOS 5.0.2 Release及以上。
3. DevEco Studio版本：DevEco Studio 5.0.2 Release及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.0.2 Release SDK及以上。 