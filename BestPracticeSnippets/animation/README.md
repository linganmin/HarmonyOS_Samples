# 布局优化指导
## 介绍
本例介绍了5种优化手段，分别为使用系统提供的动画接口、使用图形变换属性变化组件布局、参数相同时使用同一个animateTo、多次animateTo时统一更新状态变量、使用renderGroup。通过这些优化手段的单个使用或组合使用，可以对动画帧率、应用卡顿等方面带来优化，提升性能和用户体验。

## 预览效果

|            使用系统提供的动画接口            |           使用图形变换属性变化组件            |        参数相同时使用同一个animateTo        |
|:---------------------------------:|:---------------------------------:|:---------------------------------:|
|    ![image](screenshots/1.gif)    |    ![image](screenshots/2.gif)    |    ![image](screenshots/3.gif)    |

## 工程目录
``` 
├──entry/src/main/ets                                   // 代码区
│  ├──entryability
│  │  └──EntryAbility.ets                               // 程序入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  └──pages             
│     ├──CustomAnimation.ets                            // 自定义动画
│     ├──ExplicitAnimateTo.ets                          // 显式动画实现按键缩放
│     ├──IconItem.ets                                   // Icon组件
│     ├──ImageAnimation.ets                             // 改变布局属性
│     ├──MultipleProperties.ets                         // 参数相同时使用同一个animateTo
│     ├──PropertyAnimateTo.ets                          // 属性动画实现按键缩放
│     ├──RenderGroup.ets                                // 使用RenderGroup
│     ├──UpdateMultipleProperties.ets                   // 在多个animateTo之间更新状态变量        
│     └──Index.ets                                      // 首页                              
└──entry/src/main/resources                             // 应用资源目录
```

## 相关权限
无

## 约束与限制
* 本示例仅支持标准系统上运行，支持设备：华为手机。

* HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

* DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

* HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。

## 下载

如需单独下载本工程，执行如下命令：
```
git init
git config core.sparsecheckout true
echo animation/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```