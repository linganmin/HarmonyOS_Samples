# 实现应用网络重连功能

## 介绍

本示例通过HTTP下载、RCP下载和Socket下载三个案例，介绍了应用网络超时重连、应用网络恢复后重连、应用网络前后台切换后重连。其中，HTTP下载、RCP下载使用的网络视频资源，Socket下载使用的本地服务端资源，通过网络监听和状态变量监听获取应用的网络状态和应用的前后台状态，进而对网络进行重连。

## 效果预览

![](screenshots/device/socket_server.gif)

## 使用说明

1. 打开服务端应用，点击“初始化”按钮，对服务端进行初始化。

## 工程目录

```
├──entry/src/main/ets                         // 代码区
│  ├──constants
│  │  └──CommonConstants.ets                  // 公共常量
│  ├──entryability
│  │  └──EntryAbility.ets       
│  ├──model
│  │  └──TransmitInfo.ets                     // 实体类       
│  ├──pages
│  │  └──ServerSocketPage.ets                 // 主页面
│  └──utils
│     └──Logger.ets                           // 日志文件
└──entry/src/main/resources                   // 应用资源目录
```

## 具体实现

1. import需要的socket模块。
2. 创建一个TCPSocketServer连接，返回一个TCPSocketServer对象。
3. 绑定本地IP地址和端口，监听并接受与此套接字建立的客户端TCPSocket连接。
4. 订阅TCPSocketServer的connect事件，用于监听客户端的连接状态。
5. 客户端与服务端建立连接后，返回一个TCPSocketConnection对象，用于与客户端通信。
6. 订阅TCPSocketConnection相关的事件，通过TCPSocketConnection向客户端发送数据，客户端保存文件数据到相册。

## 相关权限

- 允许应用使用Internet网络权限:ohos.permission.INTERNET。

## 依赖

不涉及

## 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。
2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。