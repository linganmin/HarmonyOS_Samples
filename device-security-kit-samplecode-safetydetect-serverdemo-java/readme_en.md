# SafetyDetect SysIntegrity Server Sample

English| [中文](readme_cn.md)

## Contents

 * [Introduction](#Introduction)
 * [Procedure](#Procedure)
 * [Environment Requirements](#Environment-Requirements)
 * [Sample Code](#Sample-Code)
 * [License](#License)


## Introduction
SafetyDetect SysIntegrity Server Sample provides sample code for verifying results on the server.
## Procedure
Before running the SafetyDetect SysIntegrity Server Sample, verify that Java and Maven have been installed.

1. Use Maven to build a project.
2. Run the main program.
3. Enter the system integrity check result, which is a JWS string.
4. Enter the root G2 certificate file path.
5. If the verification is successful, output  the payload content. Otherwise, output an error message.

## Environment Requirements
Java 1.7 or later

## Sample Code

1. Parse the JWS string to obtain **header**, **payload**, and **signature**.
2. Obtain the certificate chain from **header** and use the [HUAWEI CBG root G2](https://h5hosting-drcn.dbankcdn.cn/cch5/crl/pki_CA_RootG2Ca/RootG2Ca.cer) certificate to verify it.
3. Verify that the certificate chain contains three levels of certificates and the domain name of the **x5c[0]** certificate is **sysintegrity.platform.hicloud.com**.
4. Obtain the signature from **signature** and verify it.
5. Obtain the integrity verification result from **payload**. The format and example are as follows:
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
For more information, please visit [System Integrity Check](https://developer.huawei.com/consumer/en/doc/harmonyos-guides/devicesecurity-sysintegrity-check)

##  License
The sample code is licensed under [Apache License, version 2.0](http://www.apache.org/licenses/LICENSE-2.0).
