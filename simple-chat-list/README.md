# 实现简单聊天列表功能

## 介绍

本示例基于List组件实现简单聊天列表功能，包含联系人页面和聊天页面。主要涉及左滑删除、置顶、回到顶部、拖拽排序、新增聊天记录以及下拉加载等功能。

## 预览效果
<img src='./screenshots/device/effect.gif' width='320'>

## 工程目录

```
├──entry/src/main/ets       // 代码区
│ ├──common
│ |  └──CommonConstants.ets // 列表数据
│ ├──entryability
│ |  └──EntryAbility.ets    // 程序入口类
│ ├──entrybackupability
│ |  └──EntryBackupAbility.ets
│ └──pages
│    ├──ChatPage.ets        // 聊天页面
│    └──Index.ets           // 联系人页面
└──entry/src/main/resources // 应用资源目录
```

## 使用说明

1. 打开应用首页，左滑List列表，展示置顶和删除按钮，点击可分别实现列表项ListItem置顶和删除功能。
2. 往下滑动，出现回到顶部按钮，点击后可跳转至顶部。
3. 长按ListItem进行手势拖拽，可实现列表拖拽排序功能。
4. 点击ListItem进入聊天页面，默认显示底部消息，下拉可以加载更多聊天记录。
5. 点击输入框并输入消息，然后点击发送按钮，页面会实时展示最新的消息。

## 相关权限

不涉及。

## 约束与限制

* 本示例仅支持标准系统上运行，支持设备：华为手机。

* HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

* DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

* HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。
