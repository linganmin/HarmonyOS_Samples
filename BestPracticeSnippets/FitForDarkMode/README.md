# 实现深色模式功能

### 简介

本示例采用深色模式适配相关技术，确保应用在系统深浅色模式切换时界面效果美观自然，实现颜色资源适配、媒体资源适配、状态栏适配等。应用内还提供用户可控的深浅色模式开关，满足用户个性化需求，实现应用在不同模式下的深浅色切换。

### 相关权限

不涉及

### 约束与限制

1.本示例仅支持标准系统上运行，支持设备：华为手机。

2.HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3.DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4.HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。

### 下载

如需单独下载本工程，执行如下命令：
```
git init
git config core.sparsecheckout true
echo FitForDarkMode/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/BestPracticeSnippets.git
git pull origin master
```