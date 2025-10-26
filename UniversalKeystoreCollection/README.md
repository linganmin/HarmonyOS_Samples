# 基于@ohos.security.huks模块的密钥库功能实现

### 介绍

本示例主要通过使用@ohos.security.huks (通用密钥库系统)模块，完成加解密、签名验签、密钥协商等基础的通用密钥库操作。

### 效果展示
![](screenshots/Devices/UniversalKeystoreCollection.gif)

### 使用说明

1. 在主界面点击加解密、签名验签、密钥协商可以跳转至对应功能页面。
2. 点击加解密按钮后，可以选择加密算法，点击跳转后，可以根据不同的加解密算法进行加解密，可以在待加密文本处输入内容，并点击加密按钮进行加密并弹窗提
醒，并将加密内容显示在已加密文本处，点击解密会进行解密，弹窗提醒并将结果显示在已解密文本处。
3. 点击签名验签按钮后，可以根据不同算法进行签名验签，点击签名按钮会进行签名并弹窗提醒签名结果，点击验签会弹窗提醒用户，验签通过，在未完成签名，
进行验签，会提示签名为空，无法通过验签。
4. 点击密钥协商按钮，会根据不同算法进行密钥协商，分别点击生成非对称密钥A、B按钮生成密钥，在A、B密钥均存在时，点击密钥协商按钮，会提示协商通过，
否则会弹窗提示，密钥缺失，协商失败。

### 工程目录
```
├──entry/src/main/ets                             // 代码区
│  ├──common
│  │  ├──constants                                
│  │  │  ├──CommonConstants.ets                   // 常量类
│  │  │  └──HuksPropertiesConstants.ets           // 加解密常量类
│  │  └──utils
│  │     ├──EncodingUtils.ets                     // 编码工具类
│  │     ├──EncryptAndDecryptUtils.ets            // 加解密工具类
│  │     ├──KeyNegotiationUtils.ets               // 密钥协商工具类
│  │     ├──Logger.ets                            // 日志打印工具类
│  │     └──SignatureVerificationUtils.ets        // 签名验签工具类
│  ├──entryability
│  │  └──EntryAbility.ets                         // 程序入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  ├──pages
│  │  ├──EncryptionDetailPage.ets                 // 加解密详情页
│  │  ├──EncryptionPage.ets                       // 加解密方案选择页
│  │  ├──Index.ets                                // 首页
│  │  ├──KeyNegotiationDetailPage.ets             // 密钥协商详情页
│  │  ├──KeyNegotiationPage.ets                   // 密钥协商方案选择页
│  │  ├──SignatureVerificationDetailPage.ets      // 签名验签详情页
│  │  └──SignatureVerificationPage.ets            // 签名验签方案选择页
│  └──viewmodel
│     └──RouterParam.ets                          // 路由信息
└──entry/src/main/resources                       // 应用静态资源目录
```

### 相关权限

不涉及。

### 依赖

不涉及。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。
2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。
