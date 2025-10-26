# Cross-Process Communication by Listening to 127.0.0.1 Through Socket

## Overview

This sample showcases cross-process communication by listening to 127.0.0.1 through socket.

## Preview

![](screenshots/device/SocketCommunication_EN.gif)

## How to Use

1. Open the server app and touch the **Initialize** button to initialize the server.
2. Open the client app and touch the **Connect to server** button to connect the client to the server.
3. Back on the server app, enter **123456** in the text box, and touch the send icon.
4. Return to the client app. The client receives the message from the server and displays it on the page.
5. On the client app, enter **456789** in the text box, and touch the send icon.
6. Return to the server app. The server app receives the message from the client and displays it on the page.

## Required Permissions

**ohos.permission.INTERNET**: allows an app to access the Internet.

## Dependencies

N/A

## Constraints

1. The sample is only supported on Huawei phones with standard systems.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.
