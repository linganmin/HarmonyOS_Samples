# 应用安全示例代码

## 介绍

本示例是应用安全编码实践、应用资产保护设计、应用代码混淆、网络连接安全配置四篇最佳实践中的代码示例片段。

## 使用说明

本示例为最佳实践示例代码，开发者可以查阅官网最佳实践下应用安全编码实践、应用资产保护设计、应用代码混淆、网络连接安全配置四篇最佳实践学习。

## 工程目录
```
├── privacy
│   ├── src/main/ets
│   │   ├── pages
│   │   │   ├── app_json.md                             // 页面配置说明
│   │   │   ├── ApplicationAssetProtectionAfter.ets     // 应用资产保护后
│   │   │   ├── ApplicationAssetProtectionBefore.ets    // 应用资产保护前
│   │   │   ├── CheckWantOne.ets                        // Want校验场景一
│   │   │   ├── CheckWantTwo.ets                        // Want校验场景二
│   │   │   ├── CodeConfusion.cpp                       // 代码混淆实现
│   │   │   ├── Cybersecurity.cpp                       // 网络安全检测
│   │   │   ├── GeolocationAccess.ets                   // 地理位置权限
│   │   │   ├── Index.ets                               // 主页入口
│   │   │   ├── NetworkTrust.ets                        // 网络信任管理
│   │   │   ├── NoInfoJumpTo.ets                        // 无信息跳转
│   │   │   ├── OnSslErrorEventReceive.ets              // SSL错误事件处理
│   │   │   ├── PrivacyMode.ets                         // 隐私模式切换
│   │   │   ├── PublicSafeInfo.ets                      // 公共安全信息
│   │   │   ├── PublicSensitive.ets                     // 公共敏感信息
│   │   │   ├── RunJavaScript.ets                       // JS执行风险
│   │   │   ├── RunJavaScriptTrustList.ets              // 可信列表JS执行
│   │   │   ├── SignInfo.cpp                            // 签名信息验证
│   │   │   ├── TrustListCheck.ets                      // 信任列表校验
│   │   │   ├── UrlListCheck.ets                        // URL白名单检查
│   │   │   └── WebUrlSafe.ets                          // 安全URL加载
│   │   ├── privacyability
│   │   │   └── PrivacyAbility.ets                      // 程序入口类
│   │   └── privacybackupability
│   │       └── PrivacyBackupAbility.ets                // 备份能力
│   └── resources                                       // 资源目录内容不展开
└── PrivacyError
    ├── src/main/ets
    │   ├── pages
    │   │   ├── app_json.md                             // 页面配置说明
    │   │   ├── GeolocationAccess.ets                   // 地理位置权限访问
    │   │   ├── Index.ets                               // 主页入口
    │   │   ├── JavaScriptProxy.ets                     // JS代理风险示例
    │   │   ├── MixedMode.ets                           // 混合模式加载网页
    │   │   ├── NoInfoJumpTo.ets                        // 无敏感信息跳转
    │   │   ├── OnSslErrorEventReceive.ets              // SSL错误事件处理
    │   │   ├── PublicSafeInfo.ets                      // 公共安全信息展示
    │   │   ├── PublicSensitive.ets                     // 公共敏感信息风险
    │   │   ├── RunJavaScriptTrustList.ets              // 可信列表JS执行
    │   │   └── UntrustedDataToSQL.ets                  // 不可信数据注入SQL
    │   └── privacyerrorability
    │       └── PrivacyErrorAbility.ets                 // 程序入口类
    └── resources                                       // 资源目录内容不展开
```

## 相关权限

不涉及。

## 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。

## 下载

如需单独下载本工程，执行如下命令：
```
git init
git config core.sparsecheckout true
echo Privacy/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```