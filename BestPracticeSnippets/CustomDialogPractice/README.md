# **应用自定义弹窗开发实践**
## 介绍
弹窗是应用开发需要实现的基础功能，通常用来展示用户当前需要或用户必须关注的信息或操作，可用于广告、中奖、警告、软件更新等与用户交互响应的操作。
在应用开发中，经常需要实现自定义UI和功能要求，系统弹窗往往无法满足需求，此时就需要使用到自定义弹窗了。

合理选择不同的系统能力实现弹窗，有利于提升应用开发效率，实现更好的功能需求，因此了解自定义弹窗的选型和差异非常重要。在应用开发中，为了选择出
合适的弹窗选型，从使用场景上，需要重点关注以下两点：

* 弹窗与界面代码解耦
在开发业务逻辑时，例如遇到一些网络请求失败的场景，需要触发相应的弹窗提醒用户进行操作，由于在任何页面都有可能触发对应的弹窗，此时弹窗不是与某个
页面相关联，这个情况下，就需要弹窗与界面的解耦。

* 弹窗在界面跳转后保留
在一些权限配置页，用户首次进入应用时会弹出权限配置弹窗，让用户进行操作，此时若点击跳转到隐私详情页面，返回后弹窗需要保留在页面上。

## 预览效果
![](./screenshots/device/Effect.gif)

## 工程目录
``` 
├──entry/src/main/ets                                   // 代码区
│  ├──entryability
│  │  └──EntryAbility.ets                               // 程序入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  ├──pages                              
│  │  ├──CustomDialogDisplayAndExitAnimations.ets       // 自定义弹窗显示和退出动画示例  
│  │  ├──CustomDialogNotDisappear.ets                   // 切换页面弹窗不消失示例
│  │  ├──GlobalDialogDecoupledFromThePage.ets           // 与页面解耦的全局弹窗示例
│  │  ├──Index.ets                                      // 入口文件
│  │  ├──InterceptReturn01.ets                          // 拦截物理返回按钮、手势滑动关闭弹窗示例一
│  │  └──InterceptReturn02.ets                          // 拦截物理返回按钮、手势滑动关闭弹窗示例二
│  └──utils.ets
│     └──PromptActionClass.ets                            // 自定义弹窗封装Class
└──entry/src/main/resources                             // 应用资源目录
``` 
## 使用说明
依次点击应用首页的5个按钮，进入后可以实现以下4个场景：
* 与页面解耦的全局弹窗示例（按钮1）
* 拦截物理返回按钮示例（按钮2、3）
* 切换页面弹窗不消失（按钮4）
* 自定义弹窗显示和退出动画示例（按钮5）

## 实现说明
* 全局弹窗可以通过UIContext.getPromptAction弹窗实现。
* 物理拦截通过弹窗的选项对象中的onWillDismiss交互式关闭回调函数，或者基于Navigation自定义弹窗，使用NavDestination的回调函数onBackPressed实现。
* 切换页面弹窗不消失，通过Navigation.Dialog弹窗实现，NavDestinationMode.DIALOG弹窗存在于路由栈中，可以实现切换页面弹窗不消失。
* 自定义弹窗显示和退出动画，基于UIContext.getPromptAction弹窗实现，通过CustomDialogOptions自定义弹窗的内容，BaseDialogOptions弹窗选项transition参数可以设置弹窗显示和退出的过渡效果。

参考文章：[自定义弹窗选型与开发](https://developer.huawei.com/consumer/cn/doc/best-practices/bpta-customdialog-selection-and-development)。

## 相关权限
无

## 约束与限制
* 本示例仅支持标准系统上运行，支持设备：华为手机。

* HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

* DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

* HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。

## 下载

如需单独下载本工程，执行如下命令：
```
git init
git config core.sparsecheckout true
echo CustomDialogPractice/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```