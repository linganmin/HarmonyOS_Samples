# 基于在线认证服务实现通行密钥功能（C++）

## 介绍

本示例展示了通行密钥服务提供的C++ API的使用方法，可实现基于FIDO2协议的通行密钥注册、本地免密认证和跨设备扫码认证能力。
1. 通行密钥注册：支持使用用户身份认证特征（如人脸、指纹、PIN码）作为平台认证器，在本设备上创建应用或网页的通行密钥。
2. 本地免密认证：支持使用用户身份认证特征（如人脸、指纹、PIN码）作为平台认证器，使用通行密钥在本设备上进行应用或网页的免密认证。
3. 跨设备扫码认证：支持使用已注册通行密钥的移动设备作为漫游认证器，使用跨设备扫码的方式，在其他设备上进行应用或网页的免密认证。

## 效果预览

| 应用主页                                                    | 接口使用按钮 |
|---------------------------------------------------------| -------------- |
| 应用主页显示在设备屏幕                                             | 点击接口测试按钮调用接口  |
| <img src="./image/homepage_cn.png" style="zoom:25%;" /> | <img src="./image/results.png" style="zoom:25%;" /> |

## 工程目录
```
├── entry/src/main/cpp
│    ├── hcts                                                // native C++调用FIDO2NDK代码
│    │    ├── include                                        // 头文件
│    │    │    ├── fido2_serializer.h                        // fido2报文与结构体互转头文件                  
│    │    │    ├── fido2_test.h                              // 函数导出头文件
│    │    │    └── log.h                                     // 日志打印的头文件
│    │    └── src 
│    │    │    ├── connect_service.cpp                       // 调用FIDO2NDK的实现
│    │    │    └── fido2_serializer.cpp                      // fido2报文与结构体互转的实现
│    ├── third_party                                         // nlohmann三方库
│    │    └── include/nlohmann                               // nlohmann三方库
│    ├── types/libentry/                                     // 
│    │    ├── Index.d.ts                                     // 声明C++方法
│    │    └── oh-package.json5                               // 声明依赖
│    ├── CMakeLists.txt                                      // 链接libfido2_ndk.z.so动态库
│    └── napi_init.cpp                                       // NAPI适配层
└── entry/src/main/ets
     ├── Pages                                               // 连接FIDO服务器，获取注册、认证、注销报文
     │    └── Index.ets                                      // 程序入口类
     └── server
          ├── Fido2NetUtil.ets                               // 连接服务器工具类
          ├── ServerAuthenticationExtensionsClientOutputs.ets // 用于构造注册参数的数据结构类
          ├── ServerAuthenticatorAssertionResponse.ets        // 用于构造认证响应参数的数据结构类
          ├── ServerAuthenticatorAttestationResponse.ets      // 用于构造注册参数的数据结构类
          ├── ServerPublicKeyCredentialCreation.ets           // 用于构造注册响应参数的数据结构类
          ├── ServerPublicKeyCredentialCreationOptions.ets    // 用于构造注册参数pkOptions的数据结构类
          ├── ServerPublicKeyCredentialDescriptor.ets         // 用于构造注册参数的数据结构类
          ├── ServerPublicKeyCredentialRequest.ets            // 用于构造认证请求参数的数据结构类
          ├── ServerPublicKeyCredentialRequestOptions.ets     // 用于构造认证请求参数的数据结构类
          └── ServerPublicKeyCredentialUserEntity.ets         // 用于构造注册参数pkOptions数据结构类
```

## 使用说明

1. 运行前需修改并指定服务器地址(entry/src/main/ets/server/Fido2NetUtil.ets)；
2. 在主界面，每次使用通行密钥功能之前，需要首先点击【获取能力列表】查看客户端当前是否支持该功能；
3. 点击【获取平台认证器能力】查看支持的平台身份验证器列表；
4. 点击【注册】进行注册，页面弹出弹窗提示注册成功；
5. 注册后，点击【认证】进行认证，页面弹出弹窗提示认证成功；


## 具体实现（接口参考@hms.security.fido2）
业务使用时，需要先进行导入如下通行密钥API:
* FIDO2_ErrorCode HMS_FIDO2_getClientCapability()(FIDO2_CapabilityArray ** capability);
* FIDO2_ErrorCode HMS_FIDO2_getPlatformAuthenticator()(FIDO2_AuthenticatorMetadataArray **authenticators);
* FIDO2_ErrorCode HMS_FIDO2_register()(const FIDO2_CredentialCreationOptions options，const FIDO2_TokenBinding tokenBinding，const char * origin，FIDO2_PublicKeyAttestationCredential ** publicKeyAttestationCredential );
* FIDO2_ErrorCode HMS_FIDO2_authenticate()(const FIDO2_CredentialRequestOptions options，const FIDO2_TokenBinding tokenBinding，const char *origin，FIDO2_PublicKeyAssertionCredential **publicKeyAssertionCredential);

具体用例请参考Index.ets。


## 相关权限

1. 获取通行密钥服务权限：ohos.permission.ACCESS_FIDO2_ONLINEAUTH。

## 依赖

不涉及

## 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机、平板、2in1；
2. 本示例需要使用DevEco Studio 6.0.0 Release才可编译运行；
3. HarmonyOS系统：HarmonyOS 6.0.0 Release及以上；
4. HarmonyOS SDK版本：HarmonyOS 6.0.0 Release SDK及以上；
5. 若使用人脸认证功能，设备须支持3D人脸；
6. 开发者的业务需要接入符合FIDO2标准的协议，并部署符合FIDO2标准协议的FIDO服务端，通行密钥服务接口仅提供FIDO2客户端能力，无法独立进行开启/认证服务；Fido2NetUtil.ets提供连云服务模板，如需连云请通过修改服务器url地址接入云端服务器。
