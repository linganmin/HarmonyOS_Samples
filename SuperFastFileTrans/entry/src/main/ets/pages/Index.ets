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

import { DownloadView } from '../view/DownloadView';
import { UploadView } from '../view/UploadView';
import { LengthMetrics } from '@kit.ArkUI';
import { CustomMenuItem } from '../components/CustomMenuItem';
import { fileIo as fs } from '@kit.CoreFileKit';
import { CONSTANTS_CONFIG } from '../common/ConstantsConfig';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct Index {
  @State isDownloadStatus: boolean = true;
  @State isAllDownload: boolean = false;
  @State isClickable: boolean = true;
  @State isAllUpload: boolean = false;
  private context = AppStorage.get('context') as common.UIAbilityContext;

  async aboutToAppear(): Promise<void> {
    try {
      let readContent: Uint8Array;
      readContent =
        await this.context.resourceManager.getRawFileContent(CONSTANTS_CONFIG.certificate.serverCertificateName);
      if (readContent) {
        let file =
          fs.openSync(CONSTANTS_CONFIG.certificate.serverCertificatePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
        fs.writeSync(file.fd, readContent.buffer);
        fs.fsyncSync(file.fd);
        fs.closeSync(file);
      }
      readContent =
        await this.context.resourceManager.getRawFileContent(CONSTANTS_CONFIG.certificate.clientCertificateName);
      if (readContent) {
        let file =
          fs.openSync(CONSTANTS_CONFIG.certificate.clientCertificatePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
        fs.writeSync(file.fd, readContent.buffer);
        fs.fsyncSync(file.fd);
        fs.closeSync(file);
      }
    } catch (err) {
      hilog.info(0x0001, 'Index', 'Fail to load certificate.');
    }
  }

  @Builder
  MyMenu() {
    Menu() {
      MenuItem({ content: '下载文件' })
        .width(103)
        .onClick(() => {
          this.isDownloadStatus = true;
          this.isAllUpload = false;
          AppStorage.setOrCreate('isDeleteAll', false);
          AppStorage.setOrCreate('isUploadAll', false);
          AppStorage.setOrCreate('pauseAllUpload', true);
        })
      MenuItem({ content: '上传文件' })
        .width(103)
        .onClick(() => {
          this.isDownloadStatus = false;
          this.isAllDownload = false;
          AppStorage.setOrCreate('isDeleteAll', false);
          AppStorage.setOrCreate('isDownloadAll', false);
          AppStorage.setOrCreate('isPauseAll', true);
        })
    }
    .menuItemDivider({
      strokeWidth: new LengthMetrics(0.5),
      color: '#E6000000',
      startMargin: new LengthMetrics(0),
      endMargin: new LengthMetrics(0)
    })
  }

  @Builder
  DownloadMenu() {
    Row() {
      if (!this.isAllDownload) {
        CustomMenuItem({ image: $r('app.media.download') })
          .onClick(() => {
            if (!AppStorage.get('isDeleteAll')) {
              AppStorage.setOrCreate('isDownloadAll', true);
              AppStorage.setOrCreate('isPauseAll', false);
            }
          })
      } else {
        CustomMenuItem({ image: $r('app.media.pause') })
          .onClick(() => {
            AppStorage.setOrCreate('isPauseAll', true);
            AppStorage.setOrCreate('isDownloadAll', false);
          })
      }
      CustomMenuItem({ image: $r('app.media.delete') })
        .onClick(() => {
          AppStorage.setOrCreate('isDeleteAll', true);
          this.isAllDownload = false;
          AppStorage.setOrCreate('isDownloadAll', false);
        })
      CustomMenuItem({ image: $r('app.media.switch') })
        .bindMenu(this.MyMenu())
    }
    .height(56)
    .margin({ right: 16 })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  UploadMenu() {
    Row() {
      if (!this.isAllUpload) {
        CustomMenuItem({ image: $r('app.media.upload') })
          .onClick(() => {
            if (!AppStorage.get('isDeleteAll')) {
              AppStorage.setOrCreate('isUploadAll', true);
              AppStorage.setOrCreate('pauseAllUpload', false);
            }
          })
      } else {
        CustomMenuItem({ image: $r('app.media.pause') })
          .onClick(() => {
            AppStorage.setOrCreate('pauseAllUpload', true);
            AppStorage.setOrCreate('isUploadAll', false);
          })
      }
      CustomMenuItem({ image: $r('app.media.delete') })
        .onClick(() => {
          AppStorage.setOrCreate('isDeleteAll', true);
          this.isAllUpload = false;
          AppStorage.setOrCreate('isUploadAll', false);
        })
      CustomMenuItem({ image: $r('app.media.switch') })
        .bindMenu(this.MyMenu())
    }
    .height(56)
    .margin({ right: 16 })
    .alignItems(VerticalAlign.Center)
  }

  build() {
    Column() {
      Navigation() {
        Column() {
          if (this.isDownloadStatus) {
            DownloadView({ isAllDownload: this.isAllDownload })
              .width(474)
              .height(328)
              .margin({ top: 50 })
          } else {
            UploadView({ isAllUpload: this.isAllUpload })
              .width(474)
              .height(328)
              .margin({ top: 50 })
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
      }
      .menus(this.isDownloadStatus ? this.DownloadMenu() : this.UploadMenu())
      .title(this.isDownloadStatus ? $r('app.string.sampleTitle') : $r('app.string.uploadTitle'))
      .width('100%')
      .height('100%')
    }
  }
}