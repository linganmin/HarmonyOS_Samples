# 拉起目标方应用的详情页面

## 简介

本示例展示了作为拉起方如何拉起集成了App Linking Kit的目标方应用，缩短应用链接打开步骤，提升用户体验：

使用context.openLink()接口拉起延迟链接的url。

## 效果预览

|              **主页面**              |
| :----------------------------------: |
| ![](./screenshots/device/sample.gif) |

## 配置与使用

### 配置步骤

打开应用，配置[自动签名](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-signing#section18815157237)并运行。

### 使用说明

运行应用，点击页面上的按钮会触发打开链接的功能。

## 工程目录

```
├──entry/src/main/ets                         // 代码区
│  ├──common
│  │  └──GlobalContext.ets                    // 全局应用上下文类
│  ├──entryability
│  │  └──EntryAbility.ets                     // 程序入口类
│  ├──pages                                   // 存放页面文件目录
│  │  └──Index.ets                            // 入口类文件
│  └──constants                               // 存放常量文件目录
│     └──Constants.ets                        // 常量文件
└──entry/src/main/resources                   // 应用资源目录
```

## 具体实现

调用系统的openLink()接口打开集成了App Linking Kit的目标方应用。

**参考**

[entry\src\main\ets\pages\Index.ets](./entry/src/main/ets/pages/Index.ets)

## 相关权限

不涉及。

## 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。
2. 本示例支持API version 17及以上。
3. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
4. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
5. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。 

