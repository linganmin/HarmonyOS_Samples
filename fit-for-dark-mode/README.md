# 实现深色模式功能

### 简介
本示例采用深色模式适配相关技术，确保应用在系统深浅色模式切换时界面效果美观自然，实现颜色资源适配、媒体资源适配、状态栏适配等。应用内还提供用户可控的深浅色模式开关，满足用户个性化需求，实现应用在不同模式下的深浅色切换。

### 效果预览：
![](./screenshots/phone.gif)

### 工程目录

```
├──entry/src/main/ets/
│  ├──entryability
│  │  └──EntryAbility.ets               // 程序入口
│  ├──pages   
│  │  ├──DarkModeSetting.ets            // 深色模式设置页面
│  │  ├──Home.ets                       // 主页
│  │  ├──Index.ets                      // 程序页面入口
│  │  └──Mine.ets                       // 我的页面
│  ├──view                  
│  │  ├──FinishedTodoItem.ets           // 已完成的Todo组件    
│  │  └──TodoItem.ets                   // Todo组件
│  └──viewmodel                  
│     ├──ColorModeChangeFunctions.ets   // 深浅模式切换功能函数封装
│     ├──Todo.ets                       // Todo类
│     └──TodoViewModel.ets              // Todo数据
└──entry/src/main/resources             // 应用静态资源目录
```
使用说明：
- 默认应用跟随系统深浅色进行切换，在设置->显示与亮度->深色模式->全天开启中进行打开关闭，应用会跟随进行深浅色显示。
- 应用内提供关闭跟随系统切换功能，在我的->深色模式中关闭跟随系统设置，应用将始终保持浅色模式。
- 应用内提供手动控制深浅色开关，在我的->深色模式中打开/关闭深色模式，应用会跟随设置的值选择深色/浅色显示。

### 具体实现

1. 颜色资源适配例如文本颜色，组件背景颜色等。有以下两种方案：
   1. 使用系统预留的颜色资源值。
   2. 开发者进行手动适配。需要开发者创建src/main/resources/dark/element目录，并在目录下创建color.json文件，在文件中设置页面元素在深色模式下的颜色值，并在src/main/resources/base/element/color.json文件中设置浅色模式下的页面元素颜色值。
2. 图片与图标资源适配。若需要应用在深色模式与浅色模式下呈现不同的图片/图标，需要开发者创建出src/main/resources/dark/media目录，用于放置应用在深色模式下的图片与图标资源，并在src/main/resources/base/media放入同名但不同的静态资源。
3. 系统状态栏适配。默认情况下若应用未启用沉浸式，则不会存在状态栏适配问题，若应用设置了沉浸式，可能会导致页面的背景色与状态栏文字颜色对比度过低，对用户而言状态栏文字不可见，影响用户体验，此种情况下，可以考虑监听系统深浅色模式变化动态地通过setWindowSystemBarProperties来设置状态栏文字颜色。

### 相关权限

不涉及

### 约束与限制

1.本示例仅支持标准系统上运行，支持设备：华为手机。

2.HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3.DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4.HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。