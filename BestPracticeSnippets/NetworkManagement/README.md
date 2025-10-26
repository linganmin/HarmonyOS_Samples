# **网络管理与状态监听**
## 介绍
日常生活中，经常会使用网络。网络质量在不同场景下会有所变化，当使用场景发生变化时，需要对网络状态进行监听，如查询当前网络是否可用、判断网络质量的优劣等，并据此做出切换网络或提示用户等操作，从而提升用户体验。
## 预览效果
![](screenshots/image.gif)
## 工程目录
``` 
├──entry/src/main/ets                                   // 代码区
│  ├──entryability
│  │  └──EntryAbility.ets                               // 程序入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  └──pages
│     ├──CellularNetworkQuery.ets                       // 蜂窝网络查询页
│     ├──GetCurrentNetworkInfo.ets                      // 当前网络信息查询页
│     ├──GetNetworkConnectionInfo.ets                   // 网络连接信息查询页
│     ├──Index.ets                                      // 首页
│     ├──ListeningNetworkStatus.ets                     // 网络状态监听页
│     └──WiFiQuery.ets                                  // WiFi网络查询页
└──entry/src/main/resources                             // 应用资源目录
``` 
## 使用说明
运行程序，点击“查询网络连接信息”按钮，进入页面后，可查询当前网络连接类型、查询当前网络是否可用、查询网络路由信息、网络链路信息。

点击“查询当前网络信息”按钮，进入页面后，可进行蜂窝网络相关查询和WiFi网络相关查询。

点击“网络状态监听”按钮，进入页面后， 点击视频左下方的播放按键，视频会开始播放。然后可以执行下方的操作：

* 点击“模拟网络不可用”按钮时，模拟当前网络不可正常使用的场景，若视频正在播放，此时会暂停视频播放，并弹出相应提示。

* 点击“模拟网络丢失”按钮时，模拟网络连接丢失的场景，若视频正在播放，此时会暂停视频播放，并弹出相应提示。

* 点击“模拟弱网环境”按钮时，模拟当前处于弱网环境，若视频正在播放，此时会暂停视频播放，并弹出相应提示。

* 点击“模拟模拟网络低质量环境”按钮时，模拟当前处于网络低质量环境，若视频正在播放，此时会暂停视频播放，并弹出相应提示。

* 点击“切换视频到低清晰度”按钮时，会切换当前视频到更低的清晰度，当网络质量差的情况下可自行切换。

* 点击“切换视频到高清晰度”按钮时，会切换当前视频到较高的清晰度，当网络质量好的情况下可自行切换。

注：此示例代码使用的是加载本地视频的方式，开发时，可以根据需要使用其他加载视频资源的方式，如加载沙箱路径视频、加载网络视频。具体请参见：[加载视频资源](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-common-components-video-player#加载视频资源)

## 相关权限

* ohos.permission.SET_WIFI_INFO    设置WIFI信息

* ohos.permission.GET_WIFI_INFO    获取WIFI信息

* ohos.permission.GET_NETWORK_INFO   获取网络信息

## 约束与限制

* 本示例仅支持标准系统上运行，支持设备：华为手机。

* HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

* DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

* HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。

## 下载

如需单独下载本工程，执行如下命令：
```
git init
git config core.sparsecheckout true
echo NetworkManagement/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```