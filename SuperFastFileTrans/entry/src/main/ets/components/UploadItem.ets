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

import { UploadConfig, UploadTask, UploadManager } from '@hadss/super_fast_file_trans';
import { UploadProgressInfo, UploadListener } from '@hadss/super_fast_file_trans';
import { CONSTANTS_CONFIG } from '../common/ConstantsConfig';
import { FileItem } from '../model/FileItem';
import MemoryTool from '../util/MemoryTool';
import { BusinessError } from '@kit.BasicServicesKit';

@Component
export struct UploadItem {
  private uploadInstance: UploadTask | undefined;
  private memoryTool: MemoryTool = new MemoryTool();
  public filePath: string = ''; // 本地文件地址
  public isChunk: boolean = false; // 是否分片
  @State itemKey: number = 0; // 上传项key，所属列表内唯一标识属性
  @State fileName: string = ''; // 文件名
  @State isPaused: boolean = false; // 是否暂停过
  @State isUploading: boolean = false; //是否正在上传
  @State transferredSize: number = 0; // 传输大小
  @State totalSize: number = 0; // 文件总大小
  @State speed: number = 0; // 上传速度
  @State currentRate: number = 0; // 进度
  @Link uploadTaskList: Array<FileItem>; // 当前item所属的上传列表
  @Link uploadingList: Set<number>;
  @StorageLink('isUploadAll') @Watch('onUploadAll') isUploadAll: boolean = false; // 接收外部全部上传指令
  @StorageLink('pauseAllUpload') @Watch('pauseAllUpload') isPauseAll: boolean = false; // 暂停全部上传指令
  @StorageLink('isDeleteAll') @Watch('onDeleteAll') allDelete: boolean = false;
  @StorageLink('isDatabaseLoaded') @Watch('freshProgress') isDatabaseLoaded: boolean = false;

  async aboutToAppear() {
    let uploadListener: UploadListener = {
      onStart: () => {
        this.isUploading = true;
        if (this.isChunk) {
          this.uploadingList.add(this.itemKey);
        }
        console.log(`Task onStart`);
      },
      onResume: (_uploadProgressInfo: UploadProgressInfo) => {
        this.isUploading = true;
        if (this.isChunk) {
          this.uploadingList.add(this.itemKey);
        }
        console.log(`Task onResume, ${JSON.stringify(_uploadProgressInfo)}`);
      },
      onPause: (_uploadProgressInfo: UploadProgressInfo) => {
        this.isUploading = false;
        this.speed = 0;
        if (this.isChunk) {
          this.uploadingList.delete(this.itemKey);
        }
        console.log(`Task onPause, ${JSON.stringify(_uploadProgressInfo)}`);
      },
      onCancel: () => {
        this.isUploading = false;
        if (this.isChunk) {
          this.uploadingList.delete(this.itemKey);
        }
        console.log(`Task onCancel`);
      },
      onSuccess: (_filePath: string) => {
        this.isUploading = false;
        this.speed = 0;
        if (this.isChunk) {
          this.uploadingList.delete(this.itemKey);
        }
        console.log(`Task onSuccess, ${_filePath}`);
      },
      onFail: (_err: BusinessError<void>) => {
        this.isUploading = false;
        this.speed = 0;
        if (this.isChunk) {
          this.uploadingList.delete(this.itemKey);
        }
        console.log(`Task onFail, ${JSON.stringify(_err)}`);
      },
      onProgressUpdate: (uploadProgress: UploadProgressInfo) => {
        this.transferredSize = uploadProgress.transferredSize;
        this.totalSize = uploadProgress.totalSize;
        this.speed = uploadProgress.speed;
        this.currentRate = this.transferredSize / this.totalSize * 100;
        console.log(`Task onProgressUpdate, ${JSON.stringify(uploadProgress)}`);
      }
    };
    // [Start ChunkUpload]
    // [Start ResumableUpload]
    let uploadConfig: UploadConfig = {
      url: this.isChunk ? CONSTANTS_CONFIG.urls.chunkUploadUrl :
           CONSTANTS_CONFIG.urls.ordinaryUploadUrl, // URL of the upload request
      filePath: this.filePath, // Local file path.
      isChunk: this.isChunk, // Enable chunk upload by setting isChunk to true, which also activates download functionality.
      chunkSize: 1024 * 1024 * 10, // Set chunk size to 10MB. This field is effective only when isChunk is set to true.
      // [StartExclude ChunkUpload]
      // [StartExclude ResumableUpload]
      hashConfig: {
        hashValue: 'test',
      },
      uploadFileName: this.fileName,
      securityConfig: CONSTANTS_CONFIG.certificate.securityConfig,
      // [EndExclude ChunkUpload]
      // [EndExclude ResumableUpload]
    };
    // Create a upload task, with uploadListener specified as an optional callback.
    this.uploadInstance = UploadManager.getInstance().createUploadTask(uploadConfig, uploadListener);
    // [StartExclude ChunkUpload]
    // [StartExclude ResumableUpload]
    this.uploadInstance?.getProgress().then((progress: UploadProgressInfo) => {
      this.transferredSize = progress.transferredSize;
      this.totalSize = progress.totalSize;
      this.currentRate = progress.transferredSize / progress.totalSize * 100;
      this.isPaused = this.transferredSize !== 0;
    });
  }

  async onUploadAll() {
    if (this.isUploadAll && !this.isUploading) {
      await this.upload();
    }
  }

  async pauseAllUpload() {
    if (this.isPauseAll && this.isUploading) {
      await this.pause();
      this.isPaused = true;
    }
  }

  async onDeleteAll() {
    await this.cancel();
    this.uploadTaskList = this.uploadTaskList.filter((item: FileItem) => {
      return item.fileKey !== this.itemKey;
    });
  }

  async start() {
    // [EndExclude ChunkUpload]
    // [EndExclude ResumableUpload]
    await this.uploadInstance?.start(); // Enable chunk upload.
    // [End ChunkUpload]
    // [StartExclude ResumableUpload]
  }

  async pause() {
    // [EndExclude ResumableUpload]
    await this.uploadInstance?.pause(); // Pause the upload manually or through other methods.
    // [StartExclude ResumableUpload]
  }

  async resume() {
    // [EndExclude ResumableUpload]
    await this.uploadInstance?.resume(); // Resume the upload.
    // [End ResumableUpload]
  }

  async cancel() {
    await this.uploadInstance?.cancel();
  }

  async upload() {
    if (!this.isPaused || this.transferredSize == this.totalSize) {
      await this.start();
    } else {
      await this.resume();
    }
  }

  async freshProgress() {
    const progress = await this.uploadInstance?.getProgress();
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
            Image(this.isUploading ? $r('app.media.pause') : $r('app.media.play'))
              .width(24)
              .height(24)
              .onClick(async () => {
                if (this.isUploading) {
                  this.isPaused = true;
                  await this.pause();
                } else {
                  await this.upload();
                }
              })
            Image($r('app.media.cancel'))
              .width(24)
              .height(24)
              .onClick(async () => {
                await this.cancel();
                this.uploadTaskList = this.uploadTaskList.filter((item: FileItem) => {
                  return item.fileKey != this.itemKey;
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