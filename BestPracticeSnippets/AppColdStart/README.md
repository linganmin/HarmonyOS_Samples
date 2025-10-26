# 应用冷启动时延优化同源示例代码

### 介绍

本示例代码为最佳实践《应用冷启动时延优化》配套示例代码。

### 使用说明

不涉及

### 工程目录

``` 
├──entry/src/main/ets                      
│  ├──entryability
│  │  └──EntryAbility.ets                   // 程序入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets             // 数据备份恢复类
│  ├──pages         
│  │  ├──ColdStartSlow.ets                  // 冷启动缓慢示例
│  │  ├──ColdStartSpeedOptimization.ets     // 冷启快速示例
│  │  ├──ComputeTaskAsync.ets               // 异步任务示例
│  │  ├──ImportMainPage.ets                 // 页面导入示例
│  │  ├──ImportMainPageDemo.ets             // 减少导入文件示例
│  │  ├──ImportSubPage.ets                  // 导入次级页面
│  │  ├──Index.ets                          // 应用首页
│  │  ├──NewIndex.ets                       // 展示网路图片首页
│  │  ├──NotRecommendDemo.ets               // 不推荐iport示例
│  │  ├──ReduceImport.ets                   // 减少import导入示例
│  │  ├──ScenariosExample.ets               // 网络二次刷新示例
│  │  └──SecondPage.ets                     // 跳转页面
│  └──utils
│     ├──Calculator.ets                     // 耗时运算函数封装
│     └──NetRequest.ets                     // 网络请求工具类
├──entry/src/main/resources                 // 应用资源目录
└──library                                  // 静态资源共享包 
   ├──src/main/ets/components/mainpage   
   │  ├──MainPgge.ets                       // 静态资源包首页                          
   │  └──SubPage.ets                        // 静态资源包次级页面     
   ├──Index.ets                             // 入口文件，对外暴露模块方法
   ├──IndexAppStart.ets                     // 拆分导出文件MainPage 
   ├──IndexOthers.ets                       // 拆分导出文件SubPage 
   └──src/main/resources                    // 应用静态资源目录
```

### 相关权限

不涉及

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
echo AppColdStart/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```