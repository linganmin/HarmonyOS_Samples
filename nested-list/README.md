# 实现List组件嵌套滑动的效果

### 介绍

本示例通过List组件的scrollToIndex接口，实现两个List组件（ListA、ListB）嵌套时，ListA滑动到某一位置，ListB跟随滑动至业务期望的位置。帮助开发者掌握两个List嵌套滑动时的场景如何处理。

### 效果预览

|                   主页                   |
|:--------------------------------------:|
| ![home](screenshots/devices/phone.gif) |

使用说明

1.运行后滑动页面。

### 工程目录

```
├──entry/src/main/ets/
│  ├──constants                         
│  │  └──CommonConstants.ets            // 常量类
│  ├──entryability
│  │  └──EntryAbility.ets               // 入口类
│  ├──pages
│  │  └──Index.ets                      // 主页
│  ├──view
│  │  └──CardItemComponent.ets          // 自定义子组件
│  └──viewmodel
│     ├──CardItem.ets                   // 卡片实体类
│     ├──ClassifyModel.ets              // 列表实体类
│     └──ClassifyViewModel.ets          // 数据类
└──entry/src/main/resources             // 应用静态资源目录

```

### 具体实现

通过List接口scrollToIndex方法实现一个List滑动时另一个List跟随滑动到相应的位置。

### 相关权限

不涉及。

### 依赖

不涉及。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。
