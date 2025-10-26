# 基于应用接续实现分布式视频播放器功能

### 介绍

基于ArkTS扩展的声明式开发范式编程语言编写的一个分布式视频播放器，主要包括一个直播视频播放界面，实现视频播放时可以从一台设备迁移到另一台设备继续运行，来选择更合适的设备继续执行播放功能以及平板视频播放时协同调用手机编辑发送弹幕功能。

### 效果预览
![dia.gif](./screenshots/devices/dia.gif)

**使用说明**

1. 准备手机端与平板端两台设备，并且登录同一华为账号，双端设备打开WI-FI和蓝牙，建议双端设备接入同一个局域网，可提升数据传输的速度
2. 双端设备均安装此应用
3. 滑动浏览手机端视频，打开平板端应用
4. 点击平板端手机输入按钮，调起手机端输入内容，提交后平板端查看

### 工程目录

```
├──entry/src/main/ets             // 代码区
│  ├──common
│  │  └──Constants.ets            // 公共常量类
│  ├──entryability
│  │  └──EntryAbility.ets         // 程序入口类
│  ├──inputability
│  │  └──InputAbility.ets         // 手机文本编辑入口类
│  ├──model
│  │  ├──LiveData.ets             // 直播视频相关数据
│  │  └──LiveDataModel.ets        // 直播视频类
│  ├──pages
│  │  ├──CommentPage.ets          // 弹幕显示界面
│  │  ├──InputPage.ets            // 手机评论编辑界面
│  │  └──LivePage.ets             // 视频播放界面
│  └──utils
│     ├──Logger.ets               // 日志类
│     └──WindowUtil.ets           // 界面控制类
└──entry/src/main/resource        // 应用静态资源目录
```

### 具体实现
1. 在实现协同接口前，应用需要申请协同所需的访问控制权ohos.permission.DISTRIBUTED_DATASYNC。
   在requestPermissions字段中增加权限声明ohos.permission.DISTRIBUTED_DATASYNC
2. 同时需要在应用首次启动时弹窗向用户申请授权，在用户手动允许授权后，应用才会真正获取相应权限，从而成功访问操作目标对象。
   打开“entry > src > entryability > EntryAbility.ets” 文件，在EntryAbility类中实现以下函数，从而在调用时动态弹窗向用户申请权限。
3. 获取目标设备的设备ID。
4. 在发起端设置目标组件参数，调用startAbilityForResult()接口启动目标端UIAbility，异步回调中的data用于接收目标端UIAbility停止自身后返回给调用方UIAbility的信息。
5. 在目标端UIAbility任务完成后，调用terminateSelfWithResult()方法，将数据返回给发起端的UIAbility。
6. 发起端UIAbility接收到目标端UIAbility返回的信息，对其进行处理。

### 相关权限

ohos.permission.DISTRIBUTED_DATASYNC：允许不同设备间的数据交换。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机、平板。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。