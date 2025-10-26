## 基于AppStartup初始化启动任务

### 介绍

本示例通过系统能力[StartupConfigEntry](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-app-appstartup-startupconfig)、[StartupTask](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-app-appstartup-startuptask)和[startupManager](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-app-appstartup-startupmanager)
实现当应用启动时，同步或异步地做一些初始化任务，加快应用启动速度。 帮助开发者掌握ArkUI启动框架AppStartup，让执行启动任务的代码变得更加简洁清晰、容易维护。

### 预览效果
![image](screenshots/device/startWork.gif)

### 使用说明

1. 启动应用，进入应用主界面，检索日志“AutoMode Task execute complete”，表示自动初始化任务执行完成。
2. 点击“自动模式”按钮，进入二级页面查看自动初始化任务的结果。
3. 点击“手动模式”按钮，执行并手动初始化任务的结果，可检索日志“Manual Task execute success”。

### 工程目录

``` 
├──entry/src/main/ets                          
│  ├──common
│  │  ├──Constants.ets                  // 公共常量
│  │  └──GlobalBuilderContext.ets       // 缓存全局@Builder
│  ├──entryability
│  │  └──EntryAbility.ets               // 程序入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets         // 自定义应用数据转换和迁移模板类
│  ├──pages
│  │  ├──AutoModePage.ets               // 自动模式页面
│  │  ├──Index.ets                      // 首页
│  │  └──ManualModePage.ets             // 手动模式页面
│  ├──startup
│  │  ├──FileTask.ets                   // 文件读写任务
│  │  ├──ImageKinfeTask.ets             // 图片框架Imagekinfe初始化任务
│  │  ├──KvManagerUtilTask.ets          // 分布式数据库初始化任务
│  │  ├──KVStoreTask.ets                // 分布式数据库写入脏数据任务
│  │  ├──RdbStoreTask.ets               // 关系型数据库初始化任务
│  │  ├──ResourceManagerTask.ets        // resource资源初始化任务
│  │  └──StartupConfig.ets              // 启动框架配置能力
│  ├──util
│  │  └──SingleKVStore.ets              // 数据库操作工具类
│  └──view                        
│     ├──AutoModeView.ets               // 自动模式 view
│     └──ManualModeView.ets             // 手动模式 view
└──entry/src/main/resources             // 应用资源目录
``` 

### 具体实现

1. 定义启动框架配置文件[startup_config.json](entry/src/main/resources/base/profile/startup_config.json)，并在[module.json](entry/src/main/module.json5)中引用。
2. 设置启动参数[StartupConfig.ets](entry/src/main/ets/startup/StartupConfig.ets)
3. 为每个待初始化组件添加启动任务[startup下的Task](entry/src/main/ets/startup)
4. 手动模式启动任务[startupManager.run](entry/src/main/ets/pages/Index.ets)

### 相关权限

不涉及

### 约束与限制

* 本示例仅支持标准系统上运行，支持设备：华为手机。
* HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
* DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
* HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。
