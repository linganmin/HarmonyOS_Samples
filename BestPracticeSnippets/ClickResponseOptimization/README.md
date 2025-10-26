# 点击响应时延分析

### 介绍

本示例是《点击响应时延分析》最佳实践中的代码示例片段。

### 使用说明

进入首面，加载示例逻辑。


### 工程目录

``` 
├──entry/src/main/ets                          
│  ├──common/constants
│  │  ├──AppConstant.ets                    // app常量
│  │  ├──ChatConstants.ets                  // chat常量
│  │  ├──WorldCommonConstants.ets           // 公共常量
│  │  └──WorldConstants.ets                 // 公共常量
│  ├──common/db
│  │  ├──AccountData.ets                    // account数据
│  │  ├──AccountTable.ets                   // account表
│  │  └──Rdb.ets                            // rdb工具类
│  ├──entryability
│  │  └──EntryAbility.ets                   // 入口类
│  ├──model                              
│  │  └──ChatModel.ets                      // chat数据模型
│  ├──pages
│  │  ├──CameraOptPage.ets                  // 示例页面
│  │  ├──CameraPage.ets                     // 示例页面
│  │  ├──CityListPage.ets                   // 示例页面
│  │  ├──ConcurrentOptPage.ets              // 示例页面
│  │  ├──Index.ets                          // 首页
│  │  ├──PanGestureDistanceOptPage.ets      // 示例页面
│  │  ├──PanGestureDistancePage.ets         // 示例页面
│  │  ├──ProfilePage.ets                    // 示例页面
│  │  └──VisionOptPage.ets                  // 示例页面
│  └──view        
│     ├──ArticleSkeletonView.ets            // 骨架屏view
│     ├──LoadingView.ets                    // 加载view                    
│     └──OptChatItemView.ets                // 优化后的chat view
└──entry/src/main/resources                 // 应用资源目录
```


### 具体实现

1. 针对点击响应时延分析经，介绍这方面的常见性能优化方法。

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
echo ClickResponseOptimization/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```