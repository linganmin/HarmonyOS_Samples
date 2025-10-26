# 手势事件冲突解决方案

### 介绍

本代码示例展示了多个组件嵌套时同时绑定手势事件，或者同一个组件同时绑定多个手势等场景下，手势冲突问题的解决。

### 效果说明

* GesturesConflictScene1：Scroll组件和List组件嵌套滑动冲突解决方案，Scroll组件和List组件实现整体滑动。
* GesturesConflictScene2：单击手势和双击手势互斥执行，优先响应单击，无法响应双击事件。   
* GesturesConflictScene2A：单击手势和双击手势并行执行，单击和双击事件同时执行。      
* GesturesConflictScene3：系统手势覆盖自定义手势，长按Image组件，Image组件放大，自定义长按手势不会触发。
* GesturesConflictScene3A：自定义手势使用优先级手势priorityGesture，长按Image组件，Image组件无变化，自定义长按手势触发，弹出Toast提示。
* GesturesConflictScene4：手势事件透传，在层的红色组件上左右滑动，弹出Toast提示。
* GesturesConflictScene5：Button1使用事件独占属性.monopolizeEvents(true)后，一个手指按住Button1，另一个手指点击Button2，不会出发Button2的点击事件。
* GesturesConflictScene6：长按红色区域不会触发拖拽效果。
* GesturesConflictScene7：Scroll组件嵌套Scroll组件实现联合滚动。
* WebScrollDemo：Web组件和Scroll组件嵌套，红色区域的Text组件和Web组件一起滚动。

#### 使用说明

安装运行应用，进入应用首页，点击不同的按钮跳转到不同的手势场景示例。

## 工程目录

``` 
├──entry/src/main/ets                          
│  ├──entryability
│  │  └──EntryAbility.ets               // 程序入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets         // 数据备份恢复类
│  └──pages        
│     ├──GesturesConflictScene1.ets     // 滚动容器嵌套滚动容器事件冲突
│     ├──GesturesConflictScene2.ets     // 使用组合手势同时绑定多个同类型手势冲突解反例   
│     ├──GesturesConflictScene2A.ets    // 使用组合手势同时绑定多个同类型手势冲突解正例 
│     ├──GesturesConflictScene3.ets     // 系统手势和自定义手势之间冲突反例
│     ├──GesturesConflictScene3A.ets    // 系统手势和自定义手势之间冲突正例
│     ├──GesturesConflictScene4.ets     // 手势事件透传
│     ├──GesturesConflictScene5.ets     // 多点触控场景下手势冲突
│     ├──GesturesConflictScene6.ets     // 动态控制自定义手势是否响应
│     ├──GesturesConflictScene7.ets     // 父组件如何管理子组件手势
│     ├──Index.ets                      // 应用首页
│     └──WebScrollDemo.ets              // Web组件和Scroll组件嵌套示例
└──entry/src/main/resources             // 应用资源目录
```

### 相关权限

* 允许使用Internet网络：ohos.permission.INTERNET。

## 约束与限制

* 本示例仅支持标准系统上运行，支持设备：华为手机。
* HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
* DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
* HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。

### 下载

如需单独下载本工程，执行如下命令：
```
git init
git config core.sparsecheckout true
echo GesturesConfictPractice/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```