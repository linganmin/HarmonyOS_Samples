# TextAreaEventNDK

## 介绍

本示例为使用NDK接口构建UI->使用文本->[监听输入框事件](https://gitee.com/openharmony/docs/blob/master/zh-cn/application-dev/ui/ndk-textarea-event.md)的配套示例工程。 

本示例展示了输入框输入、选中以及选中菜单。

## 效果预览

| 预览                                      | 
| -------------------------------------------- | 
<img src="./screenshots/textarea_getstringevent.gif" width="300" />

## 使用说明
1. 安装编译生成的hap包，并打开应用；
2. 在输入框内输入一段文字；
3. 长按文字进行选中；


## 工程目录

```
TextAreaEventNDK
entry/src/main/ets/
└── pages
    └── Index.ets (获取输入框界面)
entry/src/main/
├── cpp
│   ├── types
│   │   └── libentry
│   │       └── Index.d.ts (NDK函数对应的js映射)
│   ├── CMakeLists.txt (CMake脚本)
|   ├── manager.cpp (创建输入框实现CPP文件)
|   ├── manager.h
│   └── napi_init.cpp (NDK函数)
└── resources
    ├── base
    │   ├── element
    │   │   ├── color.json
    │   │   ├── float.json
    │   │   └── string.json
    │   └── media
```

## 相关权限

不涉及

## 依赖

不涉及

## 约束和限制

1. 本示例支持仅标准系统上运行，支持设备：华为手机、华为平板。

2. HarmonyOS系统：HarmonyOS 6.0.0 Beta3版本及以上。
   
3. DevEco Studio版本：DevEco Studio 6.0.0 Beta3版本及以上。

4. HarmonyOS SDK版本：HarmonyOS 6.0.0 Beta3 SDK版本及以上。

## 下载

如需单独下载本工程，执行如下命令：

```
git init
git config core.sparsecheckout true
echo ArkUIKit/TextAreaEventNDK > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/guide-snippets.git
git pull origin master
```