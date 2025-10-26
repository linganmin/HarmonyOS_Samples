# Call Service Kit（通话服务）

### 介绍
本示例主要展示了Call Service Kit（通话服务）相关的功能
使用Call Service Kit、Push Kit、Image Kit等接口，实现了订阅'voipCallUiEvent'事件、上报音视频来电、上报通话状态变化等功能。

### 相关概念
Call Service Kit是华为提供给VoIP类应用的通话相关接口，管理VoIP类应用通话，做到VoIP类应用来电体验一致。

### 相关权限
1. ohos.permission.MICROPHONE，用于在语音通话中，使用麦克风。
2. ohos.permission.CAMERA，用于在视频通话中，使用相机。

### 使用说明
本示例展示了应用接收到服务端推送音视频来电信息后的操作行为。
为模拟服务端的发送音视频通话请求行为，需要您有自己的云服务器，并且结合Push Kit的Token相关内容，进行实际的音视频通话发送及接收操作。

### 效果预览
![锁屏预期效果图](screenshots/device/lock.jpeg) ![未锁屏预期效果图](screenshots/device/unlock.jpeg)

### 工程目录
```bash
├─entry/src/main/ets              // 代码区
│ ├─entryability
│ │ ├─EntryAbility.ets            // 程序入口类
│ │ └─VoipCallAbility.ets         // 事件响应
│ └─model                         // 业务逻辑和工具类
│ | └─CallDataManager.ets         // 通话业务逻辑
│ | └─TypeUtils.ets               // 工具类
│ └─pages                         // 存放页面文件的目录
│   └─Index.ets                   // 主页界面
│   └─VoipCallPage.ets            // 通话界面
└─entry/src/main/resources        // 应用资源目录
```

### 具体实现
本示例主要展示了应用调用通话服务相关接口等具体操作，包括：
1. 应用在接收到音视频来电后，订阅'voipCallUiEvent'事件，当用户在来电界面进行接听、挂断等操作时，会收到对应事件上报进而打出log：“Voip call event”。
2. 应用调用reportIncomingCall上报来电信息。
3. 应用内部处理完接听、挂断等操作后，调用reportCallStateChange接口向系统通知通话状态变化。

### 约束与限制
1. 本示例仅支持标准系统上运行，支持设备：华为手机。
2. HarmonyOS系统：HarmonyOS NEXT Developer Beta1及以上。
3. DevEco Studio版本：DevEco Studio NEXT Developer Beta1及以上。
4. HarmonyOS SDK版本：HarmonyOS NEXT Developer Beta1 SDK及以上。
   
   
