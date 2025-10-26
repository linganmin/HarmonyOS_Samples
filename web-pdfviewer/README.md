# 基于Web组件实现预览PDF文件功能

### 介绍

本示例通过Web组件实现预览本地PDF文件和预览网络PDF文件，Tabs容器组件包含了两个独立的TabContent子组件，分别标示为预览本地PDF文件和预览网络PDF文件。每个子组件内部构建一个Web组件。第一个Web组件利用resource协议关联本地PDF文件路径以预览本地存储的PDF资源；第二个Web组件则通过配置网络链接属性，实现从互联网加载并预览远程PDF文件内容。

### 效果预览

![](screenshots/device/WebPDFViewer.gif)


##### 使用说明

- 运行代码前,需要把[CommonConstants.ets](entry/src/main/ets/constants/CommonConstants.ets)文件中的REMOTE_URL替换成网络PDF文件地址。
- 进入页面默认预览本地PDF文件，点击预览网络PDF文件按钮可以切换到预览网络PDF文件模块。

### 工程目录

```
├──entry/src/main/ets/
│  ├──constants
│  │  └──CommonConstants.ets         // 公共常量类
│  ├──entryability
│  │  └──EntryAbility.ets            // 程序入口类
│  ├──pages
│  │  └──Index.ets                   // 应用首页
│  └──utils
│     └──Logger.ets                  // 日志类
└──entry/src/main/resources          // 应用静态资源目录
```

### 具体实现

1. 本地PDF加载:通过resource协议（需在工程resources/rawfile 目录下添加PDF文件,通过RESOURCE_URL获取的PDF文件）来实现本地PDF文件资源的装载与呈现，在无需网络连接的情况下，也能顺利加载并预览用户本地PDF资源。
2. 网络PDF加载:通过设置网络链接属性，能够对接互联网上的PDF文件资源。提供有效的远程PDF文件URL（REMOTE_URL），实现云端PDF资源的加载与预览。

### 相关权限

- 允许应用使用Internet网络权限：ohos.permission.INTERNET。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。