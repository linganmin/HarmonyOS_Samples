# 基于enableDataDetector属性实现文本特殊文字识别的功能

### 介绍

本示例通过Text组件的enableDataDetector属性，实现文本特殊文字识别，比如输入电话号码、链接、邮箱和地址的文本，文本自动变蓝并增加下划线。帮助开发者掌握文本的特殊识别能力。

### 效果图预览

![](./screenshots/device/word.gif)

##### 使用说明

进入页面，输入带有特殊文字的信息并发送，对话列表中文本会自动识别并标识特殊文字。目前支持识别的类型包括电话号码、链接、邮箱和地址，其中地址需要具体地址信息才会被识别，被识别的文字会变成蓝色并增加下划线。

### 工程目录

```
├──entry/src/main/ets/
│  ├──common
│  │  └──CommonConstants.ets         // 公共常量类
│  ├──entryability
│  │  └──EntryAbility.ets            // 程序入口类
│  ├──pages                  
│  │  └──Index.ets                   // 首页
│  └──viewmodel
│     ├──BasicDataSource.ets         // 数据源
│     └──MessageModel.ets            // 信息数据模型
└──entry/src/main/resources          // 应用静态资源目录
```

### 具体实现

1. 使用Text组件的enableDataDetector属性实现文本特定文字识别。

2. 使用Text组件的dataDetectorConfig属性设置允许识别的类型。

### 相关权限

不涉及。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。