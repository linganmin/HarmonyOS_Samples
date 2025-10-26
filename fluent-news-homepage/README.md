# 体验流畅的首页信息流

### 介绍
本场景解决方案主要面向于新闻类页面开发人员，指导开发者从零开始构建一个新闻类的首页面，包含地址选择、tabs和tabContent切换的动态图标和流畅动效、下拉刷新上拉加载、首页feed流等常见功能，及功能的流畅体验。

### 效果预览

<img src='screenshots/device/NewsDemo.gif' width='320'>

使用说明

1. 获取地理位置的权限；
2. 点击位置信息，跳转地址页，可修改当前位置信息；
3. 点击顶部页签或者滑动切换页面，页签同步切换；
4. 点击底部页签切换页面，同步切换页签，触发页签切换的动画效果；
5. 下拉刷新页面信息；
6. 上拉加载页面信息；
7. 点击右下角按钮回弹至顶部。


### 工程目录
```
├──entry/src/main/ets/
│  ├──common
│  │  └──lottie                    // 动画
│  ├──constants
│  │  ├──BreakpointConstants.ets   // 断点常量
│  │  ├──CommonConstants.ets       // 常用常量
│  │  └──HomeConstants.ets         // 主页常量
│  ├──entryability
│  │  └──EntryAbility.ets          // Ability的生命周期回调内容
│  ├──pages
│  │  ├──CitySearch.ets            // 城市查询
│  │  └──Index.ets                 // 首页
│  ├──util                  
│  │  ├──BreakpointType.ets        // 断点类型
│  │  └──ResourceUtil.ets          // 路由数据
│  ├──view                  
│  │  ├──CityView.ets              // 城市列表组件
│  │  ├──Home.ets                  // 主页组件
│  │  ├──HomeContent.ets           // tab内容组件
│  │  ├──HomeHeader.ets            // 主页头部组件
│  │  ├──NewsChannel.ets           // 新闻渠道组件
│  │  ├──PullToRefreshNews.ets     // 拉取刷新新闻组件
│  │  ├──SearchView.ets            // 搜索组件
│  │  └──TabBar.ets                // 标签栏组件
│  └──viewmodel                  
│     ├──CityDetailData.ets        // 城市详细数据
│     ├──NewsData.ets              // 新闻数据
│     ├──NewsDataSource.ets        // 新闻数据源
│     ├──NewsTypeModel.ets         // 新闻类型模型
│     └──NewsViewModel.ets         // 新闻视图模型
└──entry/src/main/resources        // 应用静态资源目录
```

### 依赖
本方案使用了三方库lottie和pulltorefresh，如出现缺少依赖的情况可通过命令下载<br>
ohpm install @ohos/pulltorefresh<br>
ohpm install @ohos/lottie<br>


### 相关权限

获取定位权限：ohos.permission.APPROXIMATELY_LOCATION和ohos.permission.LOCATION。

### 约束与限制

1.本示例仅支持标准系统上运行，支持设备：华为手机。

2.HarmonyOS系统：HarmonyOS 5.1.0 Release及以上。

3.DevEco Studio版本：DevEco Studio 5.1.0 Release及以上。

4.HarmonyOS SDK版本：HarmonyOS 5.1.0 Release SDK及以上。
