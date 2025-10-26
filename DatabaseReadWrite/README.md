# 使用C-API读写关系型数据库

### 介绍

本示例展示了使用了C-API接口对关系型数据库进行增删改查的场景。

### 效果预览



|                             主页                              |                           增加/编辑商品                           |                            筛选商品                             |
|:-----------------------------------------------------------:|:-----------------------------------------------------------:|:-----------------------------------------------------------:|
| <img src=./screenshots/pic1.png align="center" width=320 /> | <img src=./screenshots/pic2.png align="center" width=320 /> | <img src=./screenshots/pic3.png align="center" width=320 /> |

### 使用说明

1. 点击**新增**按钮可以添加一个商品，点击**提交**按钮后商品信息的增加会展示在主页面。
2. 点击编辑按钮可以修改当前列表一个商品的信息，点击**提交**按钮后商品信息的修改会展示在主页面。
3. 点击**删除**按钮可以删除当前列表的一个商品信息，删除后剩下的商品信息会展示在主页面。
4. 点击**商品**选择项用来筛选商品类别，可以筛选 Mate60/Mate40 系列产品并展示在商品列表。
5. 点击**售价**选择项用来筛选商品价格，可以根据价格筛选产品并展示在主页面。
6. 点击**刷新**按钮，清除筛选条件，展示全部商品。

### 具体实现

本示例分为NDK封装RDB数据库、ArkUI和NDK数据交互两个部分

- NDK封装RDB数据库：

  (1) 通过NDK能力封装RDB数据库。

  (2) 参考文件：RDB.h，RDB.cpp。

  (3) 指南参考：[RelationalStore开发指导 (C/C++)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/native-relational-store-guidelines-V5)，[NDK开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/ndk-development-overview-V5)。

- ArkUI和NDK数据交互：

  (1) 将NDK封装后的数据与ArkUI界面交互。

  (2) 参考文件：napi_init.cpp，index.ets，oh_modules/libentry.so/index.d.ts。

  (3) 指南参考：[NDK开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/ndk-development-overview-V5)。

### 工程目录

```c++
 ├───entry/src/main/ets       
 │   ├───constant      
 │   │   └───FileConstants.ets                      // 封装常量
 │   ├───entryability
 │   │   └───EntryAbility.ets                       // Ability的生命周期回调内容
 │   ├───entrybackupability
 │   │   └───EntryBackupAbility.ets                 // BackupAbility的生命周期回调内容
 │   ├───model
 │   │   └───GoodModel.ets                          // 封装商品类
 │   └───pages
 │       ├───Index.ets                              // 首页
 │       └───GoodsList.ets                          // 商品列表页
 ├───entry/src/main/cpp  
 │   ├───types/libentry/Index.d.ts                  // 函数、类型声明
 │   ├───RDB.h									    // 封装RDB数据库
 │   ├───RDB.cpp									// 封装RDB数据库
 │   └───napi_init.cpp                              // 封装自定义NDK函数到ArkUI
 └───entry/src/main/resources                       // 应用静态资源目录
```

### 相关权限

不涉及

### 依赖

不涉及

### 约束与限制

1.本示例仅支持标准系统上运行，支持设备：华为手机。
2.HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
3.DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
4.HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。

