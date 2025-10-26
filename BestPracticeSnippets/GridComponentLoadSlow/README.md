# Grid组件加载丢帧优化同源示例代码

### 介绍

本示例代码为最佳实践《Grid组件加载丢帧优化》配套示例代码。

#### 使用说明

安装应用进入首页，点击按钮滑动列表。

## 工程目录

``` 
├──entry/src/main/ets                      
│  ├──entryability
│  │  └──EntryAbility.ets               // 程序入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets         // 数据备份恢复类
│  └──pages        
│     ├──Index.ets                      // 使用columnStart/columnEnd设置GridItem大小示例：反例
│     └──RightIndex.ets                 // 使用GridLayoutOptions设置GridItem大小：正例
└──entry/src/main/resources             // 应用资源目录
```

### 相关权限

不涉及

## 约束与限制

* 本示例仅支持标准系统上运行，支持设备：华为手机。
* HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
* DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
* HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。

### 下载

如需单独下载本工程，执行如下命令：
```
git init
git config core.sparsecheckout true
echo GridComponentLoadSlow/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```