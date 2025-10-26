# 通过module.json5文件配置应用快捷打开方式入口
## 介绍
桌面快捷方式能让用户快速访问应用的核心功能，有效提高操作效率，同时增加用户对应用的依赖性。

以导航场景为例，为常去的地点（例如家、公司等）创建导航方式，点击即可启动地图应用并开始导航。
## 预览效果
![](/screenshots/image.gif)
## 工程目录
````
├──entry/src/main/ets                                   // 代码区
│  ├──entryability
│  │  └──EntryAbility.ets                               // 程序入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  ├──pages                              
│  │  ├──GoCompany.ets                                  // 我的公司页
│  │  ├──GoHouse.ets                                    // 我的家页
│  │  └──Index.ets                                      // 首页
│  └──util
│     └──CommonFunction.ets                             // 公共方法
└──entry/src/main/resources                             // 应用资源目录
````
## 使用说明
长按应用图标，即可出现快捷方式列表。点击对应图标，即可快速打开应用中对应的页面。
## 实现说明
* 在/resources/base/profile/目录下配置shortcuts_config.json配置文件。

* 在module.json5配置文件的abilities标签中，针对需要添加快捷方式的UIAbility进行配置metadata标签，使shortcut配置文件对该UIAbility生效。

## 相关权限
无
## 约束与限制
* 本示例仅支持标准系统上运行，支持设备：华为手机。

* HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

* DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

* HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。