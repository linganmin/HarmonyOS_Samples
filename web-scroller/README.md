# 实现Web组件嵌套滑动功能

## 简介
本示例基于组件通用的onScrollFrameBegin()滚动开始的注册回调以及设置滚动模式，实现了父组件滚动后Web组件再进行滚动、Web组件全量展开滑动、多容器嵌套滚动等功能，为用户滚动浏览网页内容提供了更加精确有效的操作逻辑支撑。

## 效果预览
手机运行效果图如下：

![image](screenshots/device/phone.gif)
## 工程目录

```
├──entry/src/main/ets/
│  ├──entryability
│  │  └──EntryAbility.ets               // 程序入口类
│  ├──pages                  
│  │  ├──NestedScrolling.ets            // 父组件滚动后Web组件再进行滚动
│  │  ├──FullExpansion.ets              // Web组件全量展开滑动
│  │  ├──WebNestedTabs.ets              // 多容器嵌套滚动
│  │  └──Index.ets                      // 首页
│  ├──view                  
│  │  └──StandardButtonList.ets         // 封装首页功能区
│  └──viewmodel                  
│     └──MenuViewModel.ets              // 菜单栏数据
└──entry/src/main/resource              // 应用静态资源目录

```

## 具体实现
- 父组件滚动后Web组件再进行滚动：依赖onScrollFrameBegin()控制元素尺寸与嵌套滚动效果。
- Web组件全量展开滑动：依靠renderMode为RenderMode.SYNC_RENDER，保持Web组件同步渲染，使得父容器尺寸大小适应Web组件。
- 多容器嵌套滚动：设置滚动模式，向下滚动时优先父组件滚动，向上滚动时优先自身滚动。

## 相关权限
- ohos.permission.INTERNET：网络请求权限用于访问网络页面

## 约束与限制
1. 本示例仅支持标准系统上运行，支持设备：华为手机。
2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。