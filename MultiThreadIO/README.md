# 基于Taskpool和@Sendable的关系型数据库和文件读写

### 介绍

本示例基于TaskPool和@Sendable实现了密集型文件和关系型数据库的读写操作,使用Taskpool创建线程，使用@Sendable实现线程间的数据传递，帮助开发者实现多线程的密集型读写。

### 效果预览

| 首页                                   |
|--------------------------------------|
| ![image](screenshots/device/index.gif) |

### 使用说明：

本示例提供8个按钮触发使用TaskPool和@Sendable对于文件和关系型数据库的读写：
1. TaskPool 文件-写入：点击该按钮完成使用TaskPool对于文件的写入。
2. TaskPool 文件-读取：点击该按钮完成使用TaskPool对于文件的读取。
3. @Sendable 文件-写入：点击该按钮完成使用TaskPool和@Sendable对于文件的写入。
4. @Sendable 文件-读取：点击该按钮完成使用TaskPool和@Sendable对于文件的读取。
5. TaskPool 数据库-写入：点击该按钮完成使用TaskPool对于数据库的写入。
6. TaskPool 数据库-读取：点击该按钮完成使用TaskPool对于数据库的读取。
7. @Sendable 数据库-写入：点击该按钮完成使用TaskPool和@Sendable对于数据库的写入。
8. @Sendable 数据库-读取：点击该按钮完成使用TaskPool和@Sendable对于数据库的读取。
9. 读写成功后会以“成功”Toast弹窗作为提示；当在进行其他I/O任务时会以“在执行任务，请稍后”，作为提示；若无写入内容，执行读取，会提示读取内容为空。

### 工程目录

```
├──entry/src/main/ets/
│  ├──commons                                  
│  │  ├──constants               
│  │  │  └─CommonConstants.ets          // 常量类 
│  │  └──utils          
│  │     ├─DatabaseSendable.ets         // 关系型数据库Sendable操作类
│  │     ├─DatabaseTaskPool.ets         // 关系型数据库TakPool操作类
│  │     ├─FileSendable.ets             // 文件Sendable操作类
│  │     └─FileTaskPool.ets             // 文件TakPool操作类
│  ├──entryability
│  │  └──EntryAbility.ets               // 程序入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets         // 备份恢复类
│  └──pages                 
│     └──Index.ets                      // 首页
└──entry/src/main/resources             // 应用资源目录
```

### 具体实现
1. TaskPool操作：封装读写函数使用@Concurrent修饰，传入taskpool.execute()中执行。
2. @Sendable将数据封装成class，使用@Sendable修饰。

### 相关权限
不涉及

### 依赖
不涉及

### 约束与限制

1.本示例仅支持标准系统上运行，支持设备：华为手机。

2.HarmonyOS 系统：HarmonyOS 5.0.5 Release及以上。

3.DevEco Studio 版本：DevEco Studio 5.0.5 Release及以上。

4.HarmonyOS SDK 版本：HarmonyOS 5.0.5 Release SDK及以上。 