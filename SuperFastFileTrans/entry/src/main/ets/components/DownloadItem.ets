/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { DownloadConfig, DownloadTask, DownloadManager } from '@hadss/super_fast_file_trans';
import { DownloadListener } from '@hadss/super_fast_file_trans';
import { DownloadProgressInfo } from '@hadss/super_fast_file_trans';
import { FileItem } from '../model/FileItem';
import MemoryTool from '../util/MemoryTool';
import { BusinessError } from '@kit.BasicServicesKit';
import { CONSTANTS_CONFIG } from '../common/ConstantsConfig';

@Component
export struct DownloadItem {
  @State itemKey: number = 0; // 下载项key，所属列表内唯一标识属性
  @State fileName: string = '文件'; // 文件名
  @State url: string = ''; // 下载地址url
  @State concurrency: number = 1;
  @State isResumable: boolean = false;
  @State isPaused: boolean = false; // 是否暂停过
  @State isDownloading: boolean = false;
  @State transferredSize: number = 0;
  @State totalSize: number = 0;
  @State speed: number = 0;
  @State currentRate: number = 0;
  @Link downloadTaskList: Array<FileItem>; // 当前item所属的下载列表
  @Link downloadingList: Set<number>;
  @StorageLink('isDownloadAll') @Watch('onDownloadAll') isDownloadAll: boolean = false; // 接收外部全部下载指令
  @StorageLink('isPauseAll') @Watch('onPauseAll') isPauseAll: boolean = false; // 接收外部全部下载指令
  @StorageLink('isDeleteAll') @Watch('onDeleteAll') allDelete: boolean = false;
  @StorageLink('isDatabaseLoaded') @Watch('freshProgress') isDatabaseLoaded: boolean = false;
  private downloadInstance: DownloadTask | undefined;
  private memoryTool: MemoryTool = new MemoryTool();

  async aboutToAppear() {
    let downloadListener: DownloadListener = {
      onStart: (_trialResponseHeaders: Record<string, string | string[] | undefined>) => {
        this.isDownloading = true;
        if (this.isResumable) {
          this.downloadingList?.add(this.itemKey);
        }
        console.log(`Task onStart, ${JSON.stringify(_trialResponseHeaders)}`);
      },
      onResume: (_trialResponseHeaders: Record<string, string | string[] | undefined>,
        _downloadProgress: DownloadProgressInfo) => {
        this.isDownloading = true;
        if (this.isResumable) {
          this.downloadingList.add(this.itemKey);
        }
        console.log(`Task onResume, ${JSON.stringify(_trialResponseHeaders)}`);
      },
      onPause: (_downloadProgress: DownloadProgressInfo) => {
        this.isDownloading = false;
        this.speed = 0;
        if (this.isResumable) {
          this.downloadingList.delete(this.itemKey);
        }
        console.log(`Task onPause, ${JSON.stringify(_downloadProgress)}`);
      },
      onCancel: () => {
        this.isDownloading = false;
        if (this.isResumable) {
          this.downloadingList.delete(this.itemKey);
        }
        console.log(`Task onCancel`);
      },
      onSuccess: (_filePath: string) => {
        this.isDownloading = false;
        if (this.isResumable) {
          this.downloadingList.delete(this.itemKey);
        }
        console.log(`Task onSuccess, ${_filePath}`);
      },
      onFail: (_err: BusinessError) => {
        this.isDownloading = false;
        if (this.isResumable) {
          this.downloadingList.delete(this.itemKey);
        }
        console.log(`Task onFail, ${JSON.stringify(_err)}`);
      },
      onProgressUpdate: (downloadProgress: DownloadProgressInfo) => {
        this.transferredSize = downloadProgress.transferredSize;
        this.totalSize = downloadProgress.totalSize;
        this.speed = downloadProgress.speed;
        this.currentRate = this.transferredSize / this.totalSize * 100;
        console.log(`Task onProgressUpdate, ${JSON.stringify(downloadProgress)}`);
      }
    };

    // [Start MultiTheadDownload]
    // [Start ResumableDownload]
    // [Start AutoReconnect]
    let downloadConfig: DownloadConfig = {
      url: this.url, // URL of the remote file.
      fileName: this.fileName, // Local file name.
      concurrency: this.concurrency, // Number of download threads. The value is an integer ranging from 1 to 8.
      // [StartExclude MultiTheadDownload]
      isBreakpointResume: this.isResumable, // Enable resumable download by setting isBreakpointResume to true.
      // [StartExclude ResumableDownload]
      maxRetries: 3, // Set the maximum retry attempts to 3.
      retryInterval: 2000, // Set the retry interval to 2000 ms.
      // [StartExclude AutoReconnect]
      securityConfig: CONSTANTS_CONFIG.certificate.securityConfig,
      // [EndExclude AutoReconnect]
      // [EndExclude MultiTheadDownload]
      // [EndExclude ResumableDownload]
    };
    // Create a download task, with downloadListener specified as an optional callback.
    this.downloadInstance = DownloadManager.getInstance().createDownloadTask(downloadConfig, downloadListener);
    // [End AutoReconnect]
    // [StartExclude MultiTheadDownload]
    // [StartExclude ResumableDownload]

    this.downloadInstance =
      DownloadManager.getInstance().createDownloadTask(downloadConfig, downloadListener);
    this.downloadInstance?.getProgress().then((progress: DownloadProgressInfo) => {
      this.transferredSize = progress.transferredSize;
      this.totalSize = progress.totalSize;
      this.currentRate = progress.transferredSize / progress.totalSize * 100;
      this.isPaused = this.transferredSize !== 0;
    });
  }

  async onDownloadAll() {
    if (this.isDownloadAll && !this.isDownloading) {
      await this.download();
    }
  }

  async onPauseAll() {
    if (this.isPauseAll && this.isDownloading) {
      await this.pause();
      this.isPaused = true;
    }
  }

  async onDeleteAll() {
    await this.cancel();
    this.downloadTaskList = this.downloadTaskList.filter((item: FileItem) => {
      return item.fileKey !== this.itemKey;
    });
  }

  async download() {
    if (!this.isPaused || this.transferredSize === this.totalSize) {
      await this.start();
    } else {
      await this.resume();
    }
  }

  async start() {
    // [EndExclude MultiTheadDownload]
    // [EndExclude ResumableDownload]
    await this.downloadInstance?.start(); // Enable multi-threaded download.
    // [End MultiTheadDownload]
    // [StartExclude ResumableDownload]
  }

  async pause() {
    // [EndExclude ResumableDownload]
    await this.downloadInstance?.pause(); // Pause the download manually or through other methods.
    // [StartExclude ResumableDownload]
  }

  async resume() {
    // [EndExclude ResumableDownload]
    await this.downloadInstance?.resume(); // Resume the download.
    // [End ResumableDownload]
  }

  async cancel() {
    await this.downloadInstance?.cancel();
  }

  async freshProgress() {
    const progress = await this.downloadInstance?.getProgress();
    this.transferredSize = progress!.transferredSize;
    this.totalSize = progress!.totalSize;
    this.currentRate = progress!.transferredSize / progress!.totalSize * 100;
    if (this.transferredSize === 0) {
      this.isPaused = false;
    } else {
      this.isPaused = true;
    }
  }

  build() {
    Column() {
      Row() {
        Column() {
          Image($r('app.media.logo'))
            .width(46)
            .height(46)
        }

        Column() {
          Text(this.fileName)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.Black)
            .fontSize(18)
            .opacity(0.9)

          Text(this.memoryTool.convert(this.transferredSize) + '/' +
          this.memoryTool.convert(this.totalSize) + ' - ' +
          this.memoryTool.convert(this.speed) + '/s')
            .fontSize(14)
            .fontColor(Color.Black)
            .opacity(0.6)
        }
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.SpaceAround)
        .width(164)
        .height(46)

        Column() {
          Row() {
            Image(this.isDownloading ? $r('app.media.pause') : $r('app.media.play'))
              .width(24)
              .height(24)
              .onClick(async () => {
                if (this.isDownloading) {
                  this.isPaused = true;
                  await this.pause();
                } else {
                  await this.download();
                }
              })
            Image($r('app.media.cancel'))
              .width(24)
              .height(24)
              .onClick(async () => {
                await this.cancel();
                this.downloadTaskList = this.downloadTaskList.filter((item: FileItem) => {
                  return item.fileKey !== this.itemKey;
                });
              })
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .width(64)
          .height(24)
        }
        .height(46)
        .justifyContent(FlexAlign.Start)
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width(307)
      .height(62)

      Row() {
        Progress({ value: this.currentRate, total: 100, type: ProgressType.Linear })
          .width(307)
          .height(24)
      }
    }
    .width(328)
    .height(86)
    .justifyContent(FlexAlign.Center)
  }
}