## 基于RCP实现文件上传下载功能

### 介绍

本示例基于Remote Communication Kit远场通信服务，使用post、fetch、downloadToFile等方法实现相册的文件上传下载、文件分片下载、断点续传、后台文件上传下载功能。为开发者提供基于RCP上传下载各种场景的开发指导。

### 效果预览

![](./screenshots/devices/home.png)

使用说明：
1. 环境配置：根据[文件服务器配置](./service/README.md)配置本地文件服务器。
2. 相册图片上传与下载：页面展示文件服务器中的图片列表，选中某个文件，点击下载，下载成功后在相册查看。点击上传拉起相册，选择图片后上传，上传成功更新列表。
3. 文件断点续传：选中某个文件，点击下载，按钮变为暂停，再点击下载开始继续下载。
4. 其他页面交互逻辑与1相同。

### 工程目录

```
├──entry/src/main/ets/                              
│  ├──components             
│  │  ├──CustomList.ets                             // 自定义列表组件
│  │  ├──ProgressButton.ets                         // 带进度显示的按钮组件
│  │  └──SelectionList.ets                          // 选择列表组件
│  ├──entryability
│  │  └──EntryAbility.ets                           // 程序入口类
│  ├──constants
│  │  └──Constants.ets                              // 常量文件
│  ├──pages             
│  │  ├──AlbumImageTrasfer.ets                      // 相册图片上传下载页面
│  │  ├──BackgroundFileTransfer.ets                 // 后台文件上传下载页面
│  │  ├──ChunkedFileTransfer.ets                    // 文件分片下载页面
│  │  ├──Index.ets                                  // 应用首页
│  │  └──ResumableFileTransfer.ets                  // 断点续传页面
│  ├──service             
│  │  ├──Env.ets                                    // 服务端环境配置文件
│  │  ├──FileRequest.ets                            // 文件上传下载请求接口模块
│  │  ├──Formatter.ets                              // 服务端与客户端数据格式化模块
│  │  ├──Interceptor.ets                            // 请求拦截相关类
│  │  └──Model.ets                                  // 服务端与客户端数据类型定义
│  └──utils
│     ├──CommonUtil.ets                             // 常用工具函数模块    
│     ├──LocalFileUtil.ets                          // 本地文件工具函数模块                        
│     └──Logger.ets                                 // 日志类
└──entry/src/main/resources                         // 应用静态资源目录
```

### 具体实现

1. 使用[Remote Communication Kit](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/remote-communication-rcp)相关能力。

### 相关权限

- ohos.permission.INTERNET：允许应用在上传下载场景中访问网络
- ohos.permission.GET_NETWORK_INFO：允许应用获取数据网络信息
- ohos.permission.KEEP_BACKGROUND_RUNNING: 允许Service Ability在后台持续运行

### 依赖

[文件服务器配置](./service/README.md)。

### 约束与限制

1.本示例仅支持标准系统上运行，支持设备：华为手机。

2.HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3.DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4.HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。

