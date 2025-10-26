# 定制hvigor插件

### 介绍

在进行编译构建的过程中，开发者可以通过定制hvigor插件，扩展构建逻辑，实现个性化的打包流程。

### 使用说明

不涉及。

### 工程结构

```
├──entry/src/main/ets/
│  ├──entryability
│  │  └──EntryAbility.ets                    // 入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets              // 备份恢复类
│  └──pages
│     └──Index.ets                           // 示例页面
├──entry/src/main/resource                   // 应用资源目录
├──library/src/main/ets
│  └──components
│     └──MainPage.ets                        // library模块中MainPage
└──library/src/main/resource                 // lib资源目录
```

### 相关权限

不涉及。

### 约束与限制

* 本示例仅支持标准系统上运行，支持设备：华为手机。

* HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

* DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

* HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。

### 下载

如需单独下载本工程，执行如下命令：
```
git init
git config core.sparsecheckout true
echo customPlugin/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```
