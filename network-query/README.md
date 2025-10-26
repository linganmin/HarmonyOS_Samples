# 实现常见网络信息查询

### 介绍

本示例使用 Network Kit 和 Telephony Kit
实现了四个常用的网络查询功能。开发者可参考这些实现，快速完成网络状态判断、MAC地址查询、wifi列表查询、蜂窝网络相关数据的获取以及监听网络服务与质量变化等常见功能。

### 效果预览

| 连接到指定网络                                  | 网络状态感知                                   | WLAN定位                                   | 网络故障诊断                                   |
|------------------------------------------|------------------------------------------|------------------------------------------|------------------------------------------|
| ![image](screenshots/devices/Scene1.png) | ![image](screenshots/devices/Scene2.png) | ![image](screenshots/devices/Scene3.png) | ![image](screenshots/devices/Scene4.png) |

**使用说明**
1. 启动应用，点击首页按钮分别进入对应的场景页面。
2. 连接到指定网络场景：首先点击底部“获取系统扫描wifi”按钮获取wifi列表，然后点击列表中的项，在弹出窗中输入密码以连接wifi。由于wifi列表数据依赖于系统扫描，可能存在延时，开发者可以进入设置页面刷新wifi列表。
3. 网络状态感知场景：视频播放过程中，变化网络环境，如断开和连接网络，wifi和数据网络切换。
4. WLAN定位场景：点击底部按钮，页面显示wifi的mac地址。
5. 网络故障诊断场景：点击底部的按钮，显示网络类型、路由信息等等；若需通过网速和信号强度来检测网络问题，则需修改[NetworkDiagnostics.ets](entry/src/main/ets/view/NetworkDiagnostics.ets)文件中的文件下载地址TEST_DOWNLOAD_URL，10秒后将显示网络检测结果。

### 工程目录

```
├──entry/src/main/ets                           // 代码区
│  ├──common
│  │  ├──Logger.ets                             // 日志打印类   
│  │  ├──NetworkUtil.ets                        // 网络工具类 
│  │  ├──TimeUtil.ets                           // 时间格式转化工具类
│  │  └──ToastUtil.ets                          // Tost工具类
│  ├──component
│  │  ├──NetInfoItem.ets                        // 网络信息列表项  
│  │  └──WlanItem.ets                           // WLAN列表项
│  ├──entryability
│  │  └──EntryAbility.ets                       // 程序入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets                 // 数据备份恢复类
│  ├──pages
│  │  └──Index.ets                              // 应用入口页
│  └──view
│     ├──NetworkDiagnostics.ets                 // 网络故障诊断场景
│     ├──NetworkMonitor.ets                     // 网络状态感知场景
│     ├──WifiConnector.ets                      // 连接到指定wifi场景
│     └──WlanLocation.ets                       // WLAN定位场景
└──entry/src/main/resources                     // 应用静态资源目录
```

### 具体实现

* 使用@ohos.net.connection（网络连接管理）接口实现网络的详情、域名解析、网络监听等功能。
* 使用@ohos.wifiManager (WLAN)接口实现wifi网络的信息获取、wifi列表的获取、wifi连接等功能。获取到的数据可能为缓存数据，与实际数据可能不一致，具体可以参考系统wifi[扫描周期](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/scan-development-guide#%E5%91%A8%E6%9C%9F%E6%89%AB%E6%8F%8F)。
* 使用@ohos.telephony.radio (网络搜索)接口实现蜂窝网络的信息获取。

### 相关权限

* 允许使用Internet网络：ohos.permission.INTERNET。
* 允许应用获取设备位置信息：ohos.permission.LOCATION。
* 允许应用获取设备模糊位置信息：ohos.permission.APPROXIMATELY_LOCATION。
* 获取网络状态权限：ohos.permission.GET_NETWORK_INFO。
* 允许应用获取wifi信息：ohos.permission.GET_WIFI_INFO。
* 允许应用配置wifi设备：ohos.permission.SET_WIFI_INFO。

### 依赖

不涉及。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。
2. HarmonyOS系统：HarmonyOS 5.1.0 Release及以上。
3. DevEco Studio版本：DevEco Studio 5.1.0 Release及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.1.0 Release SDK及以上。