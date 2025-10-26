# 实现解压和压缩功能

### 介绍

本示例通过@ohos.zlib和@ohos.fileio接口，实现添加文件、解压和压缩文件功能，便于用户进行常见的文件解压操作。

### 效果预览

| 主页                               | 新建弹窗                               |
|----------------------------------|------------------------------------|
| ![](screenshots/device/main.png) | ![](screenshots/device/create.png) |

使用说明

1.点击屏幕右上角 **+** 按钮，弹出创建文件窗口；

2.输入文件名称、文件内容，并点击 **确定** 按钮来创建文件；

3.文件创建成功后，文件名称自动追加.txt后缀并在主页面列表会显示，同时文件的物理地址为/data/app/el2/100/base/ohos.samples.ziplib/haps/entry/files/，点击 **压缩** 按钮，提示“文件压缩成功”，并会在文件列表创建一个相同名称的.zip文件；

4.点击压缩文件后的 **解压** 按钮，提示“文件解压成功”，并会再次在文件列表创建一个同名文件夹。

### 工程目录

```
├──entry/src/main/ets/
│  ├──common
│  │  └──AddDialog.ets                    // 弹窗组件
│  ├──entryability
│  │  └──EntryAbility.ets                 // 程序入口文件
│  ├──model
│  │  ├──DataSource.ets                   // 懒加载文件
│  │  └──Logger.ets                       // 日志文件
│  └──pages
│     └──Index.ets                        // 首页，接口都在这里调用
└──entry/src/main/resources               // 应用静态资源目录
``` 

### 具体实现

* 添加文件、解压和压缩文件的接口都在首页调用，源码参考[Index.ets](entry/src/main/ets/pages/Index.ets)
  * 添加文件：通过调用fileio.openSync()创建文件并调用fileio.writeSync()向文件中写入内容；
  * 压缩文件：通过调用zlib.zipFile()压缩文件；
  * 解压文件：通过zlib.unzipFile解压文件。

### 相关权限

不涉及。

### 依赖

不涉及。

### 约束与限制

1.本示例仅支持标准系统上运行，支持设备：华为手机。

2.HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3.DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4.HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。
