## 基于Grid的嵌套混合布局

### 介绍

本示例介绍了两种嵌套混合布局，一种是通过Grid组件与List组件实现嵌套混合布局，另一种是Grid组件与Swiper组件实现嵌套混合布局。

### 效果预览

本示例在预览器中的效果：
#### 场景一：Grid与List相互嵌套
![running](screenshots/Devices/image1.gif)

#### 场景二：Grid与Swiper相互嵌套
![running](screenshots/Devices/image2.gif)

使用说明：

1.可以在预览器中查看页面效果，也可在对应设备上查看页面效果。

### 工程目录

```
├──entry/src/main/ets                              // 代码区
│  ├──constants                                  
│  │  ├──CommonConstants.ets                       // 常用常量
│  │  └──ListDataConstants.ets                     // 列表数据常量
│  ├──entryability  
│  │  └──EntryAbility.ets 
│  ├──model  
│  │  ├──GridListDataSources.ets                   // 场景一Grid组件数据
│  │  ├──WaterFlowDataSource.ets                   // 瀑布流数据
│  ├──pages  
│  │  ├──GridNestListIndex.ets                     // Grid组件与List组件混合布局页
│  │  ├──GridNestSwiperIndex.ets                   // Grid组件与Swiper组件混合布局页                             
│  │  └──Index.ets                                 // 首页 
│  └──view
│     ├──GridComponent.ets                         // 场景一竖直方向的List子组件
│     ├──GridItemComponent.ets                     // GridItem子组件
│     └──MenuItemComponent.ets                     // 场景二Swiper子组件        
└──entry/src/main/resources                        // 应用资源目录

```

### 具体实现

#### 场景一：Grid嵌套List混合布局

* 通过合理设置各个组件高度，当主页面滑动到底部时，实现水平list组件吸顶。
* 使用两个scroller控制竖直、水平方向两个列表，实现两个列表之间的联动。

#### 场景二：Grid嵌套Swiper混合布局

* 滑动Swiper时，动态修改Swiper组件高度。


### 相关权限

不涉及。

### 依赖

不涉及。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。
