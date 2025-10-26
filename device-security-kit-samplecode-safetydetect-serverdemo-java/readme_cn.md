# SafetyDetect SysIntegrity Server Sample

[English](readme_en.md) | 中文

## 目录

 * [介绍](#介绍)
 * [运行步骤](#运行步骤)
 * [支持环境](#支持环境)
 * [示例代码](#示例代码)
 * [许可证](#许可证)


## 介绍
SafetyDetect SysIntegrity Server Sample 提供了在服务端验证结果的示例代码。
## 运行步骤
在运行SafetyDetect SysIntegrity Server Sample之前，请检查是否安装Java以及Maven。
1.使用maven工具构建工程。
2.运行main程序。
3.输入系统完整性检测结果，即：JWS字符串。
4.输入root G2 证书文件路径。
5.如果验证成功，则输出payload内容，否则输出错误信息。

## 支持环境
Java 1.7 及以上

## 示例代码

1. 解析JWS，获取header，payload，signature。
2. 从header中获取证书链，使用[HUAWEI CBG root G2](https://h5hosting-drcn.dbankcdn.cn/cch5/crl/pki_CA_RootG2Ca/RootG2Ca.cer)证书对其进行验证。
3. 校验证书链中是否包含3级证书；校验证书链中x5c[0]证书的域名是否为sysintegrity.platform.hicloud.com。
4. 从signature中获取签名，校验其签名。
5. 从payload中获取完整性验证结果，格式和样例摘录如下：
```json
{
  "hapCertificateSha256": "xxx",
  "hapBundleName": "xxx",
  "appId": "xxx",
  "basicIntegrity": false,
  "detail": [
    "attack",
    "jailbreak",
    "emulator"
  ],
  "nonce": "xxx",
  "timestamp": 1604098577327
}
```
更多信息请访问[系统完整性检测](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/devicesecurity-sysintegrity-check)
##  许可证
此代码已获得 [Apache License, version 2.0](http://www.apache.org/licenses/LICENSE-2.0).

