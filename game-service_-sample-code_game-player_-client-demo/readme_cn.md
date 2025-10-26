# Game Service Kit（ArKTS）

## 简介
本示例集成了Game Service Kit，实现了一个简单的游戏登录和账号切换功能，供您参考使用。

## 效果预览
![](./image/result_cn.png)

## 工程目录
```
├─entry/src/main/ets                // 代码区  
│  ├─common                          // API接口实现  
│  │  └─GameApi.ets  
│  ├─entryability  
│  │  └─EntryAbility.ets              // 程序入口类  
│  ├─entrybackupability  
│  │  └─EntryBackupAbility.ets  
│  └─pages                           // 存放页面文件目录  
│      └─Index.ets                     // 主页面，游戏登录场景、游戏号切换场景实现  
└─entry/src/main/resources          //应用资源目录  
```

## 使用说明
1. 使用DevEco Studio打开工程目录。
2. 替换AppScope中app.json5文件中的bundleName。
3. 在build-profile.json5的signingConfigs中配置签名信息，并在AppGallery Connect中配置签名证书指纹。
4. 替换entry/src/main/module.json5文件中的client_id和app_id。
5. 在HarmonyOS设备上运行示例代码。

## 相关权限
该Sample应用在调用游戏初始化、联合登录等接口需要访问网络，已在module.json5文件中添加网络权限"ohos.permission.INTERNET"。

## 约束与限制
1. 本示例仅支持标准系统上运行，支持设备：华为手机、平板、2in1、TV。
2. HarmonyOS系统：HarmonyOS NEXT Developer Beta1及以上。
3. DevEco Studio版本：DevEco Studio NEXT Developer Beta1及以上。
4. HarmonyOS SDK版本：HarmonyOS NEXT Developer Beta1 SDK及以上。