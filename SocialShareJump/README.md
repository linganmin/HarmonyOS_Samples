# 基于App Linking实现社交分享跳转

### 介绍
本示例基于App Linking实现一个社交类型的应用，可以通过Share Kit分享文章详情的App Linking链接给好友（畅连好友），好友可以点击链接实现应用跳转，直达文章详情，提升用户体验。当应用未安装应用时，一键直达文章详情页或者应用市场（未安装该社交应用的情况下，方便好友直接安装）。

### 效果预览
![image](screenshots/devices/image.gif)

使用说明
1. 在运行项目前，需要完成App Linking的配置，以及对应用进行手动签名，具体可以参考[使用App Linking实现应用间跳转](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/app-linking-startup)。
2. 在完成App Linking的配置后，请前往[Detail.ets](entry/src/main/ets/pages/Detail.ets)文件，将share()方法中的content参数替换为真实可用的链接地址，同时将[module.json5](./entry/src/main/module.json5)文件中uris的host修改为可用的域名。
3. 启动应用，点击首页文章列表项，跳转到详情页。
4. 点击详情页右上角的分享按钮拉起分享面板，分享至畅连好友。
5. 在畅连消息列表中点击分享的消息，进行页面跳转。

### 工程目录

```
├──entry/src/main/ets                           // 代码区
│  ├──common
│  │  ├──LazyDataSource.ets                     // 懒加载数据源管理类
│  │  └──Logger.ets                             // 日志打印类   
│  ├──entryability
│  │  └──EntryAbility.ets                       // 程序入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets                 // 数据备份恢复类
│  ├──model
│  │  └──Article.ets                            // 文章实体类
│  ├──pages
│  │  ├──Detail.ets                             // 文章详情页
│  │  └──Index.ets                              // 应用入口页
│  └──view
│     └──IArticleItem.ets                       // 文章列表项组件
└──service
   │──detail                                    // 文章Web详情页，用于部署到服务器
   └──index                                     // App Linking对应的Web页面
```

### 具体实现

* 通过Share Kit的systemShare模块实现分享功能。
* 应用首次启动时，通过deferredLink.popDeferredLink()获取用户此前点击的该应用相关链接，根据链接中的参数直接跳转到详情页。
* 在AppGallery Connect中配置直达应用市场，当应用未安装时，点击链接直接跳转到应用市场。


### 相关权限

不涉及。

### 依赖

不涉及。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。
2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。