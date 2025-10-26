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
import { CustomListItem } from '../components/CustomList';
import { SelectionList } from '../components/SelectionList';
import { download, getFileList, upload } from '../service/FileRequest';
import { File } from '../service/Model';
import { saveImageToAlbum, selectImagesFromAlbum } from '../utils/LocalFileUtil';
import { ProgressBtn } from '../components/ProgressButton';
import { getProgressPercent, showErrorMessage, showSuccessMessage } from '../utils/CommonUtil';
import { Logger } from '../utils/Logger';

@Component
export struct AlbumImageTransfer {
  @Consume navPageInfos: NavPathStack;
  @State imageList: File[] = [];
  @State selectedRowId: string = '';
  @State downloadProgress: number = 0;
  @State uploadProgress: number = 0;

  aboutToAppear(): void {
    this.setFileList();
  }

  async setFileList() {
    this.imageList = await getFileList();
  }

  onUploadProgress: rcp.OnUploadProgress = (totalSize, uploadedSize) => {
    this.uploadProgress = getProgressPercent(totalSize, uploadedSize);
  }

  onDownloadProgress: rcp.OnDownloadProgress = (totalSize, downloadedSize) => {
    this.downloadProgress = getProgressPercent(totalSize, downloadedSize);
  }

  async downloadToFile() {
    const image = this.imageList.find(image => image.id === this.selectedRowId);
    if (!image) return;
    const httpEventsHandler: rcp.HttpEventsHandler = {
      onDownloadProgress: this.onDownloadProgress
    };
    try {
      const filePath = await download(image.name, httpEventsHandler);
      await saveImageToAlbum(filePath);
      showSuccessMessage('Succeed in downloading to album');
      fileIo.unlink(filePath);
    } catch (err) {
      showErrorMessage(`Failed to save to album, ${err.message || err.data}`);
      Logger.error(err.message || JSON.stringify(err.data));
    } finally {
      this.selectedRowId = '';
      this.downloadProgress = 0;
    }
  }

  async upload() {
    try {
      const sandboxPaths = await selectImagesFromAlbum();
      const filePath = sandboxPaths[0];
      if (!filePath) return;
      const httpEventsHandler: rcp.HttpEventsHandler = {
        onUploadProgress: this.onUploadProgress,
      };
      await upload(filePath, httpEventsHandler);
      showSuccessMessage('succeed in uploading from album');
      this.setFileList();
      fileIo.unlink(filePath);
      this.uploadProgress = 0;
    } catch (err) {
      Logger.error(`Failed to select images from album, ${err.message}`);
      showErrorMessage(err.message);
    }
  }

  getCustomListData(): CustomListItem[] {
    return this.imageList.map(image => {
      const item: CustomListItem = {
        id: image.id.toString(),
        title: image.name,
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
          text: $r('app.string.button_text_download_album')
        })
          .margin({ bottom: 10 })
          .onClick(() => this.downloadToFile())
        ProgressBtn({
          progress: this.uploadProgress,
          text: $r('app.string.button_text_upload_album')
        })
          .onClick(() => this.upload())
      }
      .padding({ left: 16, right: 16, bottom: 16 })
    }
    .backgroundColor('#F1F3F5')
  }
}