# 多文件下载监听

### 介绍

本示例为开发者展示常见的多文件下载，介绍如何使用request模块实现多个文件下载进度和状态的监听管理。

### 效果预览
![](./screenshots/device/download.png)

### 工程目录

```
├──entry/src/main/ets/
│  ├──constants
│  │  └──Constants.ets                  // 公共常量类
│  ├──entryability
│  │  └──EntryAbility.ets               // 程序入口类
│  ├──pages                 
│  │  └──Index.ets                      // 首页
│  └──view     
│     ├──FileDownloadItem.ets           // 列表item项            
│     └──ProgressButton.ets             // 进度条按钮
└──entry/src/main/resources             // 应用静态资源目录
```

### 具体实现

1. Index页面中使用List实现下载列表（在downloadUrlArray变量中输入要下载的url数组）。
2. FileDownloadItem中实现列表项视图。
3. 在每个列表项中配置下载参数，创建下载任务，注册相关监听，在监听回调中获取文件的下载状态，将数据绑定到相应组件上。
4. 针对每个下载任务提供启动、暂停、恢复的功能操作。

### 相关权限

1. 网络使用权限：ohos.permission.INTERNET。

### 依赖
不涉及

### 约束与限制

1.本示例仅支持标准系统上运行，支持设备：华为手机。 

2.HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3.DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4.HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。