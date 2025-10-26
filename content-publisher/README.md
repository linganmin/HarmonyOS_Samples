# 实现富文本编辑器功能

## 项目简介

本示例基于ArkUI的基本能力和RichEditor组件，实现一个富文本编辑器应用。功能包括：支持用户从图库中选取图片添加到页面；正文输入框支持添加话题、联系人、图文标题、自定义表情信息；页面支持添加添加当前位置信息。

## 效果预览

![](screenshots/device/home.png)

## 使用说明

1. 点击“添加优质首图”，选择好图片后，图片显示在横向列表中。
2. 点击“正文”输入框，可以输入相应的信息。
3. 点击页面下方![](entry/src/main/resources/base/media/ic_symbol2.svg)按钮，下方显示“图文标题”列表，选择相应的“图文标题”后，“图文标题”会在正文中显示。
4. 点击页面下方“@”按钮，页面进入联系人页面，选择需要@的联系人，返回发帖页面，在正文输入框会显示选中联系人的昵称。
5. 点击页面下方“#”按钮，页面弹出话题列表内容,选择对应的话题，弹框关闭，在正文输入框会显示选中的话题。
6. 点击页面下方表情按钮，切换到表情面板，点击表情，在正文输入框会显示选中的表情。
7. 点击左下“添加位置”，“添加位置”下方区域会多出一行附近位置信息，选中后，“添加位置”会变成选中的位置信息。

## 工程目录

```
├──entry/src/main/ets                         // 代码区
│  ├──constants
│  │  └──CommonConstants.ets                  // 公共常量
│  ├──entryability
│  │  └──EntryAbility.ets       
│  ├──models
│  │  └──CommonModel.ets                      // 公共实体类       
│  ├──pages
│  │  ├──ContactListPage.ets                  // 联系人页面
│  │  └──Home.ets                             // 主页面       
│  ├──utils
│  │  ├──CommonUtil.ets                       // 通用工具类
│  │  ├──FileUtil.ets                         // 选择图片工具类
│  │  ├──LocationUtil.ets                     // 本地位置工具类
│  │  ├──PermissionManager.ets                // 权限管理类
│  │  └──Logger.ets                           // 日志文件
│  └──view
│     ├──ContactListView.ets                  // 联系人模块
│     ├──PictureListView.ets                  // 图片列表模块
│     ├──ToolbarView.ets                      // 底部工具模块
│     ├──EditorView.ets                       // 编辑输入模块
│     ├──GraphicTitleView.ets                 // 图文标题模块
│     ├──TopView.ets                          // 顶部区域模块
│     └──TopicView.ets                        // 话题内容模块
└──entry/src/main/resources                   // 应用资源目录
```

## 具体实现
使用RichEditor组件实现。

## 相关权限

- 申请获取设备位置信息权限:ohos.permission.APPROXIMATELY_LOCATION和ohos.permission.LOCATION

## 依赖

不涉及

## 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机、平板。

2. HarmonyOS系统：HarmonyOS 5.1.1 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.1.1 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.1.1 Release SDK及以上。