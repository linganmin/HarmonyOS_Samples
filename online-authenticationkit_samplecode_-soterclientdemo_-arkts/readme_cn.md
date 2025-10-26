# SOTER免密身份认证

## 介绍

本示例展示了SOTER免密身份认证接口的使用方法，通过从 @kit.OnlineAuthenticationKit 导入SOTER API接口，从@kit.UserAuthenticationKit导入userAuth。在设备处于联网状态下，可实现基于SOTER 协议提供的端侧生成密钥，开通，认证和关闭功能。


## 效果预览

| 应用入口 | 应用主页| 接口使用按钮 |
| --------------- | --------------- | -------------- |
| 点击图标打开应用 | 应用主页显示在设备屏幕   | 点击接口测试按钮调用接口  |
| <img src=".\image\startIcon.png" style="zoom:50%;" /> | <img src=".\image\homepage_cn.jpeg" style="zoom:25%;" /> | <img src=".\image\results_cn.jpeg" style="zoom:25%;" /> |

## 工程目录

```
├──entry/src/main/ets                      // 代码区
│   ├──entryability
│   │   └──EntryAbility.ets                // 程序入口类
│   ├──model
│   │   └──SoterModel.ets                  // 生成密钥、签名、删除密钥功能 
│   └──pages
│       └──Index.ets                       // 主页面入口
└──entry/src/main/resources                // 应用资源目录
```



## 使用说明

1. 使用指纹/3D人脸进行免密身份认证，移动端设备需要录入对应的生物特征信息。
2. 在设备录入指纹/3D人脸后，点击生成AppSecureKey按钮，提示生成应用密钥成功。
3. 点击生成AuthKey按钮，提示生成AuthKey成功。
4. 点击认证按钮，可使用生物特征（人脸/指纹）进行SOTER免密身份认证。
5. 点击关闭按钮，关闭SOTER生物特征（人脸/指纹）免密身份认证.


## 具体实现
以SOTER认证功能为例，业务使用时，需要先进行import导入如下SOTER API:

import { soter } from '@kit.OnlineAuthenticationKit'
* function getChallenge(keyAlias: string): Uint8Array;
* function auth(keyAlias: string, authToken: Uint8Array, info: string): soter.SignedResult;

业务使用时，首先需要在设备中存入指纹或3D人脸；首先通过调用getChallenge()接口获取本次验证临时challenge参数，该数值需与生物认证所用challenge保持一致，SOTER服务会进行校验；通过使用UserAuthenticationKit提供的生物特征认证能力，使用auth()接口对业务数据进行认证签名，认证成功返回签名报文，失败会抛出异常。

具体用例请参考Index.ets


## 相关权限

1. 获取网络权限：ohos.permission.INTERNET。
2. 获取振动权限：ohos.permission.VIBRATE。
3. 获取生物识别权限：ohos.permission.ACCESS_BIOMETRIC。

## 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机、平板、2in1。
2. HarmonyOS系统：HarmonyOS NEXT Beta1及以上。
3. DevEco Studio版本：DevEco Studio NEXT Beta1及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.1.0 Release SDK及以上。