# 折叠屏开发实践样例代码工程

### 简介
本示例实现折叠屏上的多种常见功能，如悬停、折痕区避让、沉浸浏览等。

### 工程目录
```
├──entry/src/main/ets                            // 代码区
│  ├──entryability
│  │  └──EntryAbility.ets                        // 本地启动ability 
│  ├──modules
│  │  ├──AsideColum.ets                           
│  │  ├──Crease.ets                           
│  │  ├──Folder.ets                        
│  │  ├──NavigationComponent.ets                     
│  │  ├──PinchImage.ets    
│  │  ├──PinchText.ets 
│  │  ├──PopupComponent.ets
│  │  ├──Screen.ets 
│  │  ├──Screen2.ets
│  │  ├──Scroll.ets 
│  │  ├──ScrollParent.ets
│  │  └──Web.ets                       
│  ├──pages
│  │  └──Index.ets                       
│  └──utils
│     ├──source_add1.ets           
│     ├──source_add2.ets             
│     ├──source_add3.ets               
│     └──WindowUtil.ets                    
└──entry/src/main/resources                      // 资源文件目录
```

### 使用说明
1. 按照个人需求在Index.ets中调用相关功能并运行。


### 约束与限制
1. 本示例仅支持标准系统上运行，支持设备：华为手机。
2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。

### 下载

如需单独下载本工程，执行如下命令：
```
git init
git config core.sparsecheckout true
echo FoldableGuilde/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```