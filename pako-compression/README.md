# 基于pako三方库的文件压缩与解压

### 介绍

本示例通过使用pako三方库能力，实现了对字符串的压缩与解压能力，即将字符串保存至文件中并压缩，以及解压获取到原字符串，给开发者提供一个简单的字符串压缩解压示例。

## 下载安装

```
  ohpm install pako
  ohpm install @types/pako --save-dev  // import pako 的时候语法报错。其原因是pako包内不含类型声明，需要 @types/pako 下载这个包的声明文件，从而解决语法的报错。
```

### 效果预览
![image](screenshots/device/StreamCompression.gif)

使用说明

1、在输入框内输入内容并点击压缩字符串并保存按钮，会拉取文件管理页面并压缩字符串、创建压缩文件。

2、点击解压文件并读取按钮，会拉取文件管理页面，选择压缩文件后，会解压并返回字符串显示在界面中。


### 工程目录
```
├──entry/src/main/ets/
│  ├──common
│  │  ├──constants
│  │  │  └──CommonConstants.ets             // 常量类
│  │  └──utils
│  │     ├──CommonUtils.ets                 // 常用工具类
│  │     ├──CompressionUtils.ets            // 压缩解压工具类
│  │     └──Logger.ets                      // 日志打印类
│  ├──entryability
│  │  └──EntryAbility.ets                   // 程序入口类
│  └──pages
│     └──Index.ets                          // 主页面
└──entry/src/main/resources                 // 应用静态资源目录
```
### 具体实现

* 本示例主要实现了压缩与解压的功能，实现主要参考三方js库[pako](https://github.com/nodeca/pako)，pako提供gzip和deflate等格式压缩解压码功能。

### 相关权限

不涉及。

### 依赖

不涉及。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。
2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。