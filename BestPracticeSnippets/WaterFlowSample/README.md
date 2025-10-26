# 常见瀑布流操作

### 简介

本示例基于WaterFlow组件的特性，整理了瀑布流常见操作的示例代码。

### 工程目录
```
├─entry/src/main/ets                         
│  ├─common/constants
│  │  └─CommonConstants.ets                  // 常量类
│  ├─entryability
│  │  └─EntryAbility.ets                     // 入口文件
│  ├─entrybackupability
│  │  └─EntryBackupAbility.ets               // backup
│  ├─model
│  │  ├─BasicDataSource.ets                  // 基类DataSource
│  │  ├─MediaItem.ets                        // 媒体实体类
│  │  ├─MyDataSource.ets                     // 我的DataSource
│  │  ├─SectionsWaterFlowDataSource.ets      // 分组DataSource
│  │  └─StickyWaterFlowDataSource.ets        // 吸顶DataSource
│  ├─pages
│  │  ├─CustomItemHeightPage.ets             // 自定义分组和高度页面
│  │  ├─DataLoadMorePage.ets                 // 加载更多页面
│  │  ├─DataUpadteAndAnimationPage.ets       // 下拉刷新页面
│  │  ├─ElementByOrderPage.ets               // 元素分类页面
│  │  ├─FadingEdgePage.ets                   // 边缘渐隐页面
│  │  ├─FlowItemAutoPlayPage.ets             // 停止自动播放页面
│  │  ├─FlowItemRmoveAnimationPage.ets       // 移除item带动画页面
│  │  ├─FlowItemRmovePage.ets                // 移除item页面
│  │  ├─ForceShowOnTopLeftPage.ets           // 强制左上角显示页面
│  │  ├─Index.ets                            // 主页
│  │  ├─MergeDoubleWaterFlowPage.ets         // 合并两个瀑布流页面
│  │  ├─SectionOptionsUsePage.ets            // 分组功能页面
│  │  ├─StickOnTopPage.ets                   // 吸顶功能页面
│  │  └─ZoomChangeColumnPage.ets             // 缩放改变列数页面
│  └─utils
│     └─WindowUtil.ets                       // 窗口工具类
└─entry/src/main/resources                   // 应用资源目录
```
### 原理

不涉及

### 使用说明

不涉及

### 相关权限

不涉及

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
echo WaterFlowSample/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```