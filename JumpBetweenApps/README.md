# 基于AppLinking实现应用间跳转

## 介绍

本示例基于AppLinking拉端能力，实现了应用间跳转相关功能，包括拉起设置应用，指定应用拉起，指定意图拉起，拉起应用完成后带参返回等，为应用间跳转场景提供了统一可信的拉端体验。

## 效果预览
手机运行效果图如下：

![image](screenshots/device/phone.gif)

## 工程的目录结构

```  
├──entry/src/main/ets                         // 代码区  
│  ├──pages  
│  │  └──Index.ets                            // 首页  
│  ├──entryability  
│  │  └──EntryAbility.ets                     
│  ├──entrybackupability  
│  │  └──EntryBackupAbility.ets               
│  ├──view  
│  │  ├──CommunicationArea.ets                // 对话区域  
│  │  ├──FooterBar.ets                        // 底部功能区  
│  │  ├──HeaderBar.ets                        // 头部信息区  
│  │  ├──MessageItem.ets                      // 单条消息  
│  │  └──WarningBox.ets                       // 警告  
│  └──viewmodel  
│     └──MessageViewModel.ets                 // 信息数据  
└──entry/src/main/resources                   // 应用资源目录  
```  

## 具体实现

指定应用拉起使用openLink()接口，配置拉起的应用App Linking链接进行应用的拉起。

拉起指定类型应用使用startAbilityByType接口，配置要拉起的应用的参数，系统将会弹窗提示用户选择要在哪个应用中继续操作，用户选择后，在具体应用中继续操作。

注：
1. 开发者需自行在`src/main/ets/viewmodel/MessageViewModel.ets`第67行代码修改自行配置的App Linking链接。
2. 拉起自开发的应用需要开发者自行在dependence/AppLinkingTestDemo应用内进行App Linking相关配置，包括申请App Linking链接、申请证书与Profile签名等。

## 相关权限

不涉及

## 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。
2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。