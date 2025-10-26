# 实现发布图片评论功能

### 简介

本示例通过拉起系统相机实现发布图片评论，便于用户了解系统相机接口的调用方式。

### 效果预览
<img src="screenshots/ImageComment.png" width="300px">

使用说明：

1.启动后点击文本框，再点击相机按钮，拉起系统相机。

2.拍照后返回，点击发布按钮。

### 工程目录
```
├──entry/src/main/ets
│  ├──commmon
│  │  └──CommonConstants.ets       // 常量类                             
│  ├──entryability  
│  │  └──EntryAbility.ets          // 程序入口
│  ├──model
│  │  ├──CommentModel.ets          // 评论类
│  │  └──MockCommentData.ets       // 评论数据
│  ├──pages                                     
│  │  └──Index.ets                 // 首页
│  ├──utils                                 
│  │  └──CameraUtils.ets           // 拉起相机
│  └──view
│     ├──CommentInputDialog.ets    // 发布评论弹窗
│     ├──CommentItemView.ets       // 评论组件
│     └──ImageListView.ets         // 评论图片列表
└──entry/src/main/resources        // 应用资源目录
```

### 相关权限

不涉及

### 约束与限制

1.本示例仅支持标准系统上运行，支持设备：华为手机。

2.HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3.DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4.HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。
