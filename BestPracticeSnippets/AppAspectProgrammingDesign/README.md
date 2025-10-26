# 应用切面编程设计

### 介绍

本示例是《应用切面编程设计》最佳实践中的代码示例片段。

### 使用说明

进入首面，加载示例逻辑。

### 工程目录

``` 
├──entry/src/main/ets                          
│  ├──entryability
│  │  └──EntryAbility.ets               // 入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets         // 备份恢复类
│  └──pages        
│     ├──Index.ets                      // 示例页面
│     ├──Index1.ets                     // 示例页面                  
│     ├──Index2.ets                     // 示例页面   
│     ├──Index3.ets                     // 示例页面
│     ├──Index4.ets                     // 示例页面           
│     ├──Index5.ets                     // 示例页面
│     ├──Index6.ets                     // 示例页面
│     ├──Index7.ets                     // 示例页面              
│     ├──Index8.ets                     // 示例页面
│     ├──Index9.ets                     // 示例页面
│     └──Index10.ets                    // 示例页面
└──entry/src/main/resources             // 应用资源目录
```


### 具体实现

1. 介绍使用util.Aspect在切面编程中的方法操作，包括使用addBefore、addAfter、replace等。

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
echo AppAspectProgrammingDesign/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```