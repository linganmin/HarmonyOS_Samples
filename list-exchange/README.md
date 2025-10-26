# 列表项交换案列

### 介绍

本示例介绍了如何通过组合手势结合List组件，来实现对List组件中列表项的交换排序。

### 效果预览

本示例在预览器中的效果：

![running](screenshots/Devices/image1.gif)


使用说明：

1.可以在预览器中查看页面效果，也可在对应设备上查看页面效果。

### 工程目录

```
├──entry/src/main/ets                              // 代码区
│  ├──constants                                  
│  │  └──CommonConstants.ets                       // 常用常量
│  ├──entryability  
│  │  └──EntryAbility.ets 
│  ├──pages                             
│  │  └──Index.ets                                 // 首页 
│  ├──utils
│  │  └──Logger.ets                                // 日志打印类       
│  └──viewModel
│     ├──AttributeModifier.ets                     // 列表样式类
│     ├──ListExchangeCtrl.ets                      // 列表行为控制类
│     └──ListInfo.ets                              // 列表项信息类    
└──entry/src/main/resources                        // 应用资源目录

```

### 具体实现


本示例通过组合手势：长按、拖动，以及拖动的距离判断列表项是否需要交换，并使用ListItem组件的swipeAction属性设置划出的删除组件。



### 相关权限

不涉及。

### 依赖

不涉及。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。
