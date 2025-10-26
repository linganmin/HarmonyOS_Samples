# 基于子窗口实现悬浮窗

### 介绍
本示例通过子窗口和画中画接口实现悬浮窗和视频小窗功能，便于用户进行子窗口以及画中画相关操作。

### 效果预览

|                   主页                   |
|:--------------------------------------:|
| ![home](screenshots/devices/phone.gif) |

使用说明

1. 运行点击子窗口-悬浮窗按钮跳转到子窗口功能展示页面。
2. 点击四个按钮查看子窗口四种不同的操作。
3. 点击画中画-视频小窗跳转到画中画功能展示页面。
4. 点击启动画中画生成视频小窗。

### 工程目录

```
├──entry/src/main/ets/
│  ├──constants                         
│  │  └──CommonConstants.ets                 // 常量类
│  ├──entryability
│  │  └──EntryAbility.ets                    // 入口类
│  ├──pages
│  │  ├──Index.ets                           // 主页
│  │  ├──MiniWindowPage.ets                  // 子窗口显示隐藏页面
│  │  ├──NavigationRedirectPage.ets          // 子窗口通过Nacigation跳转到画中画页面
│  │  ├──ResizeWindowPage.ets                // 调整子窗口大小页面
│  │  ├──RouterRedirect.ets                  // 控制创建子窗口通过Router返回首页页面
│  │  └──RouterRedirectPage.ets              // 子窗口通过Router返回首页
│  ├──utils
│  │  └──Logger.ets                          // 日志类
│  ├──view
│  │  ├──MiniWindowComponent.ets             // 控制创建子窗口显示隐藏自定义组件
│  │  ├──NavigationRedirectComponent.ets     // 控制创建子窗口通过Nacigation跳转到画中画自定义组件
│  │  ├──PipWindowComponent.ets              // 画中画功能实现自定义组件
│  │  ├──ResizeWindowComponent.ets           // 控制创建调整子窗口大小自定义组件
│  │  └──SubWindowComponentRouter.ets        // 悬浮窗功能展示路由自定义组件
│  └──viewmodel
│     ├──AVPlayerDemo.ets                    // 视频播放控制类
│     └──WindowPosition.ets                  // 子窗口位置类
└──entry/src/main/resources                  // 应用静态资源目录
```

### 相关权限

不涉及。

### 依赖

不涉及。

### 约束与限制

1.本示例仅支持标准系统上运行，支持设备：华为手机。

2.HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3.DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4.HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。