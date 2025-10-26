# 实现底部抽屉滑动效果

### 介绍

本示例介绍了利用List实现底部抽屉滑动效果场景，使用RelativeContainer和Stack布局，将界面沉浸式（全屏）显示，实现地图拖动功能，开发者可以使用底部抽屉滑动效果。

### 效果图预览

![](screenshots/device/BottomDrawerSlideCase.gif)

##### 使用说明

1. 向上滑动底部列表，支持根据滑动距离进行分阶抽屉式段滑动。

### 具体实现

1. 本示例使用RelativeContainer和Stack布局，实现可滑动列表在页面在底部，且在列表滑动到页面顶部时，显示页面顶部标题栏。
2. 通过对List设置onTouch属性，记录手指按下和离开屏幕纵坐标，判断手势是上/下滑。
3. 根据手指滑动的长度对列表高度进行改变。
4. 在手指滑动结束离开屏幕后，通过判断此时列表高度处于哪个区间，为列表赋予相应的高度。

## 工程目录

```
├──entry/src/main/ets                         // 代码区
│  ├──constants
│  │  └──CommonConstants.ets                  // 公共常量
│  ├──entryability
│  │  └──EntryAbility.ets       
│  ├──model
│  │  └──CommonModel.ets                      // 公共实体类       
│  ├──pages
│  │  └──BottomDrawerSlideCase.ets            // 首页     
│  ├──utils
│  │  ├──ArrayUtil.ets                        // 数组工具类
│  │  ├──GlobalContext.ets                    // 变量工具类
│  │  ├──Logger.ets                           // 日志文件
│  │  ├──SettingItem.ets                      // 图片实体类
│  │  └──WindowModel.ets                      // 窗口管理
│  └──view
│     └──ComComponent.ets                     // 公用子组件
└──entry/src/main/resources                   // 应用资源目录
```


### 相关权限

不涉及。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。