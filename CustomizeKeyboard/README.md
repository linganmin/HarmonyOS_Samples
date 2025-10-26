# 实现自定义键盘功能

### 介绍

本示例介绍自定义键盘的实现，通过绑定系统键盘，实现自定义键盘和系统键盘的切换；通过onAreaChange获取自定义键盘高度，设置布局避让；为开发者讲解键盘切换、自定义键盘光标处理、自定义键盘布局避让等技术场景案例。

### 效果预览
|               自定义键盘布局避让                |              自定义键盘和系统键盘切换               |              自定义键盘通用功能               |
|:--------------------------------------:|:---------------------------------------:|:------------------------------------:|
| ![image](screenshots/device/avoid.gif) | ![image](screenshots/device/switch.gif) | ![image](screenshots/device/use.gif) |


使用说明

1. 首页点击“绑定自定义键盘”输入框，拉起自定义键盘，布局会向上避让。

2. 分别点击键盘上“123”、“ABC”、“中文”tab页签，切换数字键盘、英文键盘、系统键盘，实现一个输入框同时绑定自定义键盘和系统键盘。

3. 支持键盘通用操作，包括内容输入、光标设置、大小写切换、复制、粘贴、删除等功能。


### 工程目录

```
├──entry/src/main/ets	                 // 代码区
│  ├──constants
│  │  └──Constants.ets                   // 公共常量类
│  ├──entryability
│  │  └──EntryAbility.ets                // 程序入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets          // 数据备份
│  ├──model
│  │  └──KeyboardController.ets          // 自定义键盘控制类
│  ├──pages
│  │  └──MainPage.ets                    // 主页面
│  ├──view
│  │  ├──CustomKeyboard.ets              // 自定义键盘入口
│  │  ├──CustomKeyboardComponent.ets     // 自定义键盘组件
│  │  ├──EnglishKeyboard.ets             // 英文键盘组件
│  │  ├──InputTextComponent.ets          // 绑定的TextInput组件
│  │  ├──NumberKeyboard.ets              // 数字键盘组件
│  │  ├──TabButton.ets                   // 键盘上方Tab组件Button按钮
│  │  ├──TabView.ets                     // 键盘上方Tab组件
│  │  └──TextInputComponent.ets          // 绑定自定义键盘的TextInput类
│  └──viewmodel
│     └──MenuModel.ets                   // 键盘按钮数据
└──entry/src/main/resources              // 资应用资源目录
```

### 具体实现 

1. TextInput组件customKeyboard属性绑定builder，实现自定义键盘。
2. TextInput组件customKeyboard属性传值null，绑定系统键盘，实现自定义键盘和系统键盘的切换。
3. 监听TextInput组件onTextSelectionChange、onChange事件，实现光标位置设置。
4. 监听TextInput组件onPaste、onCut事件，实现复制粘贴功能。
5. 通过window的keyboardHeightChange事件获取系统键盘高度，通过onAreaChange获取自定义键盘高度，设置布局避让。

### 相关权限
不涉及。

### 依赖
不涉及。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。