# 实现获取设备标识功能

## 介绍
设备标识是一种用于标识设备的代码或符号，应用可以通过设备标识来区分不同设备，HarmonyOS提供了三种设备标识：
* [ODID（开发者匿名设备标识符）](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-device-info#属性)：一般用于设别同一设备上运行的同一个开发者的应用，标识应用身份。
* [OAID（开放匿名设备标识符）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/oaid-service)：一般用于广告跟踪，可在保护用户个人数据隐私安全的前提下，向用户提供个性化广告。
* [AAID（应用匿名标识符）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/push-get-aaid)：一般用于应用的推送，标识应用身份。

## 预览效果
![](./screenshots/device/Effect.gif)

## 工程目录
``` 
├──entry/src/main/ets                                   // 代码区
│  ├──entryability
│  │  └──EntryAbility.ets                               // 程序入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  ├──pages                              
│  │  └──Index.ets                                      // 入口文件
│  └──view
│     └──CreateIDComponent.ets                          // 创建设备标识页面
└──entry/src/main/resources                             // 应用资源目录
``` 
## 使用说明
依次点击应用首页的3个按钮，进入创建设备标识页面后，可以实现以下3个场景：
* 创建ODID，创建成功后显示在上方输入框内，点击保存按钮将设备标识保存至关键资产中，最后点击查询按钮，查询成功后即可显示在下方输入框内。
* 创建AAID，创建成功后显示在上方输入框内，点击保存按钮将设备标识保存至关键资产中，最后点击查询按钮，查询成功后即可显示在下方输入框内。
* 创建OAID，创建成功后显示在上方输入框内，点击保存按钮将设备标识保存至关键资产中，最后点击查询按钮，查询成功后即可显示在下方输入框内。

## 实现说明
* 通过[deviceInfo](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-device-info#属性)获取ODID
* 通过[identifier.getOAID](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-oaid#identifiergetoaid)获取OAID
* 通过[AAID.getAAID](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/push-aaid-api#section573317917425)获取AAID
* 通过[asset.add](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-asset#assetadd)新增一条关键资产
* 通过[asset.query](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-asset#assetquery)查询一条或多条符合条件的关键资产

## 相关权限
允许应用读取开放匿名设备标识符：ohos.permission.APP_TRACKING_CONSENT。

## 约束与限制
* 本示例仅支持标准系统上运行，支持设备：华为手机。

* HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

* DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

* HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。