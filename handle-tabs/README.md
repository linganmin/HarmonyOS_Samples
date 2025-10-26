# 基于Tab组件实现增删Tab的功能

### 介绍

本示例通过修改Tab组件的barHeight高度，隐藏组件自带的TabBar，自定义一个可以增删Tab页签的场景，该场景多用于浏览器等场景。帮助开发者掌握Tab组件的相关接口属性，灵活的实现自己业务需要用到的Tab场景。

### 效果图预览

![](./screenshots/phone.gif)

### 使用说明

1. 点击新增按钮，新增Tab页面。
2. 点击删除按钮，删除Tab页面。

### 目录结构

```
handletabs
│  ├──entryability
│  │  └──EntryAbility.ets
│  ├──model
│  │  └──ConstantsData.ets                       // 数据类
│  └──pages
│     ├──Index.ets                               // 增删tab页签功能实现页面
│     ├──MenuBar.ets                             // 工具栏
│     └──TabSheetComponent.ets                   // 自定义TabBar组件
└────entry/src/main/resources 
```

## 实现思路

1. 设置Tab组件的barHeight为0，隐藏组件自带的TabBar。
2. 使用@Link修饰符，将自定义TabBar组件和Tab组件通过focusIndex和tabArray进行双向绑定。
3. 在自定义TabBar中修改focusIndex和tabArray的值时，Tab组件根据数据变化进行对应UI变更。

### 相关权限
不涉及。

### 依赖
不涉及。

### 约束与限制

1.本示例仅支持标准系统上运行，支持设备：华为手机。

2.HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3.DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4.HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。