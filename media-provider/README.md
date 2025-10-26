# 实现音频应用作为媒体会话提供方接入媒体会话

## 介绍

本示例主要展示了媒体会话（媒体提供方）的相关功能，使用@ohos.multimedia.avsession等接口实现媒体提供方与媒体播控中心自定义信息的交互功能。

> 注意：
> 此示例仅展示媒体提供方的相关功能，如果需要媒体会话提供的完整的自定义信息交互功能，请将本示例与系统播控中心共同使用。

## 效果预览

![Index](screenshot/device/media_provider.gif) 

## 使用说明

### 基础操作

1. 打开媒体提供方示例应用。
2. 点击播放按钮，应用的播放状态发生变化，进度开始刷新。
3. 点击暂停按钮，应用的播放状态开始变化，进度停止刷新。
4. 点击上一首按钮，应用界面展示播放列表中的上一首歌曲的信息。
5. 点击下一首按钮，应用界面展示播放列表中的下一首歌曲的信息。
6. 点击播放，拖动进度条，播放进度改变。
7. 点击收藏，收藏按钮点亮。
8. 点击播放模式，可以切换不同的播放模式（注：播放模式未实现功能，仅实现与播控中心状态同步）。

### 进阶操作（与媒体播控中心一起使用）

1. 点击本应用播放、暂停、上一首、下一首按钮，可以发现媒体播控中心中，该会话的状态同步改变。
2. 点击媒体播控中心的对应按钮，可以发现本应用中按钮状态同步改变。
3. 媒体播控中心可以获取到本应用的正在播放内容、播放模式、歌词、进度、收藏状态、媒体资源金标、历史歌单等信息。

## 工程目录

给出项目中关键的目录结构并描述它们的作用，示例如下：

```
├──entry/src/main/ets/
│  ├──common
│  │  ├──constants
│  │  │  └──Constants.ets                       // 常量类
│  │  └──utils
│  │     ├──GlobalContextUtils.ets              // 全局上下文封装
│  │     ├──Logger.ets                          // 日志打印封装
│  │     └──MediaData.ets                       // 歌曲相关信息
│  ├──entryability
│  │  └──EntryAbility.ets  
│  ├──model
│  │  ├──IntentExecutorImpl.ets                 // 意图调用执行实现类
│  │  └──mediaData.ets                          // 媒体数据类型  
│  ├──pages
│  │  └──Index.ets                              // 界面实现
│  └──viewmodel
│     └──ProviderManager.ets                    // 媒体提供方状态管理
└───entry/src/main/resources                    // 应用资源目录
```

## 具体实现

* 界面相关的实现都封装在pages/Index.ets下，源码参考：[pages/Index.ets](./entry/src/main/ets/pages/Index.ets)
  
  * 使用`@StorageLink`来设置与逻辑代码同步更新的变量，当逻辑代码中对应的变量更新时，界面会同步的刷新。
  
  * 通过引入逻辑代码对应的类，创建出对象，实现对onClick事件的响应，关键代码段：
    
    ```ets
    import { ProviderFeature } from '../feature/ProviderFeature';
    this.providerFeature = await ProviderFeature.getInstance(); // 创建对象单例
    
    Button() {
      // 按钮的内容
    }
    .onClick(async () => {
      this.providerFeature.play(); // 通过类的对象来调用逻辑代码
    })
    ```

* 逻辑相关的实现都封装在viewmodel/ProviderManger.ets下，源码参考：[viewmodel/ProviderManager.ets](entry/src/main/ets/viewmodel/ProviderManager.ets)
  应用的初始化相关操作
  
  * 链接变量
    通过`AppStorage.SetAndLink()`将逻辑代码中的变量与界面代码中使用`@StorageLink`声明的变量连接起来，通过`set()`与`get()`操作来修改或获取变量的值，关键代码段：
    
    ```ets
    private isPlayLink: SubscribedAbstractProperty<boolean> = null;
    this.isPlayLink = AppStorage.SetAndLink('IsPlaying', false);
    this.isPlayLink.set(false); // 设置变量的值
    let currentState : boolean = this.isPlayLink.get(); // 获取变量的值
    ```

* 创建并设置媒体会话
  通过接口`createAVSession()`创建媒体会话；
  通过接口`activate()`激活媒体会话；
  通过接口`setAVMetadata()`设置当前媒体的元数据，设置后媒体播控中心可以读取使用此信息；
  通过接口`setAVPlaybackState()`设置当前媒体的播放信息，包括播放状态、播放进度，设置后媒体播控中心可以读取使用此信息；
  通过接口`on()`开启对媒体播控中心控制命令的监听，对媒体播控中心的命令进行处理，请激活媒体会话后再调用；
  应用在运行中相关的操作

* 切换歌曲
  在切换歌曲时，除了需要设置媒体提供方自身的状态，还需要使用接口`setAVPlaybackState()`与接口`setAVMetadata()`将当前播放状态与元数据同步给媒体播控中心。

* 发送自定义数据包
  媒体提供方可以使用接口`dispatchSessionEvent()`与接口`setExtras()`来发送自定义数据包。

## 相关权限

1. 长时任务权限ohos.permission.KEEP_BACKGROUND_RUNNING
   如果需要让媒体提供方应用在后台运行或响应命令，需要注册长时任务权限[ohos.permission.KEEP_BACKGROUND_RUNNING]
   请在需要后台运行的Ability的`module.json5`中添加以下配置：
   
   ```json5
   {
     "requestPermissions": [
       {
         "name": "ohos.permission.KEEP_BACKGROUND_RUNNING",
         "reason": "$string:reason_keep_background_running",
         "usedScene": {
           "abilities": [
             "EntryAbility"
           ],
           "when": "always"
         }
       }
     ]
   }
   ```
   
   添加配置后，需要在逻辑代码中进行申请长时任务的操作，示例代码如下：
   
   ```ets
   async startContinuousTask(){
     let wantAgentInfo = {
       wants:[
         {
           bundleName: "com.samples.mediaprovider",
           abilityName:"EntryAbility"
         }
       ],
       operationType : WantAgent.OperationType.START_ABILITY,
       requestCode: 0,
       wantAgentFlags: [WantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
     };
     let want = await WantAgent.getWantAgent(wantAgentInfo);
     await backgroundTaskManager.startBackgroundRunning(globalThis.context, backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK,want);
   }
   ```

## 依赖

此示例仅展示媒体提供方的相关功能，如果需要媒体会话提供的完整的自定义信息交互功能，请将本示例与媒体播控中心共同使用。

## 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。
2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。
