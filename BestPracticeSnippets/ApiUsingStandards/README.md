# 易错API的使用规范

### 介绍

本示例是《易错API的使用规范》最佳实践中的代码示例片段。

### 使用说明

不涉及。


### 工程目录

``` 
├──entry/src/main/ets
│  ├──cpp
│  │  ├──CMakeList.txt                      // CMake文件
│  │  ├──napi_init.cpp                      // napi初始化   
│  │  └──callbackTest.cpp                   // callback测试类
│  ├──cpp/types/libentry
│  │  ├──oh-package.json5                   // lib打包信息
│  │  └──Index.d.ts                         // lib接口索引              
│  ├──entryability
│  │  └──EntryAbility.ets                   // 入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets             // 数据备份类
│  └──pages       
│     ├──animate1.ets                       // 示例页面
│     ├──animate2.ets                       // 示例页面   
│     ├──AVImageGenerator.ets               // 示例页面
│     ├──camera.ets                         // 示例页面     
│     ├──Index.ets                          // 示例页面
│     ├──playStateCallback.ets              // 示例页面     
│     └──StyleExample.ets                   // 示例页面
└──entry/src/main/resources                 // 应用资源目录
```


### 具体实现

1. 主要配套文档介绍易错API的使用规范。

### 相关权限

不涉及。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。

### 下载

如需单独下载本工程，执行如下命令：
```
git init
git config core.sparsecheckout true
echo ApiUsingStandards/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```