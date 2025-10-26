# 列表编辑效果

### 介绍

本示例基于List组件，实现待办事项管理、文件管理、备忘录的等场景列表编辑效果。

### 效果预览

![](./screenshots/device/listitem_edit.gif)

##### 使用说明

- 点击添加按钮，选择需要添加的待办事项。
- 点击左侧checkbox按钮，待办事项状态变更为已完成。
- 左滑单个待办事项，点击删除按钮后，当前待办事项被删除。

### 工程目录

```

├──entry/src/main/ets/
│  ├──common
│  │  └──Constants.ets               // 公共常量类
│  ├──entryability
│  │  └──EntryAbility.ets            // 程序入口类
│  ├──model
│  │  └──ToDo.ets                    // 待办事项数据
│  ├──pages
│  │  └──Index.ets                   // 首页
│  └──view
│     └──TodoListItem.ets            // 待办选项
└──entry/src/main/resources          // 应用静态资源目录
```

### 具体实现

1. List组件绑定@State修饰的数组变量toDoData。

2. ListItem组件设置左滑动效swipeAction属性，使得单个ListItem可以进行左右滑动，并显示自定义的UIBuilder。

3. 新增/删除列表项，更新数组变量toDoData，并同时更新List组件UI。

### 相关权限

不涉及

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。
