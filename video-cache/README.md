# 实现视频边缓存边播放功能

### 简介

本示例基于三方库OhosVideoCache，实现了视频边缓存边播放的功能，将音视频的url传递给OhosVideoCache处理之后再设置给播放器， 即可一边下载音视频数据并保存在本地，一边读取本地缓存返回给播放器，适用于HTTP/HTTPS协议类型流媒体播放场景。

### 效果预览：

![image](screenshots/video.png)

使用说明：

1.本案例需要访问一个网络视频直链来实现边缓存边播放的功能，您可以修改VideoPlayerManager.ets中的ORIGIN_URL为想要播放的视频直链(HTTP/HTTPS协议类型典型链接: https://xxxx.mp4)，本案例也提供了一个本地视频和本地搭建服务器的方案，来模拟访问网络视频的情况，请参考搭建服务器章节。

2.安装应用后打开，应用会一边下载音视频数据并保存在本地，一边读取本地缓存返回给播放器进行播放。

### 搭建服务器

1.本案例提供了Python脚本快速搭建服务器，需要本地有Python环境，另外，您需要安装Flask框架，可以通过Python的包管理器pip来安装Flask，在终端输入以下命令：

```
pip install flask
```

2.修改video_server.py中的VIDEO_PATH，将其替换为想要播放的视频的实际路径。

3.使用终端运行脚本：
```
python video_server.py
```

4.脚本将启动一个Flask服务器，默认监听5000端口，您可以通过访问http://<您的电脑IP地址>:5000/video来播放视频。

### 工程目录

```
├──entry/src/main/ets
│  ├──common
│  │  └──CommonConstants.ets            // 公共常量类
│  ├──entryability
│  │  └──EntryAbility.ets               // 程序入口类
│  ├──model
│  │  ├──GlobalProxyServer.ets          // 代理服务器
│  │  └──VideoPlayerManager.ets         // 播放器管理类
│  ├──pages                  
│  │  └──Index.ets                      // 首页
│  └──utils
│     └──utils.ets                      // 工具类
└──entry/src/main/resource              // 应用静态资源目录
```

### 相关权限

- ohos.permission.INTERNET
- ohos.permission.GET_NETWORK_INFO

### 约束与限制

1.本示例仅支持标准系统上运行，支持设备：华为手机。

2.HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3.DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4.HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。