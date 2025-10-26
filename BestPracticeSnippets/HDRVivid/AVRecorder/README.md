# 基于CameraKit通过AVRecorder录像

### 介绍

本示例通过CameraKit自定义相机，并通过AVRecorder进行录像。

### 效果图预览

|               获取权限              |             录制页                  |                录制中                      |              主页                  |
|-----------------------------------|------------------------------------|-------------------------------------------|-----------------------------------|
|![](screenshots/device/request.png)| ![](screenshots/device/record.png) | ![](screenshots/device/stopRecording.png) | ![](screenshots/device/index.png) |

### 使用说明

1. 获取权限。
2. 点击“录制视频”按钮，判断授权权限，若权限均已授权，则跳转录制页面，否则需按提示开启所有权限后重新点击“录制视频”按钮。
3. 点击开始录制按钮，开始录制视频。
4. 点击停止录制按钮，停止录制视频，并返回首页，在“录制视频”按钮上方显示录制的视频，视频可手动播放。

### 工程目录

```
├───entry/src/main/ets
│   ├───common
│   │   └───CommonConstants.ets            // 常量
│   ├───entryability                        
│   │   └───EntryAbility.ets               // Ability的生命周期回调内容
│   ├───pages    
│   │   ├───Index.ets                      // 主页
│   │   └───Record.ets                     // 录制页
│   └───utils                               
│       ├───FileUtil.ets                   // 文件工具类
│       ├───Logger.ets                     // 日志工具类
│       └───RouterParams.ets               // 路由参数类
└───entry/src/main/resources     
```

### 实现思路

1. 通过cameraInput,获取相机采集数据，创建相机输入。
2. 创建previewOutput，获取预览输出流，通过XComponent的surfaceId连接，送显XComponent。
3. 通过AVRecorder的surfaceId创建录像输出流VideoOutput输出到文件中。

### 相关权限

- 允许应用使用相机：ohos.permission.CAMERA。
- 允许应用使用麦克风：ohos.permission.MICROPHONE。
- 允许应用访问用户媒体文件中的地理位置信息：ohos.permission.MEDIA_LOCATION。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 5.1.0 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.1.0 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.1.0 Release SDK及以上。

### 下载

如需单独下载本工程，执行如下命令：
```
git init
git config core.sparsecheckout true
echo HDRVivid/AVRecorder/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```

