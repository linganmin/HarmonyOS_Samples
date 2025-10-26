# **基于enableDataDetector属性实现特殊文本识别的能力**
## 介绍
本示例通过Text组件的enableDataDetector属性，实现对一段文本中的特殊文字识别，比如包含链接、电话号码、日期、地址和邮箱的文本中，能自动识别出哪些文本是这些特殊文字。
特殊文字会变蓝并增加下划线。当识别出链接、电话号码、日历、地址和邮箱时，用户点击这些文本，弹出对应的操作菜单，点击菜单中的操作选项后会进行相应的跳转。
## 预览效果
![](screenshots/device/image.png)
## 工程目录
``` 
├──entry/src/main/ets                                   // 代码区
│  ├──entryability
│  |  └──EntryAbility.ets                               // 程序入口类
│  ├──entrybackupability
│  |  └──EntryBackupAbility.ets
│  ├──pages
│  |  ├──Index.ets                                      // 首页
│  |  └──LinksPage.ets                                  // 特殊文本识别页面
|  └──uiComponent.ets
│     └──TextLink.ets                                   // 文字UI组件
└──entry/src/main/resources                             // 应用资源目录
``` 

## 使用说明

* 标准HTTP/HTTPS链接：用户点击后，弹出操作菜单，点击“打开”后，跳转至系统默认浏览器打开链接。
* AppLinking链接：用户点击后，弹出操作菜单，点击“打开”后，若系统已安装对应的应用，则直接拉起该应用；若未安装，则拉起应用市场或者跳转到浏览器中的Web页面。
* 日期链接：用户点击后，弹出操作菜单，点击“新建日程提醒”后，拉起系统新建日程的页面。
* 电话号码链接：用户点击后，弹出操作菜单，可选择进行呼叫、发生短信、新建联系人等操作。
* 地址链接：用户点击后，弹出操作菜单，点击“导航至该位置”后，拉起系统弹窗，可选择已安装的地图应用进行导航。当前系统规格不支持对英文地址的识别跳转。
* 邮箱链接：用户点击后，弹出操作菜单，点击“新建邮件”后，拉起系统弹窗，点击“电子邮件”后，拉起电子邮件应用。

## 相关权限

不涉及。
## 约束与限制
* 本示例仅支持标准系统上运行，支持设备：华为手机。

* HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

* DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
  
* HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。