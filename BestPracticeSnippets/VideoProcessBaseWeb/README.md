# 基于Web的视频处理

### 介绍

本示例基于Web组件，对具有视频内容的Web页面进行了适配，包括适配了视频的全屏播放、复制视频链接、将视频快捷地在浏览器打开观看、以及提供了视频下载的相关能力。

### 效果预览

手机运行效果图如下：

![image](screenshots/device/phone.gif)

**注意**：本示例中的视频地址仅供演示，且该视频地址有下载次数限制，开发者请按需使用自有视频地址替代。

### 工程目录结构

```
├──entry/src/main/ets                                   // 代码区
│  ├──common
│  |  └──Constants.ets                                  // 常量
│  ├──entryability
│  |  └──EntryAbility.ets
│  ├──entrybackupability
│  |  └──EntryBackupAbility.ets
│  ├──pages
│  |  └──Index.ets                                      // 入口界面
│  ├──utils
│  |  ├──CustomFunction.ets                             // 功能函数封装
│  |  └──WebDownloadManager.ets                         // Web下载功能封装
│  └──view
│     ├──CustomPopupMenu.ets                            // 自定义弹出菜单
│     └──DownloadControlView.ets                        // 下载过程UI视图
└──entry/src/main/resources                             // 应用资源目录
```

### 具体实现
* 全屏播放视频需要监听Web页面进入全屏的onFullScreenEnter()事件，在进入全屏后，将屏幕方向通过setPreferredOrientation()设置为横屏显示，在退出全屏的onFullScreenExit()回调中，将屏幕方向调转回竖屏显示，需要兼容返回手势退出全屏。
* 长按复制视频链接依靠Web组件的onContextMenuShow()方法，在该方法中可通过事件回调event参数，取得长按项目的相关属性，对于视频而言，其中的event.param.getSourceUrl()方法可获取到视频的链接地址，获取成功后通过pasteboard.getSystemPasteboard().setData()设置到剪贴板中。
* 浏览器打开实现上主要通过上述的event.param.getSourceUrl()来取得视频链接地址，然后通过拉起浏览器应用并传递视频链接地址实现在浏览器中播放视频。
* 长按下载视频在实现上，可通过上述的event.param.getSourceUrl()来取得视频链接地址，下载能力主要依靠WebDownloadDelegate委托类来监听下载过程与状态，通过Web组件关联的WebviewController来触发下载。下载完成将文件保存到公共目录。

### 相关权限

* ohos.permission.INTERNET：网络访问权限。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。
2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。

### 下载

如需单独下载本工程，执行如下命令：
```
git init
git config core.sparsecheckout true
echo VideoProcessBaseWeb/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```