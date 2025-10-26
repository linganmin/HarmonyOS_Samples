# 编码规范

### 介绍

本示例是《NDK开发ArkTS侧编码规范》《使用DevEco Studio静态检测编码规范》最佳实践中的代码示例片段。

### 使用说明

进入首面，加载示例逻辑。


### 工程目录

``` 
├──DevEcoStaticCheck/src/main/ets                          
│  ├──devecostaticcheckability
│  │  └──DevEcoStaticCheckAbility.ets       // 入口类
│  └──pages       
│     ├──Index.ets                          // 示例页面
│     ├──Index2.ets                         // 示例页面                   
│     └──Index3.ets                         // 示例页面
└──entry/src/main/resources                 // 应用资源目录
```



### 具体实现

1. 主要介绍NDK开发ArkTS侧编码规范，提供代码示例。
2. 介绍使用DevEco Studio静态检测编码规范，提供代码示例。

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
echo StabilityCodingSpecification/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```