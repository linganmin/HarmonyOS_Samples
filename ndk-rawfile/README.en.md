# Using dlopen to Load a .so Library and Obtain Raw Files

## Overview

This sample shows how to use **dlopen** to load a .so library within a TaskPool thread and how to use the native Rawfile APIs to manipulate the **rawfile** directory and files in the directory. The operations covered include traversing a file list and opening, searching for, reading, and closing raw files.

## Preview

| Home page                            |
| ------------------------------------ |
| ![main](screenshots/device/main.png) |

## How to Use

The app demonstrates the Rawfile API calls, including obtaining files in the **resources/rawfile** directory as well as the content and descriptor of a raw file. The operations covered include traversing a file list and opening, searching for, reading, and closing raw files.

## Project Directory

```
├──entry/libs/                             // .so files to load
│  ├──arm64-v8a
│  │  └──libentry.so
│  └──x86_64
│     └──libentry.so
├──entry/src/main/cpp/                     // Native code
│  ├──include
│  │  └──global_handlers.h                 // Header file that contains the global object global_handlers
│  ├──types
│  │  ├──libentry
│  │  │  ├──index.d.ts                     // APIs exported
│  │  │  └──oh-package.json5
│  │  └──libpreloadso
│  │     ├──index.d.ts                     // APIs exported
│  │     └──oh-package.json5
│  ├──CMakeLists.txt                       // CMake build script
│  ├──global_handlers.cpp                  // Definition of the global object global_handlers
│  ├──preloadso.cpp                        // preload interface
│  └──rawfile_demo.cpp                     // Native API calls
├──entry/src/main/ets                      // ArkTS code
│  ├──entryability
│  │  └──EntryAbility.ets
│  ├──pages
│  │  └──Index.ets                         // Home page
│  └──utils
│     ├──Constants.ets                     // Preloaded .so file array
│     ├──Logger.ets                        // Log utility
│     └──TaskPool.ets                      // TaskPool thread to load the .so libraries
└──entry/src/main/resources                // Static resources
   ├──base
   ├──en_US
   ├──rawfile                              // Raw files
   │  ├──subrawfile
   │  │  └──rawfile2.txt
   │  ├──rawfile.txt
   │  └──rawfile1.txt
   └──zh_CN
```

## How to Implement

In the TaskPool thread, use **dlopen** to load the .so libraries. First, place the .so files to be loaded in the project's **libs** directory, and run the **target_link_directories** command in the **CMakeLists.txt** script to add the directories containing these libraries to the link directory of the preloaded library, and run the **target_link_libraries** command to link the .so libraries to the project.

In the **Preload** interface at the native layer, traverse the passed-in .so path array, use the **dlopen** function to load the libraries, and stores the handles to **global_handlers**. Expose the **Preload** API to the ArkTS layer so that the ArkTS layer can call it through **preload**. For details about the source code, see [preloadso.cpp](entry/src/main/cpp/preloadso.cpp)

The ArkTS layer uses TaskPool to create a thread and calls the **Preload** API on the native side through **preload** to load the .so libraries within the TaskPool thread and export the **preloadSOByTaskPool** function.
In the **onCreate lifecycle** function of the ability, call **preloadSOByTaskPool** to start the thread to complete the preloading of the .so libraries. For details about the source code, see [TaskPool.ets](entry/src/main/ets/utils/TaskPool.ets).

Define the external interfaces **getFileList**, **getRawFileContent**, and **getRawFileDescriptor** at the native layer, with their corresponding C++ interfaces being **GetFileList**, **GetRawFileContent**, and **GetRawFileDescriptor**.

By obtaining the JS resource object and converting it into a native resource object, you can call the native interfaces of the resources to obtain the lists of files in **rawfile** as well as the content and descriptor {fd, offset, length} of a raw file.

Import the **libentry.so** file at the JS side and obtain a resource manager object through **getContext().resourceManager**. Call the APIs declared in **src/main/cpp/types/libentry/index.d.ts**, passing in the JS resource object and related parameters, to obtain the resource information related to raw files.

For details about the source code, see [rawfile_demo.cpp](entry/src/main/cpp/rawfile_demo.cpp).

The following interfaces are involved:

| Name                                                                                                   | Description                                       |
|:------------------------------------------------------------------------------------------------------ | ------------------------------------------------- |
| NativeResourceManager *OH_ResourceManager_InitNativeResourceManager(napi_env env, napi_value jsResMgr) | Initializes a native resource manager.            |
| RawDir *OH_ResourceManager_OpenRawDir(const NativeResourceManager *mgr, const char *dirName)           | Opens a raw file directory.                       |
| int OH_ResourceManager_GetRawFileCount(RawDir *rawDir)                                                 | Obtains the number of raw files in a directory.   |
| const char *OH_ResourceManager_GetRawFileName(RawDir *rawDir, int index)                               | Obtains the name of a raw file.                   |
| RawFile *OH_ResourceManager_OpenRawFile(const NativeResourceManager *mgr, const char *fileName)        | Opens a raw file.                                 |
| long OH_ResourceManager_GetRawFileSize(RawFile *rawFile)                                               | Obtains the size of a raw file.                   |
| int OH_ResourceManager_ReadRawFile(const RawFile *rawFile, void *buf, size_t length)                   | Reads a raw file.                                 |
| void OH_ResourceManager_CloseRawFile(RawFile *rawFile)                                                 | Closes a raw file to release resources.           |
| void OH_ResourceManager_CloseRawDir(RawDir *rawDir)                                                    | Closes a raw file directory to release resources. |
| bool OH_ResourceManager_GetRawFileDescriptor(const RawFile *rawFile, RawFileDescriptor &descriptor)    | Obtains the file descriptor (FD) of a raw file.   |
| void OH_ResourceManager_ReleaseNativeResourceManager(NativeResourceManager *resMgr)                    | Releases a native resource manager.               |



## Required Permissions

N/A

## Dependencies

N/A

## Constraints

1. The sample is only supported on Huawei phones with standard systems.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.
