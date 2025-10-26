# 实现流畅切换短视频

### 简介

本示例基于在线短视频场景，通过LazyForEach进行数据懒加载，同时搭配组件复用能力以达到高性能效果，帮助开发者解决在应用中在线短视频快速切换时容易出现起播时间延长的问题，提供对应场景的解决方案。

### 效果预览：

![image](screenshots/Main.png)

### 使用说明：

1. 本示例需要访问网络视频直链来获取视频资源，您可以修改entry/src/main/ets/common/CommonConstants.ets中的VIDEO_SOURCE为想要播放的视频直链，本示例也提供了本地视频和本地搭建服务器的方案，来模拟访问网络视频的情况，请参考《搭建服务器》章节。

2. 安装应用后打开，应用会播放资源链接的视频，可上下滑动切换短视频。

### 搭建服务器

1. 本示例提供了Python脚本快速搭建服务器，需要本地有Python环境，另外，您需要安装Flask框架，可以通过Python的包管理器pip来安装Flask，在终端输入以下命令：

    ```
    pip install flask
    ```

2. 修改video_server.py中的VIDEO_PATH，将其替换为想要播放的视频的实际路径。

3. 修改entry/src/main/ets/common/CommonConstants.ets中的VIDEO_SOURCE中的链接，按照提示替换为PC的IP地址。

4. 保证播放设备和搭建服务器的PC在同一局域网内，在server文件夹内使用终端运行脚本：

    ```
    python video_server.py
    ```

5. 脚本将启动一个Flask服务器，默认监听5000端口。

### 工程目录

```
├──entry/src/main/ets
│  ├──common
│  │  ├──utils         
│  │  │  └──CommonUtils.ets             // 公共方法类
│  │  └──CommonConstants.ets            // 公共常量类
│  ├──entryability
│  │  └──EntryAbility.ets               // 程序入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets        
│  ├──model
│  │  ├──AVDataSource.ets               // 视频数据类
│  │  └──AVPlayereState.ets             // 视频状态类
│  ├──pages                  
│  │  └──Index.ets                      // 首页
│  └──view
│     └──VideoPlayView.ets              // 视频播放组件
└──entry/src/main/resources             // 应用静态资源目录
```

### 具体实现

1. 视频播放框架AVPlayer和滑块视图容器Swiper进行短视频滑动轮播切换。

2. 绘制组件XComponent的Surface类型动态渲染视频流。

3. 使用LazyForEach进行数据懒加载，设置cachedCount属性来指定缓存数量，同时搭配组件复用能力以达到高性能效果。

4. 在冷启动过程中创建一个AVPlayer并进行数据初始化到prepared阶段，在轮播过程中，每次异步创建一个播放器为下一个视频播放做准备。

### 相关权限

- ohos.permission.INTERNET

### 依赖

- 不涉及

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。