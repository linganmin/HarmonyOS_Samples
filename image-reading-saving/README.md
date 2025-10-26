# 基于Media Library Kit实现图片读取与保存

## 介绍

本示例介绍了如何使用安全控件、授权弹窗、以及获取系统权限的方式实现图片的读取与保存功能。

## 效果预览

<img src="./screenshots/device/preview.gif" width="320">

## 工程目录

```
├──entry/src/main/ets                     // 代码区
│  ├──entryability
│  │  └──EntryAbility.ets                 // 程序入口类
│  ├──component                           // 公共组件
│  │  ├──ReadBtn.ets                      // 读取组件
│  │  └──WriteBtn.ets                     // 写入组件
│  ├──pages
│  │  └──Index.ets                        // 应用主界面
│  ├──view
│  │  ├──PhotoPicker.ets                  // 使用PhotoPicker访问相册视图
│  │  ├──PhotoViewPicker.ets              // 使用PhotoViewPicker访问相册视图
│  │  ├──Preview.ets                      // 预览界面
│  │  ├──ReadView.ets                     // 读取视图界面
│  │  └──WriteView.ets                    // 写入视图界面
│  └──utils                               // 工具类
│     └──AuthorizationTools.ets           // 授权工具类
└──entry/src/main/resources               // 应用静态资源目录
```

## 使用说明

1. 主界面点击三种读取相册的方式任意一种，选择图片。
2. 预览界面查看图片相关信息，随后点击保存按钮，跳转到保存界面。
3. 保存界面点击三种保存方式任意一种，保存到相册。

## 实现说明

1. 通过[PhotoPickerComponent](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ohos-file-photopickercomponent)组件实现PhotoPicker读取图片。
2. 通过[PhotoViewPicker](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-photoaccesshelper#photoviewpicker)的select属性拉起选择界面，实现PhotoViewPicker读取图片。
3. 通过[requestPermissionsFromUser](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-abilityaccessctrl#requestpermissionsfromuser9)调用系统授权能力，实现通过申请媒体库权限读取图片。
4. 通过[SaveButton](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/ts-security-components-savebutton-V5)安全组件可以临时获取存储权限，结合[packToFile](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkts-apis-image-imagepacker#packtofile11)写入文件实现安全组件保存图片。
5. 通过[showAssetsCreationDialog](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkts-apis-photoaccesshelper-photoaccesshelper#showassetscreationdialog12)弹出授权弹窗结合[copyFile](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-fileio#fileiocopyfile)写入文件实现授权弹窗保存图片。
6. 通过[requestPermissionsFromUser](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-abilityaccessctrl#requestpermissionsfromuser9)调用系统授权能力，结合[packToFile](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-image#packtofile11)写入文件实现通过申请媒体库权限保存图片。

## 相关权限

* ohos.permission.READ_IMAGEVIDEO：允许读取图片权限。
* ohos.permission.WRITE_IMAGEVIDEO：允许写入图片权限。

## 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。
2. HarmonyOS系统：HarmonyOS 5.1.1 Release及以上。
3. DevEco Studio版本：DevEco Studio 5.1.1 Release及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.1.1 Release SDK及以上。
