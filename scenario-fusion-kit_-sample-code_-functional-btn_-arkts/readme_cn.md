# 基于融合场景服务构建场景化组件

## 介绍

本示例展示了使用华为融合场景服务提供的场景化组件，主要用于获取快速验证手机号Button、地图选点Button、选择头像Button、打开APP Button、选择收货地址Button、选择发票抬头Button、权限设置Button和省市区选择器Input的能力。

使用时需要引用场景化组件接口'@kit.ScenarioFusionKit'。

## 效果预览

| 主页                                         | 快速验证手机号                                                |      地图选点                                             |
|--------------------------------------------|--------------------------------------------------------|-----------------------------------------------------------------|
| <img src=screenshots/main.jpg width="250"> | <img src=screenshots/get_phone_number.jpg width="250"> | <img src=screenshots/choose_location.jpg width="250"> |

| 选择头像                               | 选择发票抬头                             | 打开APP                                          |
|------------------------------------------------|-----------------------------------|------------------------------------------------|
| <img src=screenshots/choose_avatar.jpg width="250"> | <img src=screenshots/choose_invoice_title.jpg width="250"> | <img src=screenshots/open_app.jpg width="250"> |

| 选择收货地址                                        | 权限设置                                        | 省市区选择器Input                                          |
|------------------------------------------------------|-----------------------------------------------------|------------------------------------------------------|
| <img src=screenshots/choose_address.jpg width="250"> | <img src=screenshots/PermissionSetting.jpg width="250"> | <img src=screenshots/selector_input.jpg width="250"> |

使用说明

1. 在主界面可以点击快速验证手机号、地图选点、选择头像、打开APP、选择收货地址、选择发票抬头、权限设置和省市区选择器Input按钮验证对应场景的功能。
2. 可以通过设置styleOption中的属性值来配置按钮的基本样式。
3. 可以通过设置styleOption中styleConfig来设置更多按钮的样式。

## 示例工程的配置与使用

### 在DevEco中配置Codelab工程的步骤如下

1. [创建项目](https://developer.huawei.com/consumer/cn/doc/app/agc-help-create-project-0000002242804048)及[应用](https://developer.huawei.com/consumer/cn/doc/app/agc-help-create-app-0000002247955506)。
2. 详细可参见开发指南-[开发准备](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/scenario-fusion-preparations)和[场景化Button](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/scenario-fusion-button)、[场景化Input](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/scenario-fusion-input)的前提条件。

## 工程目录
```
entry
  └─src                     
    ├─main                
    │  ├─ets              
    │  │  ├─entryability          // 程序入口类
    │  │    ├──EntryAbility.ets   // 本地启动ability
    │  │  └─pages
    │  │    ├──Index.ets                     // 基础预览界面
    │  └─resources        
    │      ├─base         
    │      │  ├─element       // 颜色、字体、字符串等资源
    │      │  ├─media         // 图片等资源  
    │      │  └─profile       // 页面配置
```

## 具体实现

快速验证手机号、地图选点、选择头像、打开APP、选择收货地址、选择发票抬头、权限设置按钮功能的场景化组件封装在\entry\src\main\ets\pages， 这些按钮为对应场景的FunctionalButton组件，按钮在点击时会调用FunctionalButton组件中对应的功能。
省市区选择器Input按钮功能的场景化组件封装在\entry\src\main\ets\pages， 按钮为对应场景的FunctionalInput组件，按钮在点击时会调用FunctionalInput组件中对应的功能。

## 相关权限

参考开发指南-[开发准备](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/scenario-fusion-preparations)和[场景化Button](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/scenario-fusion-button)、[场景化Input](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/scenario-fusion-input)的前提条件。

## 依赖

无

## 约束与限制

1. 本示例仅支持标准系统上运行，支持设备:Phone、Tablet和2in1（部分组件支持TV设备，详情见[开发指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/scenario-fusion-guide)每个组件的约束和限制）。
2. HarmonyOS系统: HarmonyOS 5.0.0 Release及以上。
3. DevEco Studio版本: DevEco Studio 5.0.0 Release及以上。
4. HarmonyOS SDK版本: HarmonyOS 5.0.0 Release SDK及以上。