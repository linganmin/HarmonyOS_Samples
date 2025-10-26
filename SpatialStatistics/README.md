# 实现系统和文件空间的统计与展示

### 介绍

本示例介绍应用空间统计和文件系统空间统计接口的使用，包括对内外卡的空间查询，对应用分类数据统计的查询，对应用数据的查询等。提供文件系统相关存储信息的功能，向应用程序提供获取文件系统总字节数、空闲字节数接口。

### 效果图预览

![](screenshots/device/SpatialStatistics.gif)

##### 使用说明

1. 主页面，点击“应用空间统计”按钮，进入应用空间统计页面。
2. 点击“应用空间统计”，展示应用空间数据。
3. 点击左上角“返回”按钮，返回主页面。
4. 主页面，点击“文件系统空间统计”按钮，进入文件系统空间统计页面。
5. 点击“文件系统空间统计”，展示文件系统相关存储数据。

## 工程目录

```
├──entry/src/main/ets                         // 代码区
│  ├──constants
│  │  └──Constants.ets                        // 公共常量
│  ├──entryability
│  │  └──EntryAbility.ets                     // 程序入口
│  ├──pages
│  │  ├──AppSpatialPage.ets                   // 应用空间统计页面
│  │  ├──FileSpacePage.ets                    // 文件系统空间统计页面
│  │  └──Home.ets                             // 主页面
│  ├──utils
│  │  └──Logger.ets                           // 日志文件
│  ├──view
│  │  └──SpaceInfo.ets                        // 卡片子组件
│  └──viewmodel
│     └──CommonViewModel.ets                  // 公共方法
└──entry/src/main/resources                   // 应用资源目录
```

### 相关权限

不涉及。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。