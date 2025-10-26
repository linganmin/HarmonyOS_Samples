# 实现Native侧的文件读写

### 介绍

本示例展示了如何在Native侧对文件进行读写，ArkTS侧的数据可以传到Native侧进行文件写入，Native侧读取的文件数据可以返回给ArkTS侧。该示例可以帮助开发者学习在Native侧如何精准获取ArkTS侧传入的字符串长度，并掌握如何在Native侧对文件进行读写。

### 效果预览

![](screenshots/device/native_fileio.png) 


使用说明

1、点击写入数据的输入框，输入对应的内容，点击【写入】按钮将输入的内容写到本地文件中。

2、点击读取数据的【读取】按钮，读取文件中已写入的数据，并进行展示。




### 工程目录
```
├──entry/src/main/cpp                   // C++代码区
│  ├──types
│  │  └──libentry                       // C++接口导出
│  │     ├──Index.d.ts                
│  │     └──oh-package.josn5              
│  ├──CMakeLists.txt                    // CMake配置文件     
│  └──napi_init.cpp                     // Native业务代码实现
├──entry/src/main/ets                   // ArkTS代码区
│  ├──entryability                      
│  ├──entrybackupability                
│  └──pages    
│     └──Index.ets                      // 主页界面
└──entry/src/main/resources             // 应用资源文件
```
### 具体实现
* 在写入文件时，需要在ArkTS侧获取文件的路径和写入的内容，并传递到Native侧。
* 先调用napi_get_value_string_utf8函数来获取字符串的长度，然后根据长度分配char数组的内存空间。
* 再次调用napi_get_value_string_utf8函数来获取字符串的内容，并写入到文件中。
* 在读取文件时，使用napi_create_string_utf8获取文件内容，再返回到ArkTS侧。

注意：在为写入的内容分配内存时，可以将长度+1，以便为字符串添加终止符'\0'。

### 相关权限

不涉及。

### 依赖

不涉及。

### 约束与限制

1.本示例仅支持标准系统上运行，支持设备：华为手机。

2.HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3.DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4.HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。