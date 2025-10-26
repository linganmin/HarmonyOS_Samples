# Cross-Process Communication by Listening to 127.0.0.1 Through Socket — Server

## Overview

This sample showcases cross-process communication by listening to 127.0.0.1 through socket.

## Preview

![](../screenshots/device/SocketCommunication_EN.gif)

## How to Use

1. Open the server app and touch the **Initialize** button to initialize the server.
2. Open the client app and touch the **Connect to server** button to connect the client to the server.
3. Back on the server app, enter **123456** in the text box, and touch the send icon.
4. Return to the client app. The client receives the message from the server and displays it on the page.
5. On the client app, enter **456789** in the text box, and touch the send icon.
6. Return to the server app. The server app receives the message from the client and displays it on the page.

## Project Directory

```
├──entry/src/main/ets                        // Code
│  ├──constants
│  │  └──CommonConstants.ets                  // Common constants
│  ├──entryability
│  │  └──EntryAbility.ets       
│  ├──model
│  │  └──TransmitInfo.ets                     // Entity class      
│  ├──pages
│  │  └──ServerSocketPage.ets                 // Main page
│  └──utils
│     └──Logger.ets                           // Log utility
└──entry/src/main/resources                   // Static resources
```

## How to Implement

1. Import the **socket** module.

2. Create a TCP socket server connection. A **TCPSocketServer** object is returned.
3. Bind the local IP address and port, and listen for and accept TCP socket connections established over the socket.
4. Subscribe to **connect** events of the **TCPSocketServer** object to listen for client connection status changes.
5. Set up a connection between the client and the server. A **TCPSocketConnection** object is returned.
6. Subscribe to events of the **TCPSocketConnection** object, and send data to the client through the **TCPSocketConnection** object.
7. Close the connection between the client and the server.
8. Unsubscribe from events of the **TCPSocketConnection** and **TCPSocketServer** objects.

## Permissions

**ohos.permission.INTERNET**: allows an app to access the Internet.

## Dependencies

N/A

## Constraints

1. The sample is only supported on Huawei phones with standard systems.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.