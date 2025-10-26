# 同层渲染原生组件

### 介绍

在使用Web组件加载H5页面时，经常会有输入框、视频的场景，这些场景在H5中的组件性能体验欠佳。想要更加流畅的体验，必须要将原生组件放到Web组件上。
本工程配套官网[同层渲染原生组件](https://developer.huawei.com/consumer/cn/doc/best-practices/bpta-render-web-using-same-layer-render)，
文章介绍如何在Web组件上使用原生组件同层渲染。

### 使用说明

1. 当前sample为非同层渲染模块，同层渲染模块请查看[arkweb-same-level-rendering](https://gitee.com/harmonyos_samples/arkweb-same-level-rendering)。
2. 分别运行2个sample，抓取Trace图进行[Frame分析](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-insight-session-frame)对比帧耗时。

### 工程目录

``` 
├──entry/src/main/ets                          
│  ├──entryability
│  │  └──EntryAbility.ets               // 程序入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets         // 自定义应用数据转换和迁移模板类
│  ├──mock                              
│  │  └──GoodsMock.ets                  // 构造页面脏数据
│  ├──model
│  │  └──GoodsModel.ets                 // 商品数据结构
│  └──pages        
│     └──Index.ets                      // 应用首页同层渲染
└──entry/src/main/resources             // 应用资源目录
```

### 相关权限

不涉及

### 约束与限制

* 本示例仅支持标准系统上运行，支持设备：华为手机。
* HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
* DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
* HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。

## 下载

如需单独下载本工程，执行如下命令：
```
git init
git config core.sparsecheckout true
echo NonSameLayerRendering/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```