# 基于备份恢复框架的数据迁移

### 介绍
本示例通过备份恢复框架实现终端设备从HarmonyOS 4.0升级到HarmonyOS 5.0.0后，应用如何将关系型数据库、文件、XML数据迁移到HarmonyOS NEXT上并恢复，开发者可以利用备份恢复框架里的[EntryBackupAbility.ets](entry/src/main/ets/entrybackupability/EntryBackupAbility.ets)，通过实现onRestore()方法来进行数据恢复。

### 效果预览

|                    主页                     |
|:-----------------------------------------:|
| ![home](screenshots/devices/phone_zh.gif) |

使用说明
1. 参考[设备升级应用数据迁移适配指导](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/adaptation-process)下适配流程文章中开发者自验证章节获取迁移工具。
2. 运行hdc file send com.example.backuprestore.zip /storage/media/100/local/files/Docs/Download 将同级目录中[com.example.backuprestore.zip](com.example.backuprestore.zip)发送到设备上。
3. 参考[HarmonyOS NEXT上模拟验证应用数据迁移](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/self-verification)进行数据迁移。
4. 点击数据库、文件、XML数据查看迁移后的数据。

### 工程目录

```
├──entry/src/main/ets/
│  ├──entryability
│  │  └──EntryAbility.ets                    // 入口类
│  ├──entryability
│  │  └──EntryBackupAbility.ets              // 备份恢复框架
│  ├──pages
│  │  └──Index.ets                           // 主页
│  ├──restore
│  │  ├──db
│  │  │  └──DbTransferManager.ets            // 恢复数据库数据
│  │  ├──fileMigrate
│  │  │  └──FileTransferManager.ets          // 恢复文件数据
│  │  └──sp
│  │     └──SpTransferManager.ets            // 恢复XML数据
│  └──view
│     ├──FileShow.ets                        // 展示文件数据
│     ├──RdbDataShow.ets                     // 展示数据库数据
│     └──XMLDataShow.ets                     // 展示xml数据
└──entry/src/main/resources                  // 应用静态资源目录

```

### 具体实现

1. 应用备份恢复框架入口为EntryBackupAbility.ets，开发者可实现onRestore()方法来进行数据恢复。
2. DbTransferManager.ets文件实现了关系型数据库的数据恢复。
3. FileTransferManager.ets文件实现了文件数据恢复。
4. SpTransferManager.ets文件实现了XML文件的数据恢复。

### 相关权限

不涉及。

### 依赖

不涉及。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。