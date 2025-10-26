# StyledStringNDK

## 介绍

本示例为使用NDK接口构建UI->使用文本->[Text组件的文本绘制与显示](https://gitee.com/openharmony/docs/blob/master/zh-cn/application-dev/ui/ndk-styled-string.md)的配套示例工程。 

本示例展示了如何创建文本以及设置文本样式。

## 效果预览

| 预览                                      | 
| -------------------------------------------- | 
<img src="./screenshots/text_styled_string.png" width="300" />

## 使用说明
1. 安装编译生成的hap包，并打开应用；
2. 查看创建好的文本以及相应的文本样式；


## 工程目录

```
StyledStringNDK
entry/src/main/ets/
└── pages
    └── Index.ets (获取文本界面)
entry/src/main/
├── cpp
│   ├── types
│   │   └── libentry
│   │       └── Index.d.ts (NDK函数对应的js映射)
│   ├── CMakeLists.txt (CMake脚本)
|   ├── manager.cpp (创建文本实现CPP文件)
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
echo ArkUIKit/StyledStringNDK > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/guide-snippets.git
git pull origin master
```