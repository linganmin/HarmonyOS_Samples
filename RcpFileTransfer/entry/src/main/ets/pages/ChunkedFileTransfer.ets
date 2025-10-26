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
import { chunkedDownload, getFileList } from '../service/FileRequest';
import { File } from '../service/Model';
import { saveImageToAlbum } from '../utils/LocalFileUtil';
import { ProgressBtn } from '../components/ProgressButton';
import { getProgressPercent, showErrorMessage, showSuccessMessage } from '../utils/CommonUtil';
import { Logger } from '../utils/Logger';

const TAG = 'ChunkedFileTransfer';

@Component
export struct ChunkedFileTransfer {
  @Consume navPageInfos: NavPathStack;
  @State fileList: File[] = [];
  @State selectedRowId: string = '';
  @State downloadProgress: number = 0;

  aboutToAppear(): void {
    this.setFileList();
  }

  async setFileList() {
    this.fileList = await getFileList();
  }

  onDownloadProgress: rcp.OnDownloadProgress = (totalSize, downloadedSize) => {
    this.downloadProgress = getProgressPercent(totalSize, downloadedSize);
  }

  async downloadToFile() {
    const file = this.fileList.find(image => image.id === this.selectedRowId);
    if (!file) {
      return;
    }
    let filePath = '';
    try {
      filePath = await chunkedDownload(file.name, this.onDownloadProgress);
      await saveImageToAlbum(filePath);
      showSuccessMessage('Succeed in downloading to album');
    } catch (err) {
      showErrorMessage('Failed to save to album');
      Logger.error(err.message);
    } finally {
      fileIo.unlink(filePath).catch((err: BusinessError) => {
        Logger.error(TAG, `unlink failed: code: ${err.code}, message: ${err.message}`);
      });
      this.selectedRowId = '';
      this.downloadProgress = 0;
    }
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

  build() {
    NavDestination() {
      Column() {
        Column() {
          SelectionList({
            data: this.getCustomListData(),
            selectedRowId: this.selectedRowId
          })
        }
        .layoutWeight(1)

        ProgressBtn({
          progress: this.downloadProgress,
          text: $r('app.string.button_text_download_chunked')
        })
          .onClick(() => this.downloadToFile())
      }
      .padding({ left: 16, right: 16, bottom: 16 })
    }
    .backgroundColor('#F1F3F5')
  }
}