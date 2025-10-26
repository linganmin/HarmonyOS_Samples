# super_fast_file_trans

## 简介

本项目是使用[super_fast_file_trans](https://gitcode.com/openharmony-sig/super_fast_file_trans)的三方库源码与Sample示例代码，Sample实现的是一个包含文件下载和文件上传的页面。
页面中展示的功能包括文件的下载/上传、暂停、继续、删除等。

## 下载功能预览

![](./screenshots/sfft_download.gif)

## 上传功能预览

![](./screenshots/sfft_upload.gif)

## 工程目录

```
├── library             # 网络库模块
├── entry               # Sample工程项目模块
│      └── src
│           └── main
│                 ├── ets
│                 │  ├── common
│                 │  │  └── CommonConstants.ets     # 公共常量类（需在此配置Sample所需的URL）
│                 │  ├── components
│                 │  │  ├── CustomMenuItem.ets      # Navigation菜单项组件
│                 │  │  ├── DownloadItem.ets        # 下载项组件
│                 │  │  └── UploadItem.ets          # 上传项组件
│                 │  ├── entryability
│                 │  │  └── EntryAbility.ets
│                 │  ├── entrybackupability
│                 │  │  └── EntryBackupAbility.ets
│                 │  ├── model
│                 │  │  └── FileItem.ets            # 文件项
│                 │  ├── pages
│                 │  │  └── Index.ets               # 首页面
│                 │  ├── util
│                 │  │  └── MemoryTool.ets          # 内存工具类
│                 │  └── view
│                 │     ├── DownloadView.ets        # 下载视图类
│                 │     └── UploadView.ets          # 上传视图类
│                 ├── module.json5
│                 └── resources
│                    └── rawfile                    # 资源管理
│                        ├── client.pem             # 客户端证书（需自行添加）
│                        └── server.pem             # 服务端证书（需自行添加）
└── README.md # 使用方法
```

## 使用super_fast_file_trans库的关键代码
1. 使用super_fast_file_trans三方库实现文件下载页关键代码。

    a.下载任务信息管理。

    ```typescript
    import { DownloadManager } from '@hadss/super_fast_file_trans';

    const downloadManager = DownloadManager.getInstance(); // 获取UploadManager
    
    // 下载任务开始前
    await downloadManager.init(context); // 初始化下载信息数据库
    // ...
    // 需要清理本地下载信息时
    await DownloadManager.getInstance().cleanAll(context); // 清除本地下载信息
    ```

    b.DownloadTask对象初始化。
    
    ```typescript
    import { DownloadConfig, DownloadListener, DownloadTask, DownloadProgressInfo } from '@hadss/super_fast_file_trans';
    
    let downloadConfig: DownloadConfig = {
      url: `${YOUR_DOWNLOAD_URL}`, // 远端下载地址（必选）
      fileName: `${YOUR_LOCAL_FILE_NAME}`, // 下载后的本地文件名（必选）
      isBreakpointResume: false,
      concurrency: 2,
      securityConfig: `${YOUR_CERTIFICATE_CONFIG}`,
    };
    let downloadListener: DownloadListener = {
      onStart: (trialResponseHeaders: Record<string, string | string[] | undefined>) => {
        // ...
      },
      onProgressUpdate: (downloadProgress: DownloadProgressInfo) => {
        // ...
      },
      onSuccess: (filePath: string) => {
        // ...
      },
      onFail: (err: BusinessError) => {
        // ...
      }
    };
    // 创建下载任务
    const downloadTask:DownloadTask = downloadManager.createDownloadTask(downloadConfig, customDownloadListener);
    ```

    c.下载任务功能接口使用：下载/暂停/获取下载进度/恢复/取消。
    
    ```typescript
    if (downloadTask) {
      await downloadTask.start(); // 开始下载
      await downloadTask.pause(); // 暂停下载
      let progressInfo:DownloadProgressInfo = await downloadTask.getProgress();
      await downloadTask.resume(); // 继续下载
      await downloadTask.cancel(); // 取消下载
    }
    ```

2. 使用super_fast_file_trans实现文件上传页关键代码。

    a.上传任务信息管理。
    ```typescript
    import { UploadManager } from '@hadss/super_fast_file_trans';

    const uploadManager = UploadManager.getInstance(); // 获取UploadManager单例对象
    
    // 上传任务开始前
    await uploadManager.init(context); // 初始化上传数据库;
    // ...
    await uploadManager.cleanAll(context); // 删除上传数据库,清除缓存
    ```

    b.UploadTask对象初始化。
    ```typescript
    import { UploadConfig, UploadListener, UploadTask, UploadProgressInfo } from '@hadss/super_fast_file_trans';
    
    // 自定义上传回调
    let customUploadListener: UploadListener = {
      onSuccess: () => {
        console.log("onSuccess: upload success")
      },
      onFail: (err: BusinessError) => {
        console.error(`onFail: upload fail, err.message:${err.message}, err.code:${err.code}`);
      },
      // ...
      onProgressUpdate: (uploadProgress: UploadProgressInfo) => {
        console.log(`onProgressUpdate:, upload: transferred size:${uploadProgress.transferredSize}, total size:${uploadProgress.totalSize}`)
      }
    };
    
    let fileDir = context.filesDir;
    let uploadConfig:uploadConfig = {
      url: `${YOUR_UPLOAD_SERVER_URL}`, // 远端上传地址（必选）
      filePath: `${FILE_DIR}/${FILE_NAME}`, // 本地上传文件的路径（必选）
      isChunk: false, // 是否启用分片上传（可选）
      // ...
    };
    ```
   
    c.上传任务功能接口使用：上传/暂停/获取上传进度/恢复/取消。
    ```typescript
    if (uploadTask) {
      await uploadTask.start();
      await uploadTask.pause();
      let progressInfo:UploadProgressInfo = await uploadTask.getProgress();
      await uploadTask.resume();
      await uploadTask.cancel();
    }
    ```

## 注意事项
1. 本Sample无法直接运行，需要在src/ets/common/CommonConstants.ets下配置下载地址、上传地址、上传文件本地地址。
2. 由于安全限制证书没有直接在Sample提供，当需要在双向校验下发送HTTPS请求时，请根据需要src/main/resources/rawfile/下进行补充和调整，会话安全相关接口详情见library/README.md。

## 相关权限
本Sample依赖以下权限：
ohos.permission.INTERNET

## 约束与限制
1. 本示例仅支持标准系统上运行，支持设备：华为手机、平板、PC/2in1。
2. HarmonyOS系统：HarmonyOS 5.0.1 Release及以上。
3. DevEco Studio版本：DevEco Studio 5.0.1 Release及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.0.1 Release SDK及以上。