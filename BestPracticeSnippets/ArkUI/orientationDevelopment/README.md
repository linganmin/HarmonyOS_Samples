# 多设备同源代码工程

## 介绍

本示例为窗口方向与多设备功能开发同源代码工程，包含最佳实践文档中包含的推荐使用方法的样例代码。工程本身不具备实际功能，开发者请直接阅读文档结合源码来理解多设备功能开发。

## 效果预览

不涉及。

## 工程目录

```
entry/src/main/
├──configautorotation                         // 窗口自动旋转
├──configlandscapeauto                        // 窗口横屏
├──configportrait                             // 窗口竖屏
├──ets                                        // 主目录
└──resources                                  // 资源目录
```

## 具体实现

不涉及。

## 相关权限

不涉及。

## 依赖

不涉及。

## 约束与限制

1.本示例仅支持标准系统上运行，支持设备：华为手机。

2.HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3.DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4.HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。

## 下载

如需单独下载本工程，执行如下命令：
```
git init
git config core.sparsecheckout true
echo orientationDevelopment/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```