# 实现PixelMap图片裁剪和深拷贝功能

### 介绍

本示例主要展示了通过图片获取到PixelMap格式数据，然后根据该原始PixelMap初始化出一个深拷贝的目标PixelMap，然后调用crop方法对图片进行裁剪。通过该示例开发者可以学习图片处理相关接口的使用以及图片裁剪的方法。

### 效果图预览

![](screenshots/device/ImageDepthCopy.gif) 

**使用说明**

1. 进入页面，显示的即为rawfile中图片的PixelMap经过深拷贝过后的PixelMap对象。
2. 点击底部的按钮，对原始PixelMap进行深拷贝后再根据相应的比例进行裁剪。
3. 点击顶部的保存图标，可以保存当前图片。

### 实现思路
1. PixelMap深拷贝方法。通过readPixelsToBuffer读取图片资源的PixelMap到ArrayBuffer，再通过createPixelMap得到目标PixelMap。
2. 初始化时，通过深拷贝从原始PixelMap创建目标PixelMap。
3. 调用crop方法对图片进行裁剪。
4. 通过FileIO接口方法保存图片到具体路径。

### 高性能知识点

**不涉及**

### 工程结构&模块类型
```
├──entry/src/main/ets                         // ets 代码区
│  ├──constants
│  │  └──CommonConstants.ets                  // 常量定义文件  
│  ├──entryability
│  │  └──EntryAbility.ets       
│  ├──util
│  │  ├──CopyObj.ets                          // 业务层-图片深拷贝处理
│  │  └──FileUtil.ets                         // 业务层-图片保存
│  ├──model
│  │  └──AdjustData.ets                       // 裁剪选项资源
│  └──pages
│     └──Index.ets                            // 主页界面
└──entry/src/main/resources                   // 应用资源目录
```

### 模块依赖

**不涉及**

### 参考资料

1. 位图操作。
2. packing。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。
2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。