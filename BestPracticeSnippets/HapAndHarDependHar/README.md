# 模块化设计

### 介绍

本示例是《模块化设计》最佳实践中的代码示例片段。

### 使用说明

进入首面，加载示例逻辑。

### 工程目录
```
├──entry/src/main/ets
│  ├──entryability
│  │  └──EntryAbility.ets                   // Ability入口类
│  └──pages
│     └──Index.ets                          // 首页
├──har_common/src/main/ets
│  ├──components
│  │  └──MainPage.ets                       // common模块中MainPage
│  └──utils
│     └──Utils.ets                          // 工具类
└──har_library/src/main/ets
   └──components/mainpage
      └──MainPage.ets                       // library模块中MainPage
```


### 具体实现

1. 分别包括三个模块：主业务模块entry，公共模块har_common，库模块har_library

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
echo HapAndHarDependHar/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```