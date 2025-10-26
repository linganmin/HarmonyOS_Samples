# 基于Navigation组件实现模拟登录和注销的场景

## 介绍

基于Navigation组件实现导航跳转，采用PromptAction实现弹窗。模拟登录和注销的场景实现，且界面满足一多适配。应用登录符合隐私要求，实现正确的跳转逻辑，满足更好的用户体验。

## 预览效果
手机运行效果图如下：

![](/screenshots/image1.png)

折叠屏运行效果图如下：

![](/screenshots/image4.png)

tablet运行效果图如下：

![](/screenshots/image7.png)

## 工程目录

``` 
├──entry/src/main/ets                                   // 全屏登录代码区
│  ├──common
│  │  └──CommonConstants.ets                            // 常量类
│  ├──entryability
│  │  └──EntryAbility.ets                               // 程序入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  ├──pages                              
│  │  ├──AuthorizedDialog.ets                           // 隐私授权弹窗
│  │  ├──Index.ets                                      // 首页
│  │  ├──Login.ets                                      // 登录页
│  │  └──Logout.ets                                     // 退出登录页
│  └──utils.ets
│     └──JudgeHasNet.ets                                // 判断网络是否连接
└──entry/src/main/resources                             // 应用资源目录
├──login/src/main/ets                                   // 全屏登录代码区
│  ├──common
│  │  └──CommonConstants.ets                            // 常量类
│  ├──loginability
│  │  └──LoginAbility.ets                               // 程序入口类
│  ├──pages                              
│  │  ├──AuthorizedDialog.ets                           // 隐私授权弹窗
│  │  ├──Index.ets                                      // 首页
│  │  ├──Login.ets                                      // 登录页
│  │  └──Logout.ets                                     // 退出登录页
│  └──utils.ets
│     └──JudgeHasNet.ets                                // 判断网络是否连接
└──login/src/main/resources                             // 应用资源目录
``` 

## 使用说明

该示例分两个模块：

* 运行entry模块中的代码，登录页面是全屏展示。无网络时，点击登录会有无网络连接提示。输入手机号和密码后，未勾选协议时，点击登录会弹出确认勾选协议弹窗，点击确认登录即表示同意并勾选了协议。登录成功后，首页展示用户信息。注销操作可在登录后，点击设置，弹出的模态框里面点击退出登录来实现。


* 运行login模块中的代码，登录页面是模态弹窗展示，其他页面展示和逻辑与entry模块中一致。

## 相关权限

ohos.permission.INTERNET: 允许使用网络

ohos.permission.GET_NETWORK_INFO: 允许应用获取数据网络信息

## 约束与限制

* 本示例仅支持标准系统上运行，支持设备：华为手机。

* HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

* DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

* HarmonyOS SDK版本：HarmonyOS 5.0.5 Release及以上。