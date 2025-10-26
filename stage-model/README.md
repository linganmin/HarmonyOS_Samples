# 基于AbilityKit实现Stage模型Ability管理的相关能力

### 介绍

本示例基于AbilityKit实现Stage模型Ability管理的相关能力，实现跳转AbilityContent页面、AbilityAccessCtrl页面、Window页面等功能。

### 效果预览

| 主页                                        |
|-------------------------------------------|
| ![](./screenshots/device/stage_mode.png) |

使用说明：

1.点击**AbilityContext**按钮，跳转到AbilityContext页面，测试UIAbilityContext相关内容；

2.点击**AbilityAccessCtrl**按钮，跳转到AbilityAccessCtrl页面，测试abilityAccessCtrl相关内容；

3.点击**Window**按钮，跳转到Window页面,测试窗口相关内容；

### 工程目录

```
├──entry/src/main/ets/
│  ├─Application
│  │  └──MyAbilityStage.ts                   
│  ├─feature
│  │  ├──AbilityAccessCtrlController.ts      // 访问控制             
│  │  ├──AbilityContextController.ts         // Context控制                    
│  │  └──WindowController.ts                 // 窗口管理                  
│  ├─JumpAbility
│  │  └──JumpAbility.ts                      // 跳转
│  ├─MainAbility
│  │  └──MainAbility.ts                      
│  ├─pages
│  │  ├──component
│  │  │  ├──IndexTitleBar.ets                // 单个页面标题组件
│  │  │  └──PublicTitleBar.ets               // 通用的标题组件
│  │  ├──AbilityAccessCtrlPage.ets           // 程序访问控制
│  │  ├──AbilityContextPage.ets              // 提供允许访问特定于ability的资源的能力
│  │  ├──Index.ets
│  │  ├──TestPage.ets
│  │  └──WindowPage.ets                      // 窗口               
│  └──util
│     └──Logger.ts    
└──entry/src/main/resources                              
```

### 具体实现

Stage模型的设计基于如下三个出发点：

- **应用的能力与系统总体功能和功耗的平衡**

  在系统运行过程中，前台应用的资源占用会被优先保障，与此同时由于应用能力不同而产生的功耗，也需要符合系统整体功耗的要求。Stage模型通过Ability与UI分离、严格的后台管控、基于场景的服务机制及单进程模型来达成这种应用能力与整体系统功耗的平衡。

- **原生支持组件级的迁移和协同**

  HarmonyOS是原生支持分布式的操作系统，应用框架需要从架构设计上使得组件更易于实现迁移和协同。Stage模型通过Ability与UI分离及UI展示与服务能力合一等模型特性，实现这一设计目标。

- **支持多设备和多窗口形态的特点**

  为了支持多种设备形态和更易于实现多种不同的窗口形态，需要组件管理服务和窗口管理服务在架构层面上是解耦的，从而方便裁剪，更有利于定制不同的窗口形态。Stage模型通过重新定义了Ability生命周期定义和设计组件管理服务和窗口管理服务的单向依赖解决这一问题。

  本示例主要展示Stage模型与FA模型的区别，分别从AbilityContext、Window、abilityAccessCtrl等模块进行介绍。

  **AbilityContext**：AbilityContext是Ability的上下文环境，继承自Context。AbilityContext模块提供允许访问特定于ability的资源的能力，包括对Ability的启动、停止的设置、获取caller通信接口、拉起弹窗请求用户授权等。在使用AbilityContext的功能前，需要通过Ability子类实例获取。

  **Window**：窗口提供管理窗口的一些基础能力，包括对当前窗口的创建、销毁、各属性设置，以及对各窗口间的管理调度。

  **abilityAccessCtrl**：程序访问控制提供程序的权限管理能力。

### 相关权限

不涉及。

### 依赖

不涉及。

### 约束与限制

1.本示例仅支持标准系统上运行，支持设备：华为手机。

2.HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3.DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4.HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。
