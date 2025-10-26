# 实现简易音频播放功能

### 介绍

本示例主要作为可外部调用操作的本地运行模块，实现了音频播放、信息获取、页面跳转的功能。

### 效果预览

| 首页                                 | 第二页页                               |
|------------------------------------|------------------------------------|
| ![](screenshots/devices/page1.png) | ![](screenshots/devices/page2.png) |

### 使用说明

1. 进入首页，点击“跳转到第二页”按钮，进入第二页；
2. 点击“播放音乐”，播放设置的音频；
3. 点击“获取信息”，展示APP信息区域显示音乐名称；
4. 点击“返回”，返回上一页。

### 工程目录

```
├──entry/src/main/ets                               // 代码区
│  ├──entryability                                  
│  │  │──intentHandlers                             // 意图实现类
│  │  │  ├──AudioPlayHandler.ets                    // 音频播放实现类
│  │  │  ├──PageNavigateHandler.ets                 // 页面跳转实现类
│  │  │  └──TextGetHandler.ets                      // 获取文本实现类                 
│  │  ├──EntryAbility.ets                           // 程序入口
│  │  └──InsightIntentExecutorImpl.ets              // 业务逻辑处理
│  ├──entrybackupability  
│  │  └──EntryBackupAbility.ets 
│  ├──models                                   
│  │  │──MusicData.ets                              // 音频播放枚举类                      
│  │  └──SongItem.ets                               // 音乐信息类
│  ├──pages
│  │  ├──MainPage.ets                               // 首页                                
│  │  └──SecondPage.ets                             // 第二页
│  └──utils                     
│     │──audioplayer                                // 音频播放工具类
│     │  ├──BackgroundUtil.ets 
│     │  ├──MediaService.ets
│     │  ├──MediaTools.ets
│     │  └──SongItemBuilder.ets  
│     └──Logger.ets                                 // 日志     
└──entry/src/main/resources                         // 应用资源目录
```

### 相关权限

不涉及。

### 依赖

不涉及。

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
echo XiaoyiAgentDemo/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```