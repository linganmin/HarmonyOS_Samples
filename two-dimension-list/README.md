# 实现两个Scroll组件嵌套滑动的效果

### 介绍

本示例通过两个Scroll嵌套，实现可左右和上下滑动的效果，多用于商品类、新闻类页面。帮助开发者掌握多个Scroll嵌套时，解决滑动冲突处理。

### 效果预览
![running](screenshots/device/list.gif)


### 工程目录
```
├──entry/src/main/ets                         // 代码区
│  ├──common
│  │  └──CommonConstants.ets                  // 常量类 
│  ├──entryability
│  │  └──EntryAbility.ets 
│  ├──model
│  │  ├──ListDataSource.ets                  
│  │  ├──MessageList.ets                      // 列表数据
│  │  └──TitleList.ets                        // 表头数据
│  └──pages
│     └──Index.ets                            // 首页
└──entry/src/main/resources                   // 应用资源目录
```
### 具体实现
+ 本示例通过定义多个自定义组件，封装到Scroll组件中，通过懒加载的方式加载列表数据的方式实现上下左右滑动效果。

### 相关权限

不涉及。

### 依赖

不涉及。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。