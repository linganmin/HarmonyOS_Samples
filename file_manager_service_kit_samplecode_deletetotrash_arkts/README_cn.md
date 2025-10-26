# 基于文件管理服务实现删除文件到回收站（ArkTS）

## 简介
本示例使用File Manager Service Kit(文件管理服务)提供的API，实现选择文件删除到回收站的，供您参考使用。

## 预览图
![](./screenshots/device/indexPage_cn.gif)

## 工程目录
```
└──entry/src/main                      // 代码区
   ├──ets
   │  ├──entryability 
   │  │  └──EntryAbility.ets           // 程序入口类
   │  └──pages
   │     └──Index.ets                  // 主界面
   └──resources                        // 资源文件目录
```
## 使用说明
1. 使用DevEco Studio打开工程目录；
2. 在build-profile.json5的signingConfigs中配置签名信息；
3. 在HarmonyOS设备上运行示例代码。
4. 点击‘选择文件并删除’按钮，选择相应的文件即可删除文件到回收站。


## 具体实现
在@kit.FileManagerServiceKit中定义了文件管理服务的接口API，示例接口如下：


```
    /**
     * Delete file or directory to trash.
     *
     * @param { string } uri - File or directory to delete.
     * @returns { Promise<string> } - Uri of file or directory in trash.
     * @throws { BusinessError } 401 - Parameter error.
     * @throws { BusinessError } 1014000001 - Operation not permitted.
     * @throws { BusinessError } 1014000002 - No such file or directory.
     * @throws { BusinessError } 1014000003 - No space left on device.
     * @throws { BusinessError } 1014000004 - System inner fail.
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @since 5.0.5(17)
     */
    function deleteToTrash(uri: string): Promise<string>;
    
```

业务使用时，需要导入相应模块，使用 import { fileManagerService } from '@kit.FileManagerServiceKit' 引入。
具体可参考 [entry\src\main\ets\pages\Index.ets](./entry/src/main/ets/pages/Index.ets) 文件。

## 约束与限制
1. 本示例仅支持标准系统上运行，支持设备：华为手机、平板和PC/2in1。
2. HarmonyOS系统：HarmonyOS 5.0.5 Release。
3. DevEco Studio版本：DevEco Studio 5.0.5 Release。
4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。



