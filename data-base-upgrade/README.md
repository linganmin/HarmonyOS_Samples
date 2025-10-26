# 数据库的备份与恢复

### 介绍

本示例通过使用relationalStore模块，实现对于数据库的基本增删改查操作，并实现了数据库的备份与恢复功能，给开发者提供一个简单的数据库操作示例。


### 效果预览
![image](screenshots/device/DataBaseUpgrade.gif)

使用说明

1、使用下拉选择框的方式提供几个可添加的字段名，然后提示用户输入对应的字段值。

2、点击版本更新后，会拉取正在更新的进度条弹窗，当进度条100%前点击叉号取消，会事务性回滚导致下方用户信息不更新。

3、点击版本更新后，会拉取正在更新的进度条弹窗，当进度条达到100%后，会事务性提交并刷新下方用户信息并刷新备份数据库。

4、点击版本回退按钮，会查询备份数据库并恢复。

5、版本回退的背景是在数据库在执行出问题时，可以回退到上一个版本，所以版本回退仅能回退一个版本，但在有新的版本更新之后，即可进行新的回退。


### 工程目录
```
├──entry/src/main/ets/
│  ├──common
│  │  ├──constants
│  │  │  └──CommonConstants.ets             // 常量类
│  │  └──utils
│  │     ├──CommonUtils.ets                 // 文字弹窗实现类
│  │     ├──DBUtils.ets                     // 数据库操作类
│  │     └──Logger.ets                      // 日志打印类
│  ├──entryability
│  │  └──EntryAbility.ets                   // 程序入口类
│  ├──pages
│  │  └──Index.ets                          // 主页面
│  ├──view
│  │  └──ProgressDialog.ets                 // 进度条弹窗实现类
│  └──viewmodel
│     └──userInfo.ets                       // 用户信息类
└──entry/src/main/resources                 // 应用静态资源目录
```
### 具体实现

* 本示例的主要功能都基于关系型数据库。
* 添加字段值的操作主要基于executeSql。
* 关于数据库事务性的操作主要参考commit和rollback。
* 版本回退的实现主要利用对数据库的备份与恢复，在版本更新时，备份数据库，在版本回退时，恢复数据库。

### 相关权限

不涉及。

### 依赖

不涉及。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。
2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。