# Web加载性能优化

## 项目简介

本示例展示了Web加载性能优化相关案例。

## 效果预览
不涉及

## 使用说明
不涉及

## 工程目录
```
├──entry/src/main/cpp                                   // C++代码区
│  ├──types/libentry                                    
│  │  ├──Index.d.ts                                     // 暴露给UI层的接口
│  │  └──oh-package.json5
│  ├──CMakeLists.txt                                    // 编译入口
│  ├──DefineJSBridge.cpp                                // 定义JSBridge
│  ├──hello.cpp                                         // 代码注册
│  ├──napi_init.cpp                                     // 代码注册
│  └──nnapi_init.cpp                                    // 读取Rawfile
├──entry/src/main/ets                                   // 代码区
│  ├──entryability
│  │  └──EntryAbility.ets                               // 程序入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  ├──pages        
│  │  ├──ByteCodeCache.ets                              // 字节码缓存
│  │  ├──CaseFour.ets                                   // prefetchPage预链接
│  │  ├──CaseOne.ets                                    // prepareForPageLoad
│  │  ├──CaseThree.ets                                  // prepareForPageLoad预加载   
│  │  ├──CaseTwo.ets                                    // prepareForPageLoad预加载
│  │  ├──ClearResourceCache.ets                         // clearPrefetch
│  │  ├──common.ets                                     // 预渲染
│  │  ├──CreateCarrier.ets                              // 预创建Web
│  │  ├──CreateNodeController.ets                       // 预渲染Web
│  │  ├──Index.ets                                      // 首页
│  │  ├──JsBridgeOfArkTS.ets                            // ArkTS的JsBridge
│  │  ├──JsBridgeOfNDK.ets                              // NDK的JsBridge
│  │  ├──LoadWebComponentError.ets                      // loadUrl  
│  │  ├──LoadWebComponentRight.ets                      // loadUrl
│  │  ├──LoadWebPage.ets                                // startTrace
│  │  ├──PageRequestInterception.ets                    // Web拦截
│  │  ├──PracticalCaseOne.ets                           // 未预编译
│  │  ├──PracticalCaseTwo.ets                           // 预编译
│  │  ├──PrefetchResource.ets                           // 预加载资源
│  │  ├──RegisterJavaScriptProxy.ets                    // 注册JavaScript
│  │  ├──RegisterSyncFunction.ets                       // 注册异步方法
│  │  ├──Second.ets                                     // 预渲染
│  │  ├──SetResposeData.ets                             // 拦截
│  │  ├──SetSchemeHandler.et                            // 设置Scheme
│  │  ├──UseArrayBufferInterceptReplace.ets             // 拦截后使用ArrayBuffer
│  │  ├──UseNodeController.ets                          // controller
│  │  ├──UseStringInterceptReplace.ets                  // 拦截后使用字符串
│  │  ├──WebComponent.ets                               // Web组件
│  │  └──WebComponentLoad.ets                           // Web组件加载
│  ├──utils
│  │  ├──CreateResourceConfig.ets                       // ForEach页面
│  │  └──HttpRequestPost.js                             // LazyForEach页面
│  └──view
│     └──Second.ets                                      // Web页面
└──entry/src/main/resources                             // 应用资源目录
```

## 具体实现

不涉及。

## 相关权限

不涉及。

## 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。

## 下载

如需单独下载本工程，执行如下命令：
```
git init
git config core.sparsecheckout true
echo LoadPerformanceInWeb/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```