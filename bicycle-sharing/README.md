# 基于实况窗和扫码功能实现快捷触达的骑行场景

## 简介

本示例展示了使用实况窗、地图导航、统一扫码服务等技术实现共享单车的使用场景，用户在骑行过程中可以通过实况窗获取骑行状态，为整个骑行流程带来更好的体验。

## 效果展示
![预览图](screenshots/riding.gif)

## 使用说明
1.应用包含找车、扫码解锁、实况窗功能。<br>
2.通过解锁按钮开启实况窗<br>
3.通过还车按钮更新实况窗状态<br>
4.通过立即支付按钮结束流程

## 工程目录
```
├──ets
│  ├──constants
│  │  └──CyclingConstants.ets        //公共常量类
│  ├──entryability  
│  │  ├──EntryAbility.ets
│  │  └──LiveViewLockScreenExtAbility.ets  //沉浸态实况窗扩展ability         
│  ├──liveview  
│  │  ├──LiveNotification.ets       //实况窗通知类
│  │  ├──LiveViewContext.ets        //实况窗内容类
│  │  ├──LiveViewController.ets     //实况窗控制类
│  │  ├──LiveViewDataBuilder.ets    //实况窗数据构建类
│  │  ├──LiveViewEnvironment.ets    //实况窗环境类
│  │  ├──TextCapsuleBuilder.ets     //文本胶囊类
│  │  └──TextLayoutBuilder.ets      //文本扩展区类
│  ├──pages  
│  │  ├──ConfirmUnlock.ets          //解锁页面
│  │  ├──CyclingPage.ets            //首页
│  │  ├──FindBike.ets               //找车页面
│  │  ├──LiveViewLockScreenPage.ets //沉浸态实况窗页面
│  │  ├──Pay.ets                    //支付页面
│  │  ├──PayCompleted.ets           //支付完成页面
│  │  └──Riding.ets                 //骑行中页面
│  └──utils
│     ├──Logger.ets                 //日志工具类
│     ├──MapUtil.etx                //地图工具类
│     └──ScanUtil.ets               //扫码工具类
└──resources                        //应用静态资源目录
```
## 具体实现
1. 地图、定位与路线规划相关使用Map Kit能力实现。
2. 扫码使用Scan Kit能力实现
3. 实况窗使用Live View Kit能力实现

## 相关权限
[实况窗AGC参考配置流程](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/liveview-preparations)。<br>
[地图定位AGC参考配置流程](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/map-config-agc)。<br>
请在AGC上开通实况窗推送权限以及地图权限<br>
获取定位权限：ohos.permission.LOCATION
获取前台精确位置权限：ohos.permission.APPROXIMATELY_LOCATION<br>
获取后台运行时获取设备位置权限：ohos.permission.LOCATION_IN_BACKGROUND<br>
获取网络权限：ohos.permission.INTERNET<br>
获取数据网络信息权限：ohos.permission.GET_NETWORK_INFO<br>
获取相机权限：ohos.permission.CAMERA<br>

## 约束与限制
1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 5.0.0 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.0 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.0 Release SDK及以上。

