# 基于低功耗蓝牙实现设备间连接通信的能力

## 介绍
低功耗蓝牙（简称BLE）它是一种能够在低功耗情况下进行通信的蓝牙技术，与传统蓝牙相比，BLE的功耗更低，适用于需要长时间运行的低功耗设备，如智能手表、健康监测设备、智能家具等。
本示例主要介绍了设备之间通过蓝牙进行连接和通信的能力，BLE服务端开启广播后可传递数据、BLE客户端搜索可连接设备并在连接后接收广播数据。

## 预览效果
![](/screenshots/device/mate60pro.gif)

## 工程目录

``` 
├──entry/src/main/ets                                   // 全屏登录代码区
│  ├──entryability
│  │  └──EntryAbility.ets                               // 程序入口类
│  ├──model
│  │  └──BluetoothDevice.ets                            // 蓝牙设备 model定义
│  ├──pages                              
│  │  ├──BluetoothClient.ets                            // Bluetooth客户端
│  │  ├──BluetoothServer.ets                            // Bluetooth服务端
│  │  ├──HeartRate.ets                                  // 心率折线图
│  │  └──Index.ets                                      // 首页
│  ├──uicomponents                              
│  │  ├──EmptyPage.ets                                  // 设备为空时展示
│  │  ├──HeartRateGraph.ets                             // 折线图UI组件
│  │  └──NavigationBar.ets                              // 导航样式
│  ├──utils                              
│  │  ├──ArrayBufferUtils.ets                           // 转换方法
│  │  ├──DateUtils.ets                                  // Date处理方法
│  │  ├──Logger.ets                                     // 日志打印
│  │  └──MathUtils.ets                                  // number处理
│  └──viewmodel
│     ├──AdvertiseBluetoothViewModel.ets                // 蓝牙服务端接口定义页面
│     └──BluetoothClientModel.ets                       // 蓝牙客户端接口定义页面
└──entry/src/main/resources                             // 应用资源目录
``` 

## 使用说明
需要两台设备，一台作为BLE服务端，一台作为BLE客户端。
* BLE服务端

  点击开启心率广播按钮后，进行数据传送。
* BLE客户端

  搜索可连接蓝牙设备，连接成功后，接收数据，并通过折线图展示。

## 实现说明
* BLE服务端

  调用startAdvertising接口开始广播。

  断开连接时，调用stopAdvertising接口停止广播。
* BLE客户端

  调用startBLEScan接口搜索开启了蓝牙功能的设备。

  调用connect接口连接蓝牙。

  调用on(type: 'BLECharacteristicChange')订阅特征值变化
## 相关权限
* ohos.permission.ACCESS_BLUETOOTH   允许应用接入蓝牙并使用蓝牙能力，例如配对、连接外围设备等。

## 约束与限制

* 本示例仅支持标准系统上运行，支持设备：华为手机。

* HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

* DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

* HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。