# 基于多网并发能力实现网络加速

## 项目简介
本示例基于多网并发能力，通过系统返回的多个网络通路，帮助开发者在上传、下载大吞吐场景下实现网络加速的功能。

## 效果预览
| 下载                                                      | 上传                                     | 
|---------------------------------------------------------|----------------------------------------|
|<img src="screenshots/device/download.webp" width="320"/> |<img src="screenshots/device/upload.webp" width="320"/> | 

## 注意事项
1. 本示例无法直接运行，如需正常使用下载功能，请开发者在[CommonConst.ets](./entry/src/main/ets/common/CommonConst.ets)中配置下载地址**DOWN_URL1**和**DOWN_URL2**，并且这两个地址均需要服务端支持**HEAD**方法及**Range**字段。如需正常使用上传功能，则需要开发者在[CommonConst.ets](./entry/src/main/ets/common/CommonConst.ets)配置上传地址**UP_HOST**，并且确认[FilePartsUploadManager.ets](./entry/src/main/ets/viewmodel/upload/FilePartsUploadManager.ets)中的三个文件上传相关接口是否需要修改。因为文件分段上传通常为私有协议，此处给出示例代码的详解，供开发者理解和修改使用。<br>
   1. 第一步，首先会通过初始化方法**initMultiPartUpload**告知服务端初始化，此时传递文件路径和文件名称，如果成功，则会返回指定的**InitiateMultipartUpload**数据格式；<br>
   2. 第二步，分段上传文件方法**uploadSegment**，示例代码使用指定的网络，同时搭配第一步返回的初始化结果上传了文件分段的内容，并记录了所有返回的分段结果**UploadPartResult**；<br>
   3. 第三步，通知服务端合并文件，此处会上传第二步骤的所有**UploadPartResult**。如果开发者在以上三个步骤中有不同的要求，例如返回的数据格式不同、网络请求的Header不同等问题，请自行修改使用。<br>
2. 打开应用的 "多网络并发传输" 开关，可能会因为各种原因导致打开失败，例如额度用尽、多网并发能力不支持等，开发者可参考[多网并发错误码](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/networkboost-nethandover#section8508131819279)排查。

## 使用说明
1. 下载本示例代码导入到IDE，打开AppScope->app.json文件，修改bundleName为您自己的应用名称。
2. 参考[ACL的签名配置指导](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-signing#section157591551175916)
为第一步对应的bundleName的应用，申请带有"ohos.permission.LINKTURBO"权限的profile文件。
3. 使用IDE的File->Project Structure，找到Singing Configs选项卡，配置应用的签名信息。
4. 找到设备的系统设置->移动网络->网络加速->打开"允许使用移动数据加速网络"开关。
5. 编译安装应用后，"单文件分段上传"页面是可以使用多网络通路，将文件分段上传到云存储的功能，"多文件下载"页面是可以使用多网络通路的能力，同时下载2个文件。

## 工程目录
```
├──entry/src/main/ets
│  ├──common
│  │  └──CommonConst.ets                   // 常量类
│  ├──entryability
│  │  └──EntryAbility.ets                  // 程序入口类
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets            // 备份恢复类
│  ├──net
│  │  ├──NetBoostManager.ets               // 网络并发管理类
│  │  ├──NetConnectionManager.ets          // 网络通路获取
│  │  └──SocketClient.ets                  // Socket网络请求和下载文件使用
│  ├──pages
│  │  ├──DownloadPage.ets                  // 文件下载页面
│  │  ├──IndexPage.ets                     // 首页
│  │  └──UploadPage.ets                    // 单文件分段上传
│  ├──utils
│  │  ├──CommonUtils.ets                   // 常用工具类，例如Toast
│  │  ├──FileUtils.ets                     // 文件工具类
│  │  ├──HttpParser.ets                    // Http协议解析工具类
│  │  ├──PhotoUtils.ets                    // 图片工具类
│  │  └──XmlUtils.ets                      // Xml数据格式解析类
│  ├──viewmodel
│  │  ├──download
│  │  │  └──FileDownManager.ets            // 单文件下载管理类
│  │  └──upload
│  │     └──FilePartsUploadManager.ets     // 单文件分段上传管理类
│  └──view
│     ├──DownloadView.ets                  // 下载条目信息
│     ├──Titles.ets                        // 标题信息
│     └──UploadView.ets                    // 上传条目信息
└──entry/src/main/resources                // 应用静态资源目录
```

## 具体实现
1. 使用**multiPathStateChange**设置多网状态监听，后续主要是从这里拿到NetHandle多网通路对象。
2. 使用**requestMultiPath**发起多网并发，如果成功发起多网并发，则会触发第一步骤的**multiPathStateChange**回调，可以从该回调拿到NetHandle对象。
3. 通过第二步骤的NetHandle对象的**bindSocket**方法，将Socket绑定到对应的网络。
4. 使用第三步骤绑定指定网络通路的Socket对象访问网络。
5. 由于多网有限额限制，开发者可通过**getMultiPathQuotaStats**获取当前剩余配额信息，并且当不再使用多网通路的时候，建议通过**releaseMultiPath**及时释放多网通路。

## 相关权限
1. 允许应用使用网络：ohos.permission.INTERNET
2. 允许应用使用网络加速：ohos.permission.LINKTURBO
3. 允许应用获取数据网络信息：ohos.permission.GET_NETWORK_INFO

## 依赖
- 不涉及

## 约束与限制
1. 本示例仅支持标准系统上运行，支持设备：华为手机。
2. HarmonyOS系统：HarmonyOS 6.0.0 Beta5及以上。
3. DevEco Studio版本：DevEco Studio 6.0.0 Beta5及以上。
4. HarmonyOS SDK版本：HarmonyOS 6.0.0 Beta5 SDK及以上。