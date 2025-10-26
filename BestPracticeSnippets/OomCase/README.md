# OOM样例代码工程

### 介绍

本示例为OOM样例代码工程。工程本身不具备实际功能，开发者请直接阅读具体源码结合文档来理解OOM类问题的产生原因，规避方法等。


### 效果预览

不涉及

### 工程目录
```
├──entry/src/main                                    // 代码区
│  ├──cpp
│  │  └──napi_init.cpp                               // C++样例代码
│  └──ets      
│     └──pages             
│        └──Index.ets                                // ArkTS样例代码            
└──entry/src/main/resources                          // 应用资源目录
```

### 具体实现

不涉及。

### 相关权限

不涉及。

### 依赖

不涉及。

###  约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机、华为PC/2in1设备、华为平板。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。

### 下载

如需单独下载本工程，执行如下命令：
```
git init
git config core.sparsecheckout true
echo OomCase/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```