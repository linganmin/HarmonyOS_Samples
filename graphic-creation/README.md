# 基于AI能力实现图文内容高效编创

### 简介

本示例展示如何在图文编辑中接入HarmonyOS特性，包括照片选取、HD
Vivid展示、图片AI识别文字与抠图、MovingPhoto拍摄、跨端操作等图文流转功能，适用于社交类应用，并提供详细技术实现。

### 效果展示

![](./screenshots/screen1.gif)

### 使用说明

1. 在平板和手机上都要安装该应用，主要用于测试图文流转能力。
2. 当前跨端能力仅能平板调用手机，无法实现手机调用平板。
3. 为了实现跨端拍照、跨端相册、图文流转能力，两台设备需要登录相同账号，连接WIFI网络，连接同一个局域网可以提高接续数据传输速度，同时开启蓝牙。
4. AI辅助图文内容高效编创，体现以下能力：系统Picker照片选取，HDR
   Vivid图片展示，图片AI智能识别文字及抠图，MovingPhoto拍摄，跨端拍照、扫描、相册选取，图文流转续编能力。

### 工程目录

```
├──ets
│  ├──common
│  │  └──CommonConstants.ets             // 常量配置
│  ├──entryability
│  │  └──EntryAbility.ets
│  ├──model
│  │  ├──CameraService.ets               // 相机服务
│  │  ├──ContentInfo.ets                 // 接续资产对象
│  │  ├──SelectedDataSource.ets          // picker photo后的数据源
│  │  └──WaterFlowDataSource.ets         // 首页瀑布流的数据源
│  ├──pages
│  │  ├──GraphicCreationPage.ets         // 图文编辑发布页
│  │  ├──ImageEditPage.ets               // 图片选择编辑页与自定义相机切换
│  │  ├──Index.ets                       // 主页
│  │  ├──PreviewMovingPhotoPage.ets      // 预览拍摄的Moving Photo
│  │  └──PreviewPhotoPage.ets            // 预览普通拍摄图片
│  ├──utils
│  │  ├──BreakpointSystem.ets            // 断点监听
│  │  ├──DataUtils.ets                   // 数据转换工具
│  │  ├──FileUtils.ets                   // 文件处理工具
│  │  ├──Logger.ts                       // 日志
│  │  └──UIUtils.ets                     // UI设置工具
│  └──view
│     ├──CameraView.ets                  // 相机视图
│     ├──FlowItemView.ets                // 瀑布流卡片组件
│     ├──HomeView.ets                    // 主页视图
│     ├──ListAddPictureView.ets          // 添加图片列表视图
│     ├──NavigationBarView.ets           // 自定义主页导航栏组件
│     ├──SearchTitleView.ets             // 主页标题搜索视图
│     ├──SelectedEditeView.ets           // 选择编辑图片视图
│     └──TitleBackView.ets               // 带返回标题组件
└──resources
```

### 实现思路

参考多个社交通讯类应用的编辑的图文编创发布环节，将传统发布流程结合HarmonyOS特性能力，给出技术方案，实现场景落地。

### 相关权限

1、需要申请以下权限：网络权限、定位相关权限、相机权限、分布式设备管理权限、读写权限、麦克风权限。

```
ohos.permission.DISTRIBUTED_DATASYNC
ohos.permission.APPROXIMATELY_LOCATION
ohos.permission.LOCATION
ohos.permission.INTERNET
ohos.permission.LOCATION_IN_BACKGROUND
ohos.permission.CAMERA
ohos.permission.MICROPHONE
ohos.permission.READ_IMAGEVIDEO
ohos.permission.WRITE_IMAGEVIDEO
```

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机、华为平板。
2. HarmonyOS系统：HarmonyOS 5.0.0 Release及以上。
3. DevEco Studio版本：DevEco Studio 5.0.0 Release及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.0.0 Release SDK及以上。