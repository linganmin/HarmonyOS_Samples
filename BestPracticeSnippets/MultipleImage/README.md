# **多图片合集**
## 介绍
基于Swiper组件和自定义指示器实现多图片合计功能。

在短视频平台上，经常可以见到多图片合集。它的特点是：由多张图片组成一个合集，图片可以自动进行轮播，也可以手动去进行图片切换。图片下方的进度条
会跟随图片的切换而切换。

多图片合集展示效果是一个常见的UI效果：
* 当作品自动播放时，图片可自动切换，下方进度条缓慢增长，且进度与该图片停留时间匹配。
* 当作品手动播放时，下方进度条会根据图片切换改变为未完成进度状态或已完成进度状态。

## 预览效果
![](./screenshots/device/image.gif)
## 工程目录
``` 
├──entry/src/main/ets                                   // 代码区
│  ├──common
│  │  └──CommonConstants.ets                            // 常量
│  ├──entryability
│  │  └──EntryAbility.ets                               // 程序入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  ├──pages                              
│  │  └──Index.ets                                      // 多图片合集页
│  └──utils.ets
│     └──DataSource.ets                                 // 图片数据资源类
└──entry/src/main/resources                             // 应用资源目录
``` 
## 使用说明
运行应用后，不滑动屏幕时，图片自动轮播，且下方进度条缓慢增长至已完成状态，播放完成时，会继续循环播放。

滑动屏幕时，图片跟随滑动方向而进行切换，此时会关闭自动轮播和循环播放的效果，且下方进度条瞬间增长至已完成状态。
## 实现说明
上面图片的轮播部分使用Swiper组件实现。

下面的指示器，需要关闭原生指示器，自定义指示器（进度条）来实现。

进度条可以使用Row容器来实现对应的效果，通过层叠布局方式将Row容器叠放在一起。进度条缓慢增长，可以通过animation属性来设置对应的动画效果。进度条的完成态和未完成态的实现，
只需要设置对应的背景颜色即可。

## 相关权限
无

## 约束与限制
* 本示例仅支持标准系统上运行，支持设备：华为手机。

* HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

* DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

* HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。

## 下载

如需单独下载本工程，执行如下命令：
```
git init
git config core.sparsecheckout true
echo MultipleImage/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```