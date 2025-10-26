# 基于Http实现网络请求功能

### 介绍

本示例通过@ohos.net.http等接口，实现了根据URL地址和相关配置项发起http请求的功能。帮助开发者实现使用http获取网络请求的场景。

### 效果预览

|首页|结果页|
|--------------------------------|--------------------------------|
|![](screenshots/device/index.png)|![](screenshots/device/result.png)|

使用说明

1.启动应用可配置网络请求，设置网址、请求方式、请求参数；

2.点击确认按钮，跳转请求结果页面；

3.点击返回按钮，返回配置页面；

4.支持将本示例中的http模块编译成tgz包。

### 工程目录

```
├──entry/src/main/ets/
│  ├──Application
│  │  └──MyAbilityStage.ets
│  ├──MainAbility
│  │  └──MainAbility.ets          // 项目入口，请求相关权限
│  ├──page
│  │  └──Index.ets                // 首页
│  └──util                        // 日志文件
│     └──Logger.ets               // 日志文件
├──entry/src/main/resources       // 应用静态资源目录
│
├──httprequest/src/main/ets/
│  └──components
│     ├──MainPage
│     │  └──MainPage.ets          // 首页主体内容
│     └──model
│        └──http.ts               // 封装了http参数和发起请求的接口
└──http/src/main/resources        // 应用静态资源目录
```

### 具体实现

* 本示例将发送http请求的接口封装在Http模块，源码参考：[http.ts](httprequest/src/main/ets/components/model/http.ts)
  * 发起请求：在[MainPage.ets](httprequest/src/main/ets/components/MainPage/MainPage.ets)
  通过TextInput组件获取参数，点击“确认”按钮后通过Http.request()方法调用http.createHttp().request()接口向指定的地址发送请求。

### 相关权限

ohos.permission.INTERNET

### 依赖

不涉及。

### 约束与限制

1.本示例仅支持标准系统上运行，支持设备：华为手机。

2.HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3.DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4.HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。