# 基于dlopen实现加载so库获取Rawfile资源功能

## 介绍

本示例中主要介绍在TaskPool子线程中使用dlopen加载so库，以及如何使用Native Rawfile接口操作Rawfile目录和文件。功能包括文件列表遍历、文件打开、搜索、读取和关闭Rawfile。

## 效果预览

| 主页                                   |
| ------------------------------------ |
| ![main](screenshots/device/main.png) |

使用说明

应用界面中展示了Rawfile相关的接口调用，包括获取resources/rawfile目录下的文件、对应的rawfile文件内容、对应rawfile文件的descriptor。其中使用到的功能包括文件列表遍历、文件打开、搜索、读取和关闭Rawfile。

## 工程目录

```
├──entry/libs/                             // 需要加载的.so文件
│  ├──arm64-v8a
│  │  └──libentry.so
│  └──x86_64
│     └──libentry.so
├──entry/src/main/cpp/                     // native侧代码
│  ├──include
│  │  └──global_handlers.h                 // 包含全局对象global_handlers的头文件
│  ├──types
│  │  ├──libentry
│  │  │  ├──index.d.ts                     // 接口导出
│  │  │  └──oh-package.json5
│  │  └──libpreloadso
│  │     ├──index.d.ts                     // 接口导出
│  │     └──oh-package.json5
│  ├──CMakeLists.txt                       // 编译脚本
│  ├──global_handlers.cpp                  // 定义全局对象global_handlers
│  ├──preloadso.cpp                        // preload接口
│  └──rawfile_demo.cpp                     // 调用native接口
├──entry/src/main/ets                      // ArkTS侧代码
│  ├──entryability
│  │  └──EntryAbility.ets
│  ├──pages
│  │  └──Index.ets                         // 首页
│  └──utils
│     ├──Constants.ets                     // 预加载的so文件数组
│     ├──Logger.ets                        // 日志工具
│     └──TaskPool.ets                      // TaskPool子线程加载so库
└──entry/src/main/resources                // 应用静态资源目录
   ├──base
   ├──en_US
   ├──rawfile                              // rawfile资源
   │  ├──subrawfile
   │  │  └──rawfile2.txt
   │  ├──rawfile.txt
   │  └──rawfile1.txt
   └──zh_CN
```

## 具体实现

在TaskPool子线程中使用dlopen加载so库，将需要加载的.so文件放到工程文件libs中，在CMakeLists编译脚本中使用target_link_directories命令将包含这些库文件的目录添加到预加载库的链接目录，使用target_link_libraries命令将需要预加载的so库链接到项目中。
在Native层的Preload接口中，遍历传入的.so路径数组，使用dlopen函数加载库，并将句柄保存到global_handlers中。暴露Preload接口给ArkTS层使用，使其能够通过preload调用Native层的Preload接口。源码参考：[preloadso.cpp](entry/src/main/cpp/preloadso.cpp)

ArkTS层使用TaskPool创建子线程，通过preload接口调用Native侧的Preload接口，实现在TaskPool子线程中加载.so库，导出preloadSOByTaskPool函数。
在Ability的onCreate生命周期函数中，调用preloadSOByTaskPool开启子线程，完成so库的预加载。源码参考：[TaskPool.ets](entry/src/main/ets/utils/TaskPool.ets)

在Native层定义对外接口为getFileList、getRawFileContent、getRawFileDescriptor，映射C++接口分别为GetFileList、GetRawFileContent、GetRawFileDescriptor。
通过获取Js的资源对象，并转为Native的资源对象，即可调用资源的Native接口，获取rawfile列表、rawfile文件内容以及rawfile描述符{fd, offset, length}。
在Js侧导入"libentry.so"，通过getContext().resourceManager获取资源管理对象。调用src/main/cpp/types/libentry/index.d.ts中声明的接口，传入js的资源对象和相关参数获取对于rawfile相关资源信息。
源码参考：[rawfile_demo.cpp](entry/src/main/cpp/rawfile_demo.cpp)
。 涉及到的相关接口：

| 接口名                            | 描述                                                                                                     |
|:------------------------------ |:------------------------------------------------------------------------------------------------------ |
| 初始化native resource manager。    | NativeResourceManager *OH_ResourceManager_InitNativeResourceManager(napi_env env, napi_value jsResMgr) |
| 打开指定rawfile目录。                 | RawDir *OH_ResourceManager_OpenRawDir(const NativeResourceManager *mgr, const char *dirName)           |
| 获取指定rawfile目录下的rawfile文件数量。    | int OH_ResourceManager_GetRawFileCount(RawDir *rawDir)                                                 |
| 获取rawfile名字。                   | const char *OH_ResourceManager_GetRawFileName(RawDir *rawDir, int index)                               |
| 打开指定rawfile文件。                 | RawFile *OH_ResourceManager_OpenRawFile(const NativeResourceManager *mgr, const char *fileName)        |
| 获取rawfile文件大小。                 | long OH_ResourceManager_GetRawFileSize(RawFile *rawFile)                                               |
| 读取rawfile文件内容。                 | int OH_ResourceManager_ReadRawFile(const RawFile *rawFile, void *buf, size_t length)                   |
| 释放rawfile文件相关资源。               | void OH_ResourceManager_CloseRawFile(RawFile *rawFile)                                                 |
| 释放rawfile目录相关资源。               | void OH_ResourceManager_CloseRawDir(RawDir *rawDir)                                                    |
| 获取rawfile的fd。                  | bool OH_ResourceManager_GetRawFileDescriptor(const RawFile *rawFile, RawFileDescriptor &descriptor)    |
| 释放native resource manager相关资源。 | void OH_ResourceManager_ReleaseNativeResourceManager(NativeResourceManager *resMgr)                    |



## 相关权限

不涉及。

## 依赖

不涉及。

## 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。
2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。
