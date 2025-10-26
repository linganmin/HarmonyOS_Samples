# 实现网络管理的功能

### 介绍
本示例通过@ohos.net.connection接口实现网络的详情、域名解析、网络监听等功能，注意需要申请ohos.permission.GET_NETWORK_INFO和ohos.permission.INTERNET权限。帮助开发者掌握如何处理检查网络、监听网络等的网络相关场景。

### 效果预览：
![image](screenshots/network.gif)


使用说明：

1.启动应用，在点击**检查网络**、**网络详情**、**网络连接信息**后，展示对应的信息；

2.在域名解析的模块下，输入对应的域名后，点击**域名解析**，展示解析的域名ip地址；

3.在网络监听模块下，开启网络监听后，展示当前监听的网络信息；关闭网络监听后，停止监听网络信息。


### 工程目录
```
├──entry/src/main/ets/
│  ├──common 
│  │  └──Constant.ets
│  ├──entryability
│  │  └──EntryAbility.ets                      
│  ├──pages
│  │  └──Index.ets
└──entry/src/main/resources                              
```

### 具体实现
使用@ohos.net.connection（网络连接管理）接口实现网络的详情、域名解析、网络监听等功能。代码：Index.ets


### 相关权限
允许应用获取数据网络信息：ohos.permission.GET_NETWORK_INFO

允许使用Internet网络：ohos.permission.INTERNET

### 依赖

不涉及。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 6.0.0 Beta5及以上。

3. DevEco Studio版本：DevEco Studio 6.0.0 Beta5及以上。

4. HarmonyOS SDK版本：HarmonyOS 6.0.0 Beta5 SDK及以上。