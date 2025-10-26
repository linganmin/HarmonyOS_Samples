# 基于融合场景服务实现智能推荐数据填充

## 介绍

本示例展示了使用智能填充服务提供场景化的输入建议，实现复杂表单一键填充，帮助用户轻松地完成表单填写。

使用时需要引用程序框架服务接口@kit.AbilityKit

## 效果预览


| **主页**                                     | **剪贴板推荐**                                       | **华为账号推荐**                                    |
|--------------------------------------------|-------------------------------------------------|-----------------------------------------------|
| <img src=screenshots/main.jpg width="250"> | <img src=screenshots/clipboard.jpg width="250"> | <img src=screenshots/account.jpg width="250"> |

| **历史表单输入保存**                                       | **历史表单输入更新**                                         | **历史表单输入推荐**                                       |
|----------------------------------------------------|------------------------------------------------------|----------------------------------------------------|
| <img src=screenshots/history_save.jpg width="250"> | <img src=screenshots/history_update.jpg width="250"> | <img src=screenshots/history_form.jpg width="250"> |

## 前提条件

1. 设备智能填充开关必须处于打开状态。请前往“设置”->“隐私和安全”->“智能填充”打开智能填充功能。
2. 应用/元服务的输入组件的[ContentType](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/scenario-fusion-intelligentfilling-appendix)属性配置对应场景，即可触发智能填充功能。 
3. 智能填充服务开放能力接入需要申请与审批，详见[申请接入](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/scenario-fusion-introduction-to-smart-fill#section1167564853816)。 
4. 填充数据来源请参考[推荐数据源及推荐逻辑说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/scenario-fusion-intelligentfilling-explain)。

## 工程目录
```
entry
  └─src                     
    ├─main                
    │  ├─ets              
    │  │  ├─entryability         // 程序入口类
    │  │    ├──EntryAbility.ets   // 本地启动ability
    │  │  └─pages
    │  │    ├──Index.ets         // 入口界面
    │  │    ├──Demo.ets          // 演示示例
    │  │    ├──ShipToAddress.ets // 收货地址示例
    │  │    └──PurchaseTicket.ets// 购票示例
    │  └─resources        
    │      ├─base         
    │      │  ├─element          // 颜色、字体、字符串等资源
    │      │  ├─media            // 图片等资源  
    │      │  └─profile          // 页面配置
```  

## 具体实现

智能填充功能演示在\entry\src\main\ets\pages\Index.ets， 这些输入组件已设置contentType属性，点击对应输入组件触发智能填充功能。

## 相关权限

无

## 依赖

参考[开发指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/scenario-fusion-introduction-to-smart-fill)。

## 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：Phone、Tablet和2in1。
2. 本示例为Stage模型。
3. 本示例需要使用DevEco Studio 5.0.0 Release版本运行。


