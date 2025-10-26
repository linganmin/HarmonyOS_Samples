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
/**
 * 最佳实践：基于RCP的文件上传与下载
 */
import { rcp } from '@kit.RemoteCommunicationKit';
import { fileIo } from '@kit.CoreFileKit';
import { Want, wantAgent } from '@kit.AbilityKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { CustomListItem } from '../components/CustomList';
import { SelectionList } from '../components/SelectionList';
import { download, getFileList, upload } from '../service/FileRequest';
import { File } from '../service/Model';
import { copyFileSync, getAlbumAsset, selectImagesFromAlbum } from '../utils/LocalFileUtil';
import { ProgressBtn } from '../components/ProgressButton';
import { getProgressPercent, showErrorMessage, showSuccessMessage } from '../utils/CommonUtil';
import { Logger } from '../utils/Logger';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');
let context = uiContext!.getHostContext()!;

@Component
export struct BackgroundFileTransfer {
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
  downloadToFile: () => Promise<void> = async () => {
    const image = this.imageList.find(image => image.id === this.selectedRowId);
    if (!image) return;
    const httpEventsHandler: rcp.HttpEventsHandler = {
      onDownloadProgress: this.onDownloadProgress
    };
    try {
      const fileNameExtension = image.name.split('.').pop() || 'png';
      const destPath = await getAlbumAsset(fileNameExtension);
      const srcPath = await download(image.name, httpEventsHandler);
      copyFileSync(srcPath, destPath)
      showSuccessMessage('Succeed in downloading to album');
      fileIo.unlink(srcPath);
    } catch (err) {
      showErrorMessage(`Failed to save to album, ${err.message || err.data}`);
      Logger.error(err.message || JSON.stringify(err.data));
    } finally {
      this.selectedRowId = '';
      this.downloadProgress = 0;
    }
  }
  upload: () => Promise<void> = async () => {
    try {
      const sandboxPaths = await selectImagesFromAlbum();
      const filePath = sandboxPaths[0];
      if (!filePath) {
        return;
      }
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

  getWantAgentInfo() {
    const want: Want = {
      bundleName: 'com.example.rcpfiletransfer',
      abilityName: 'EntryAbility'
    };
    const wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [want],
      actionType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      actionFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };
    return wantAgentInfo;
  }

  // [Start back_task]
  async startBackgroundTask(task: () => Promise<void>) {
    try {
      const wantAgentObj = await wantAgent.getWantAgent(this.getWantAgentInfo());
      if (canIUse('SystemCapability.ResourceSchedule.BackgroundTaskManager.Core')) {
        await backgroundTaskManager.startBackgroundRunning(
          context,
          backgroundTaskManager.BackgroundMode.DATA_TRANSFER,
          wantAgentObj
        );
        task().finally(() => {
          backgroundTaskManager.stopBackgroundRunning(context);
        });
      }
    } catch (err) {
      Logger.error('Failed to start background task', JSON.stringify(err));
      showErrorMessage('A background task is running');
    }
  }

  // [End back_task]

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

        if (this.downloadProgress) {
          ProgressBtn({
            progress: this.downloadProgress,
            text: $r('app.string.button_text_download')
          })
        } else {
          SaveButton()
            .height(40)
            .width('100%')
            .onClick(async (event: ClickEvent, result: SaveButtonOnClickResult) => {
              if (result === SaveButtonOnClickResult.SUCCESS) {
                this.startBackgroundTask(this.downloadToFile)
              }
            })
        }
        ProgressBtn({
          progress: this.uploadProgress,
          text: $r('app.string.button_text_upload_album')
        })
          .margin({ top: 10 })
          .onClick(() => {
            this.startBackgroundTask(this.upload)
          })
      }
      .padding({ left: 16, right: 16, bottom: 16 })
    }
    .backgroundColor('#F1F3F5')
  }
}