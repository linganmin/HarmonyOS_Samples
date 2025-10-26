# 基于List组件实现常见列表流场景

## 介绍
列表流是采用以“行”为单位进行内容排列的布局形式，每“行”列表项通过文本、图片等不同形式的组合，高效地显示结构化的信息。
列表流具有排版整齐、重点突出、对比方便、浏览速度快等特点。列表流主要使用List组件，按垂直方向线性排列子组件ListItemGroup或ListItem，混合渲染任意数量的图文视图，从而构建列表内容。

本示例包含以下四个常见的列表流场景：
* 多类型列表项场景
* Tab吸顶场景
* 分组吸顶场景
* 二级联动场景

## 预览效果
|  多类型列表项场景 | Tab吸顶场景  |
|---|---|
|  ![](screenshots/divice/homePage.gif) |  ![](screenshots/divice/managerPage.gif) |
| 分组吸顶场景  | 二级联动场景  |
| ![](screenshots/divice/cityList.gif)  |  ![](screenshots/divice/categoryPage.gif) |


## 工程目录
```
├──entry/src/main/ets                                   // 代码区
│  ├──entryability
│  │  └──EntryAbility.ets                               // 程序入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  ├──pages                              
│  │  ├──Index.ets                                      // 首页
│  │  ├──CategoryPage.ets                               // 二级联动场景页面
│  │  ├──CityList.ets                                   // 分组吸顶场景页面
│  │  ├──CustomListItem.ets                             // Tab吸顶场景列表内容
│  │  ├──HomePage.ets                                   // 多类型列表项场景页面
│  │  └──ManagerPage.ets                                // Tab吸顶场景页面
│  └──model 
│     └──LinkDataModel.ets                              // 二级联动场景数据
└──entry/src/main/resources                             // 应用资源目录
```

## 使用说明
示例代码包含四个场景：
* 多类型列表项场景：进入页面，下拉刷新模拟网络请求；向下滑动页面内容，景区分类标题吸顶；滑动到页面底部，上滑模拟请求添加列表数据。
* Tab吸顶场景：下滑页面内容，“关注”、“推荐”、“热搜”、“更多”实现吸顶效果。
* 分组吸顶场景：滑动左侧城市列表数据，城市列表标题实现吸顶效果，城市字母标题对应右侧字母导航列表内容高亮显示；点击右侧字母导航内容，左侧城市数据滑动到对应内容。
* 二级联动场景：点击左侧导航，右侧滑动到指定内容；滑动右侧内容，商品分类标题吸顶，左侧对应导航高亮显示。

## 相关权限
无

## 约束与显示
* 本示例仅支持标准系统上运行，支持设备：华为手机。
* HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
* DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
* HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。
