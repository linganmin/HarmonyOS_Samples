# 基于Socket实现跨进程通信-服务端

## 介绍

本示例通过Socket监听接口，实现跨进程通信。客户端应用连接服务端。输入消息数据，发送给对端；客户端、服务端接受到发送过来的信息，并展示在页面上。

## 效果预览

![](../screenshots/device/SocketCommunication.gif)

## 使用说明

1. 打开服务端应用，点击“初始化”按钮，对服务端进行初始化。
2. 打开客户端应用，点击“连接服务端”按钮，连接服务端。
3. 返回服务端应用，输入框输入“123456”，点击“发送”图标按钮。
4. 返回客户端应用，客户端接收到服务端发送过来的信息，并展示在页面上。
5. 客户端页面，输入框输入“456789”，点击“发送”图标按钮。
6. 返回服务端应用，服务端接收到客户端发送过来的信息，并展示在页面上。

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
6. 订阅TCPSocketConnection相关的事件，通过TCPSocketConnection向客户端发送数据。 
7. 主动关闭与客户端的连接。 
8. 取消TCPSocketConnection和TCPSocketServer相关事件的订阅。

## 相关权限

- 允许应用使用Internet网络权限:ohos.permission.INTERNET。

## 依赖

不涉及

## 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。