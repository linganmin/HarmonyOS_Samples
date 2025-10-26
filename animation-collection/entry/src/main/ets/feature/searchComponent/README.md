# 搜索功能实现案例

### 介绍

本示例介绍使用includes方法对数据实现模糊查询

### 效果预览

![](../../../../../../screenshots/device/search.gif)

**使用说明**

1. 点击首页搜索框跳转到搜索页面
2. 在搜索页面输入框中输入搜索的内容，下方列表自动根据搜索的内容进行筛选渲染
3. 点击筛选后的列表跳转到相应的页面
4. 跳转后会保存搜索历史，搜索历史使用持久化存储处理退出应用再次进入依旧存在
5. 点击搜索历史可以跳转到相应页面

### 具体实现

1. 通过include方法判读是否存在符合条件的数据。
2. 通过PersistentStorage进行持久化数据存储。

### 相关权限

不涉及

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。