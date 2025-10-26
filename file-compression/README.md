# 实现文件压缩与解压

### 介绍

本示例介绍通过使用@ohos.file.fs和@ohos/commons-compress三方库等接口，导入rawfile中文件，可以进行预览和压缩解压操作，开发者可以进行zip、gzip、tar、7z格式文件的操作。

### 效果图预览

![](screenshots/device/phone.gif)

### 使用说明

1. 点击预览预览文本内容，点击压缩选择压缩格式进行文件压缩。
2. 压缩后文件点击解压进行解压，解压后文件保存在在新目录/decompressedFile中，重复解压覆盖原有文件。
3. 点击从资源文件导入，导入rawfile中文件，可以进行预览和压缩解压操作。

### 目录结构

```
handletabs
│  ├──constant
│  │  └──FileConstants.ets
│  ├──entryability
│  │  └──EntryAbility.ets                        // 应用入口类
│  ├──model
│  │  └──FileItem.ets                            // 文件类
│  ├──pages
│  │  └──Index.ets                               // 首页
│  ├──utils
│  │  ├──CompressUtil.ets                        // 压缩工具类
│  │  ├──FileUtil.ets                            // 文件工具类
│  │  └──Logger.ets                              // 日志工具类
│  └──view
│     └──DialogView.ets                          // 弹窗视图
└────entry/src/main/resources 
```

### 相关权限
不涉及。

### 依赖
运行前需安装包common-compress，命令行执行"ohpm install @ohos/commons-compress"。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。