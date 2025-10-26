# 基于延迟链接能力跳转应用详情页

## 简介

本示例展示了作为目标方应用（AppLinkingSampleDestination）如何获取拉起方应用（AppLinkingSampleOriginal）的延迟链接地址，并跳转详情页面，提升链接转化率；作为拉起方如何拉起集成了App Linking Kit的目标方应用，缩短应用链接打开步骤，提升用户体验。

1. 在目标方应用的module.json5里配置需要拉起的延迟链接的skills信息。
2. 在目标方应用中使用deferredLink.popDeferredLink()接口获取延迟链接的url。
3. 在拉起方应用中使用context.openLink()接口拉起延迟链接的url。

## 效果预览

|             **主页面**             |
| :--------------------------------: |
| ![](./SampleImg/device/sample.gif) |


## 配置与使用

### 目标方应用配置步骤

1. [创建项目](https://developer.huawei.com/consumer/cn/doc/app/agc-help-create-project-0000002242804048)及[应用](https://developer.huawei.com/consumer/cn/doc/app/agc-help-create-app-0000002247955506)。

2. 打开应用，使用[AppGallery Connect](https://developer.huawei.com/consumer/cn/service/josp/agc/index.html)配置的应用包名替换app.json5文件中的bundleName属性值。

3. 使用[手动签名](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-signing#section297715173233)创建一个签名，替换工程中build-profile.json5文件中的signingConfigs的内容。

4. 在[AppGallery Connect](https://developer.huawei.com/consumer/cn/service/josp/agc/index.html)平台开通App Linking服务，并且配置网址域名，具体操作步骤请参见[开发准备](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/applinking-preparations)。

5. 在应用的module.json5里面配置skills的相关信息，可以参考以下图片。

   ![](./SampleImg/setting/module.png)

### 拉起方应用配置步骤

打开应用，配置[自动签名](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-signing#section18815157237)并运行。

### 使用说明

1. 提前将拉起方应用（AppLinkingSampleOriginal）安装到手机上，点击页面上的按钮会触发打开链接的功能。
2. 首次安装并点击目标方应用（AppLinkingSampleDestination）会触发延迟链接功能，跳转到详情页面。

## 工程目录

### 目标方应用

```
├──entry/src/main/ets                         // 代码区
│  ├──entryability
│  │  └──EntryAbility.ets                     // 程序入口类
│  ├──pages                                   // 存放页面文件目录
│  │  ├──Index.ets                            // 主页面文件
│  │  └──Page1.ets                            // 详情页1
│  └──constants                               // 存放页面常量目录
│     └──Constants.ets                        // 常量文件
└──entry/src/main/resources                   // 应用资源目录
```

### 拉起方应用

```
├──entry/src/main/ets                         // 代码区
│  ├──common
│  │  └──GlobalContext.ets                    // 全局应用上下文类
│  ├──entryability
│  │  └──EntryAbility.ets                     // 程序入口类
│  ├──pages                                   // 存放页面文件目录
│  │  └──Index.ets                            // 主页面文件
│  └──constants                               // 存放常量文件目录
│     └──Constants.ets                        // 常量文件
└──entry/src/main/resources                   // 应用资源目录
```

## 具体实现

- 目标方应用调用deferredLink.popDeferredLink()接口获取App Linking的延迟链接，并跳转到详情页面。
- 拉起方应用调用系统的openLink()接口打开集成了App Linking Kit的目标方应用。

**参考**

1. [AppLinkingSampleDestination\entry\src\main\ets\pages\Index.ets](./AppLinkingSampleDestination/entry/src/main/ets/pages/Index.ets)
2. [AppLinkingSampleDestination\entry\src\main\ets\pages\Page1.ets](./AppLinkingSampleDestination/entry/src/main/ets/pages/Page1.ets)
3. [AppLinkingSampleOriginal\entry\src\main\ets\pages\Index.ets](./AppLinkingSampleOriginal/entry/src/main/ets/pages/Index.ets)


## 相关权限

不涉及。

## 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。 
2. 本示例支持API version 17及以上。 
3. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
4. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
5. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。 
