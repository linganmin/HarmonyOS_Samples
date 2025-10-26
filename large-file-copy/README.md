# 基于定长buffer的大文件拷贝解决方案

### 介绍

文件拷贝是应用开发中的一个常见场景，通常有两种方式，一是直接读写文件的全部内容，二是使用buffer多次读写。前者的优点在于使用简单，但是在大文件场景下，内存占用较高，影响应用性能；后者的优点在于内存占用较小，但是编程稍显复杂。本例将展示如何使用buffer来将大文件的rawfile复制到应用沙箱。

### 效果预览
![Index](screenshot/LargeFileCopy.gif)

### 工程目录
```
├──entry/src/main/ets               
│  ├──constants
│  │  └──BigFileCopyConstants.ets        // 常量类               
│  ├──entryability  
│  │  └──EntryAbility.ets               // 程序入口
│  └──view                              
│     └──Index.ets                      // 首页
└──entry/src/main/resources             // 应用资源目录
```

**使用说明**

1. 点击拷贝按钮开始复制。
2. 当复制进度达到100%之后，点击预览按钮进行文件的预览，以验证文件复制的正确性。
3. 如果要反复验证本场景，请在复制完成之后，点击重置按钮，重置进度，再进行后续验证。

### 相关权限

不涉及

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。
2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。
