# Network Reconnection

## Overview
This sample uses HTTP download, RCP download, and Socket download as examples to describe the reconnection upon application network timeout, network restoration, and application foreground/background switchover. The HTTP download and RCP download are used for network video resources, and the Socket download is used for local server resources. You can obtain the foreground or background state of an application through network listening and state variable listening to implement network reconnection.

## Effect

![](screenshots/device/net_connection_en.gif)

## How to Use

1.Open the server application and touch Initialize to initialize the server.
2.Open the client application and touch Socket Download to access the Socket Download page.
3.On the Socket Download page, touch Save to Gallery to download the video file.
4.On the HTTP Download page, touch Save to Gallery to download the video file.
5.On the RCP Download page, touch Save to Gallery to download the video file.

## Project Directory

```
├──entry/src/main/ets                         // Code area 
│  ├──constants 
│  │  └──CommonConstants.ets                  // Common constants 
│  ├──entryability 
│  │  └──EntryAbility.ets        
│  ├──entrybackupability 
│  │  └──EntryBackupAbility.ets            
│  ├──pages 
│  │  ├──HTTPReconnection.ets                 // HTTP download page 
│  │  ├──Index.ets                            // Home page 
│  │  ├──RCPReconnection.ets                  // RCP download page 
│  │  └──SocketReconnection.ets               // Socket download page 
│  └──utils 
│     ├──ConnectionUtil.ets                   // Network listening utility class 
│     └──Logger.ets                           // Log utility 
└──entry/src/main/resources                   // Application resources
```

## How to Implement

1.Import the required socket module.
2.Create a TCP socket server connection. A TCPSocketServer object is returned.
3.Bind the local IP address and port, and listen for and accept TCP socket connections established over the socket.
4.Subscribe to connect events of the TCPSocketServer object to listen for client connection status changes.
5.Set up a connection between the client and the server. A TCPSocketConnection object is returned.
6.Subscribe to events of the TCPSocketConnection object, send data to the client through the TCPSocketConnection object, and save file data to Gallery.
7.Use requestInStream to complete HTTP download, and use SaveButton to save files to Gallery.
8.Use the get method to complete RCP download, and use SaveButton to save files to Gallery.

## Permissions

- ohos.permission.INTERNET: allows an application to access the Internet.
- ohos.permission.GET_NETWORK_INFO: allows an application to obtain network information.


## Dependencies

N/A

## Constraints

1.This sample is only supported on Huawei phones with standard systems.
2.The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.
3.The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.
4.The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.