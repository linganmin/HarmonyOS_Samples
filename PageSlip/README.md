# 流畅滑动页面
## 简介
本示例展示了如何在构建复杂的瀑布流滑动页面时，优化加载慢和丢帧问题。本示例是一个ArkTs的应用程序，基于应用高频使用场景，构建复杂的流畅滑动页面，使用
懒加载、缓存列表项、组件复用等性能优化方式，达到滑动不丢帧的效果。                                                                                                                                                                                                                                            
## 效果预览
![](./screenshots/device/page_slip.gif)
## 工程目录
```
├──ets
│  ├──constants
│  │  ├──BreakpointConstants.ets       // 断点相关常量
│  │  ├──CommonConstants.ets           // 一般常量
│  │  └──HomeConstants.ets             // 主页的常量
│  ├──entryability
│  │  └──EntryAbility.ets
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  ├──model
│  │  ├──FooterTabData.ets             // 底部导航栏
│  │  ├──FunctionEntryData.ets         // 功能区
│  │  ├──FunctionEntryListData.ets     // 功能区数据列表
│  │  ├──WaterFlowData.ets             // 瀑布流数据
│  │  ├──WaterFlowDescriptionData.ets  // 瀑布流item底部描述信息
│  │  ├──WaterFlowHeadData.ets         // 瀑布流item媒体信息
│  │  └──WaterFlowListData.ets         // 瀑布流数据列表
│  ├──pages
│  │  └──Index.ets                     // 滑动页面入口
│  ├──utils
│  │  ├──BreakpointSystem.ets          // 一多断点监听
│  │  ├──BreakpointType.ets            // 一多断点类型
│  │  ├──CollectionsCountModifier.ts   // 按需更新数据
│  │  ├──Logger.ts                     // 日志
│  │  └──NetworkUtil.ets               // 网络请求
│  └──view
│     ├──FunctionView.ets              // 功能区页面
│     ├──HomeContent.ets               // 主页
│     ├──IndexNavDestination.ets       // 导航栏入口
│     ├──NavigationBarView.ets         // 导航栏页面
│     ├──SearchBarView.ets             // 搜索栏页面
│     ├──WaterFlowDescriptionView.ets  // 瀑布流item底部描述页面
│     ├──WaterFlowImageView.ets        // 瀑布流item图片描述页面
│     ├──WaterFlowLivingView.ets       // 瀑布流item直播描述页面
│     ├──WaterFlowVideoView.ets        // 瀑布流item视频描述页面
│     └──WaterFlowView.ets             // 瀑布流页面
└──resources                            // 资源类
```
## 具体实现
1. 瀑布流使用懒加载+缓存列表项的方式实现，避免了使用list作为数据源时一次性加载并渲染大量数据造成的性能瓶颈，也避免了滑动过快可能会造成的白块现象。
2. 瀑布流里面的卡片都实现了组件复用，避免大量相同结构的组件频繁创建与销毁带来的性能损耗。
3. 通过固定宽高比实现卡片在占位时就计算出卡片的高度，避免在组件渲染以后出现二次测量卡片高度，造成卡片跳动的情况。
## 使用说明
1. 功能区可以左右滑动。
2. 瀑布流可以下拉刷新，即将触底时分页加载数据，滑动时不丢帧。
## 相关权限
1. 获取网络请求权限：ohos.permission.INTERNET。
2. 获取网络链接状态权限：ohos.permission.GET_NETWORK_INFO。
## 约束与限制
1. 本示例仅支持标准系统上运行，支持设备：华为手机。
2. HarmonyOS系统：HarmonyOS 5.0.0 Release及以上。
3. DevEco Studio版本：DevEco Studio 5.0.0 Release及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.0.0 Release SDK及以上。