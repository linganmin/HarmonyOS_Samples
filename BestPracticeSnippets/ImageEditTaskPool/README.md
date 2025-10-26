# 基于TaskPool实现图片编辑功能

### 简介
本示例基于TaskPool多线程并发方案，实现图片编辑功能，包含图片裁剪、图片旋转、色域调节（亮度、透明度、饱和度）、图片重置，图片保存功能，开发者使用TaskPool线程接口，把任务方法、参数传入execute接口，系统会自动根据任务量进行扩容及缩容，进行线程调度，提升代码运行效率，降低任务运行耗时。

### 效果预览
![image](screenshots/device/ImageEditTaskPool_CN.gif)

### 工程目录
```
├──entry/src/main/ets                            // 代码区
│  ├──common                         
│  │  └──constant
│  │     └──CommonConstants.ets                  // 公共常量类
│  ├──entryability
│  │  └──EntryAbility.ets                        // 本地启动ability           
│  ├──pages
│  │  └──HomePage.ets                            // 本地主页面    
│  ├──utils
│  │  ├──AdjustUtil.ts                           // 调节工具类
│  │  ├──CropUtil.ets                            // 裁剪工具类
│  │  ├──DecodeUtil.ets                          // 解码工具类
│  │  ├──EncodeUtil.ets                          // 编码工具类
│  │  └──OpacityUtil.ets                         // 透明度调节工具类
│  ├──view
│  │  ├──AdjustContentView.ets                   // 色域调整视图
│  │  ├──CommBackgroundIcon.ets                  // 公共带背景色icon
│  │  ├──newBuffer1.ets                          
│  │  ├──TitleBar.ets                            // 顶部工具栏
│  │  └──WorkerPort.ets
│  └──viewmodel
│     ├──IconListViewModel.ets                   // icon数据
│     ├──MessageItem.ets                         // 多线程封装消息
│     ├──OptionViewModel.ts                      // 图片处理封装类
│     └──RegionItem.ets                          // 区域封装类
└──entry/src/main/resources                      // 资源文件目录
```

### 使用说明
1. 按照个人需求点击按钮进行裁剪及调节。
2. 完成之后可按需保存图片。
3. 说明： 当前亮度调节、透明度调节、饱和度调节是在UI层面实现的，未实现细节优化算法，只做简单示例。调节后的图片会有色彩上的失真。

### 具体实现
1. 图片裁剪具体实现步骤：通过pixelMap获取图片尺寸，为后续裁剪做准备。 确定裁剪的方式，当前裁剪默认有原图、1:1、4:3、16:9。 最后通过pixelMap调用接口crop()进行裁剪操作。
2. 图片旋转具体实现步骤：确定旋转方向，当前支持顺时针和逆时针旋转。 最后通过pixelMap调用接口rotate()进行旋转操作。
3. 亮度调节具体实现步骤：先将pixelMap转换成ArrayBuffer，把生成好的ArrayBuffer发送到worker线程，再计算好的ArrayBuffer发送回主线程。最后把ArrayBuffer写入pixelMap，刷新UI。
4. 透明度调节具体实现步骤：先获取pixelMap，再调用接口opacity()进行透明度调节。
5. 饱和度调节具体实现步骤：将pixelMap转换成ArrayBuffer，把生成好的ArrayBuffer发送到worker线程，对每一个像素点的饱和度按倍率计算。然后再把计算好的ArrayBuffer发送回主线程。 最后将ArrayBuffer写入pixelMap，刷新UI。

### 相关权限
- ohos.permission.WRITE_IMAGEVIDEO

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
echo ImageEditTaskPool/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```