# 应用数据安全

### 简介
本示例实现了获取文件路径以及通用密钥库加解密算法。

### 效果图
| 首页                                                 |
|----------------------------------------------------|
| <img src="screenshots/device/phone.png" width=320> |

### 使用说明
1. 点击获取通用文件路径获取el2文件路径。
2. 点击获取EL1文件路径获取el1文件路径。
3. 点击加密会执行加密算法，可通过日志查看加密结果。
4. 点击解密对加密的数据进行解密，可通过日志查看解密结果。

### 工程目录
```
├──entry/src/main/ets/
│  ├──entryability
│  │  └──EntryAbility.ets          // 程序入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets    // 程序入口类
│  └──pages
│     └──Index.ets                 // 首页
└──entry/src/main/resources        // 应用静态资源目录
```

### 相关权限

不涉及

### 依赖

不涉及。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。

### 下载

如需单独下载本工程，执行如下命令：
```
git init
git config core.sparsecheckout true
echo AppDataSecurity/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```