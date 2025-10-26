/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 ("the License");
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

import { rcp } from '@kit.RemoteCommunicationKit';
import { fileIo } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { CustomListItem } from '../components/CustomList';
import { SelectionList } from '../components/SelectionList';
import { getFileList, ResumableDownloadManager } from '../service/FileRequest';
import { File } from '../service/Model';
import { getAlbumAsset } from '../utils/LocalFileUtil';
import { ProgressBtn } from '../components/ProgressButton';
import { getProgressPercent, showSuccessMessage } from '../utils/CommonUtil';
import { Logger } from '../utils/Logger';

const TAG = 'ResumableFileTransfer';
const uiContext: UIContext | undefined = AppStorage.get('uiContext');
let promptAction = uiContext!.getPromptAction()!;

@Component
export struct ResumableFileTransfer {
  @Consume navPageInfos: NavPathStack;
  @State fileList: File[] = [];
  @State selectedRowId: string = '';
  @State progress: number = 0;
  @State isDownloading: boolean = false;
  @State resumableDownloadManager: ResumableDownloadManager | null = null;
  @State filePath: string = '';
  @State selectedFile: File | undefined = undefined;

  aboutToAppear(): void {
    this.setFileList();
  }

  async setFileList() {
    this.fileList = await getFileList();
  }

  onDownloadedProgress: rcp.OnDownloadProgress = (totalSize, downloadedSize) => {
    this.progress = getProgressPercent(totalSize, downloadedSize);
  }

  async startDownload() {
    const file = this.fileList.find(file => file.id === this.selectedRowId);
    if (!file) {
      return;
    }
    this.selectedFile = file;
    const fileNameExtension = file.name.split('.').pop() || 'png';
    this.filePath = await getAlbumAsset(fileNameExtension);
    this.resumeDownload();
  }

  async resumeDownload() {
    this.isDownloading = true;
    this.resumableDownloadManager = this.resumableDownloadManager ||
      new ResumableDownloadManager(this.selectedFile!.name, this.filePath, this.onDownloadedProgress);
    await this.resumableDownloadManager.start();
    showSuccessMessage('Succeed in downloading');
    this.resetStates();
  }

  async pauseDownload() {
    this.isDownloading = false;
    this.resumableDownloadManager?.pause()
  }

  resetStates() {
    this.resumableDownloadManager = null;
    this.progress = 0;
    this.isDownloading = false;
    this.selectedRowId = '';
    this.filePath = '';
    this.selectedFile = undefined;
    fileIo.unlink(this.filePath).catch((err: BusinessError) => {
      Logger.error(TAG, `unlink failed: code: ${err.code}, message: ${err.message}`);
    });
  }

  getCustomListData(): CustomListItem[] {
    return this.fileList.map(file => {
      const item: CustomListItem = {
        id: file.id.toString(),
        title: file.name,
        image: $r('app.media.ic_public_picture')
      };
      return item;
    });
  }

  beforeRowChange: (row: CustomListItem) => Promise<boolean> = async () => {
    if (!this.resumableDownloadManager) {
      return true;
    }
    try {
      const res = await promptAction.showDialog({
        message: 'Downloading file...Cancel？',
        buttons: [
          {
            text: 'cancel',
            color: '#000000'
          },
          {
            text: 'confirm',
            color: '#0A59F7'
          }
        ]
      });
      if (res.index === 0) {
        return false;
      }
    } catch (exception) {
      Logger.error(TAG, `unlink failed: code: ${exception.code}, message: ${exception.message}`);
    }
    this.pauseDownload();
    this.resetStates();
    return true;
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          SelectionList({
            data: this.getCustomListData(),
            selectedRowId: this.selectedRowId,
            beforeRowChange: this.beforeRowChange
          })
        }
        .layoutWeight(1)

        if (this.progress) {
          ProgressBtn({
            progress: this.progress,
            text: this.isDownloading ? $r('app.string.button_text_pause') : $r('app.string.button_text_download')
          })
            .enabled(!!this.selectedRowId)
            .onClick(() => {
              if (this.isDownloading) {
                this.pauseDownload()
              } else {
                this.resumeDownload()
              }
            })
        } else {
          SaveButton()
            .height(40)
            .width('100%')
            .onClick(async (event: ClickEvent, result: SaveButtonOnClickResult) => {
              if (result === SaveButtonOnClickResult.SUCCESS) {
                this.startDownload()
              }
            })
        }
      }
      .padding({ left: 16, right: 16, bottom: 16 })
    }
    .backgroundColor('#F1F3F5')
  }
}