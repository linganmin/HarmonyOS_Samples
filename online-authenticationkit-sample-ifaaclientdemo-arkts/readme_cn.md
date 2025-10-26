# IFAA

## 介绍

本示例展示了IFAA免密身份认证接口的使用方法，IIFAA协议具体功能请参考[IIFAA本地免密技术规范](https://www.iifaa.org.cn/technical#paper)

通过从 @kit.OnlineAuthenticationKit 导入IFAA API接口，可实现基于IIFAA协议提供的端侧免密开通，认证和注销功能。


## 效果预览

| 应用入口 | 应用主页| 接口使用按钮 |
| --------------- | --------------- | -------------- |
| 点击图标打开应用 | 应用主页显示在设备屏幕   | 点击接口测试按钮调用接口  |
| <img src=".\image\startIcon.png" style="zoom:50%;" /> | <img src=".\image\homepage_cn.jpeg" style="zoom:25%;" /> | <img src=".\image\results_cn.jpeg" style="zoom:25%;" /> |

## 工程目录

```
├── entry/src/main/ets               // 代码区
│    ├── entryability
│    │    └── EntryAbility.ets       // 程序入口类
│    ├── model
│    │    └── IfaaModel.ets          // 开通、认证、关闭功能实现
│    └── pages
│         └── Index.ets              // 主页面入口
│    └── util
│         └── Util.ets               // 工具类
```



## 使用说明

1. 使用指纹/3D人脸进行免密身份认证，移动端设备需要录入对应的生物特征信息。
2. 在设备录入指纹/3D人脸后，点击开启按钮，页面弹出弹窗进行认证，提示开启成功。
3. 点击认证按钮，可使用生物特征（人脸/指纹）进行IFAA免密身份认证。
4. 点击关闭按钮，关闭IFAA生物特征（人脸/指纹）免密身份认证。


## 具体实现
以IFAA认证功能为例，业务使用时，需要先进行import导入如下IFAA API:

import { ifaa } from '@kit.OnlineAuthenticationKit'
* function preAuthSync(): Uint8Array;
* function auth(authToken: Uint8Array, authData: Uint8Array):Promise&lt;Uint8Array&gt;

业务使用时，首先需要在设备中存入指纹或3D人脸；首先通过调用preAuth()接口获取本次验证临时challenge参数，该数值需与生物认证所用challenge保持一致，IFAA服务会进行时效校验，获取参数后长时间未使用会导致验证失败；
通过调用User Authentication Kit成功获取指纹/人脸信息后，使用auth()接口进行身份认证，认证成功返回签名报文，失败会抛出异常。
具体用例请参考Index.ets


## 相关权限

1. 获取生物识别权限：ohos.permission.ACCESS_BIOMETRIC。

## 依赖

UserAuthenticationKit

## 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机、平板、2in1；
2. 本示例需要使用DevEco Studio NEXT Developer Beta1才可编译运行；
3. HarmonyOS系统：HarmonyOS NEXT Beta1及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.1.0 Release SDK及以上。
5. 样例代码需要使用IIFAA中心服务器签名的报文才能取得正确的结果。