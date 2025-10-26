# 基于Sendable实现多线程功能

### 介绍

本示例介绍Sendable的多种使用案例。Sendable的线程间共享：以文件下载为例，点击“启动”即转为“暂停”，进度条递增至100%则变为“完成”。生产者消费者模式多线程协同工作：支持单/双消费者线程消费，十子线程生产日志，长时生产及停止，以及消费者线程停止。

### 效果图预览

![](screenshots/device/UseSendable.gif)

##### 使用说明

1. 点击“Sendable的线程间共享”按钮，进入“文件下载列表”页面；
2. 点击“启动”按钮，“启动”按钮变成“暂停”按钮，页面进度条每次增加20%；
3. 当进度条到达“100%”，“启动”按钮变成“完成”按钮；
4. 点击“暂停”按钮，“暂停”按钮变成“继续”按钮，页面进度条停止增加；
5. “继续”按钮变成“暂停”按钮，页面进度条每次增加20%；
6. 返回上一页面，点击“生产者消费者模式”按钮，进入“生产者消费者模式”页面；
7. 点击“一个消费者线程消费”按钮，点击“主线程生产一条日志”按钮，打印出一条带有“consumerOne”日志；
8. 点击“二个消费者线程消费”按钮，多次点击“主线程生产一条日志”按钮，打印多条带有“consumerOne”和“consumerTwo”日志；
9. 点击“十个子线程生产十条日志”按钮，打印出10条日志；
10. 点击“长时生产日志”按钮，会一直打印日志；
11. 点击“停止长时生产日志”按钮，日志停止打印；
12. 点击“停止消费者线程”按钮；
13. 退出应用。

## 工程目录

```
├──entry/src/main/ets                         // 代码区
│  ├──constants
│  │  └──Constants.ets                        // 公共常量
│  ├──downLoadFilePage
│  │  ├──model                                // 实体类   
│  │  ├──DownLoadComponent.ets                // 下载子组件
│  │  ├──DownLoadFilePage.ets                 // 文件下载页面
│  │  └──DownLoadVideo.ets                    // 进度条
│  ├──entryability
│  │  └──EntryAbility.ets                     // 程序入口              
│  ├──pages
│  │  └──Index.ets                            // 首页     
│  ├──producerConsumer
│  │  ├──model                                // 实体类   
│  │  ├──tasks                                // Task
│  │  └──ProducerConsumerPage.ets             // 生产者消费者模式（日志打印）页面
│  └──utils
│     └──Logger.ets                           // 日志类
└──entry/src/main/resources                   // 应用资源目录
```

### 相关权限

不涉及。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。