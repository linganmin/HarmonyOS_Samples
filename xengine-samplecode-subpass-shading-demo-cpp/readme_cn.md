# Subpass Shading的使用(VULKAN)

## 简介

本篇Codelab主要介绍如何使用Subpass Shading。示例代码通过XComponent组件调用NAPI创建Vulkan环境，实现绘制SPONZA场景，并展示Subpass Shading特性的使用。本篇CodeLab使用Native C++模板创建。

## 效果预览

如图所示，XComponent组件绘制SPONZA场景。

![Subpass_Shading_VULKAN_Example.jpg](screenshots/device/Subpass_Shading_VULKAN_Example.jpg)

## 相关概念

- [XComponent](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-basic-components-xcomponent)：可用于EGL/OpenGLES和媒体数据写入，并显示在XComponent组件。

## 使用说明

1. 运行示例代码。

## 工程目录
```
├── entry/src/main	             // 代码区
│  ├── cpp
│  │  ├── types
│  │  │  ├── libnativerender
             └── index.d.ts      // native层接口注册文件 
│  │  │── napi_init.cpp          // native api层接口的具体实现函数
│  │  │── CMakeLists.txt         // native层编译配置
│  │  │── 3rdParty               // 三方件
│  │  │── common                 // 通用接口  
│  │  │── file                   // 文件管理
│  │  │── libs                   // 三方动态库
│  │  │── manager                // native&arkts交互
│  │  │── render                 // 渲染
│  ├── ets
│  │  ├── entryability 
             └── EntryAbility.ts // 程序入口类
│  │  ├── pages 
             └── index.ets       // 主界面展示类
│  ├── resources                 // 资源文件目录
│  │  ├── base
│  │  │  ├── media
             └── icon.png        // 图片资源
│  │  ├── rawfile
│  │  │  ├── forward_plus        // forward plus shader文件
│  │  │  ├── sponza_full         // 模型文件
│  │  │  ├── subpass_shading     // subpass shading shader文件
```

## 具体实现
本示例展示的功能使用了Vulkan扩展接口[VK_HUAWEI_subpass_shading](https://registry.khronos.org/vulkan/specs/1.3-extensions/man/html/VK_HUAWEI_subpass_shading.html)提供的Subpass Shading API：
* VKAPI_ATTR VkResult VKAPI_CALL vkGetDeviceSubpassShadingMaxWorkgroupSizeHUAWEI(VkDevice device, VkRenderPass renderpass, VkExtent2D* pMaxWorkgroupSize);
* VKAPI_ATTR void VKAPI_CALL vkCmdSubpassShadingHUAWEI(VkCommandBuffer commandBuffer);
通过调用展示的API实现Subpass Shading特性。

## 相关权限

不涉及。

## 依赖

* 本示例依赖assimp三方件，请按系统版本编译对应版本三方件。
* 3D模型资源："[Crytek Sponza](https://casual-effects.com/data/)" by Frank Meinl, Crytek is licensed under [CC BY 3.0](https://creativecommons.org/licenses/by/3.0/)/replace "\\\" with "/" in file sponza.mtl

## 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：请参考XEngine开发指南的[硬件要求](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/xengine-kit-preparations)。
2. 本示例为Stage模型，支持API version 12及以上。
3. HarmonyOS系统：HarmonyOS NEXT Developer Beta1及以上。
4. DevEco Studio版本：DevEco Studio NEXT Developer Beta1及以上。
5. HarmonyOS SDK版本：HarmonyOS NEXT Developer  Beta1 SDK及以上。
