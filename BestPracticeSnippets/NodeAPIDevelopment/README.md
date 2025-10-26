# Node-API开发规范

### 介绍

本示例是《Node-API开发规范》最佳实践中的代码示例片段。

### 使用说明

进入首面，加载示例逻辑。


### 工程目录

``` 
├──entry/src/main/ets                          
│  ├──entryability
│  │  └──EntryAbility.ets                   // 入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets             // 数据备份类
│  ├──pages
│  │  ├──Index.ets                          // 示首页
│  │  └──Test.ets                           // 示例页面
│  └──view        
│     └──Worker.ets                         // worker示例
└──entry/src/main/resources                 // 应用资源目录
```

### 具体实现

1. 主要介绍Node-API开发规范，提供代码示例。

### 相关权限

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
echo NodeAPIDevelopment/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```