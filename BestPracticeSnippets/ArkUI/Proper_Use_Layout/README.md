# **布局优化指导**
## 介绍
本例通过Scroll嵌套List，对比List设置宽度和不设置的情况。

## 工程目录
``` 
├──entry/src/main/ets                                   // 代码区
│  ├──entryability
│  │  └──EntryAbility.ets                               // 程序入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  ├──pages                              
│  │  └──Index.ets                                      // 首页
│  └──segment
│     ├──segment1.ets                                   // List列表数据
│     ├──segment2.ets                                   // List不设置宽高
│     └──segment3.ets                                   // List设置固定高度
└──entry/src/main/resources                             // 应用资源目录
```
## 使用说明
示例代码包含两个场景：
* Scroll嵌套List，List不设置宽高。
* Scroll嵌套List，List设置固定宽高。

## 相关权限
无

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
echo Proper_Use_Layout/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```