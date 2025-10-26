# 内存检测样例代码工程

### 介绍

本示例为内存检测样例代码工程，包含最佳实践文档中涉及的分析方法、优化建议、问题案例等内容的局部样例代码。工程本身不具备实际功能，开发者请直接阅读具体源码结合文档来理解地址越界、资源泄漏类问题的产生原因，规避方法等。


### 效果预览

不涉及

### 工程目录
```
├──entry/src/main/
│  ├──cpp
│  │   ├──CMakeLists.txt
│  │   ├──address_problems.cpp                          // 地址问题示例
│  │   ├──address_sanitizer_case1.cpp                   // 地址优化示例1
│  │   ├──address_sanitizer_case2.cpp                   // 地址优化示例2
│  │   ├──address_sanitizer_case3.cpp                   // 地址优化示例3
│  │   ├──address_sanitizer_case4.cpp                   // 地址优化示例4
│  │   ├──resource_leak.cpp                             // 泄露示例
│  │   ├──task_demo1.cpp                                // 任务示例1
│  │   ├──task_demo2.cpp                                // 任务示例2
│  │   └──napi_init.cpp                                 // C++ init示例代码
│  └──ets
│      ├──pages
│      │      ├──FdLeakDetection.ets                    // 泄露检测示例代码
│      │      ├──Index.ets                              // 首页
│      │      ├──MemoryLeakDetection.ets                // 内存泄露检测示例代码1
│      │      └──MemoryLeakDetection2.ets               // 内存泄露检测示例代码2
│      ├──entryability
│      │      └──EntryAbility.ets                       // Ability的生命周期回调内容
│      └──entrybackupability
│             └──EntryBackupAbility.ets                 // 应用数据备份恢复类
└──entry/src/main/resources                             // 应用资源目录 
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
echo MemoryDetection/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```