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

import { image } from '@kit.ImageKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';
import { JSON } from '@kit.ArkTS';
import { fileIo } from '@kit.CoreFileKit';
import { connection } from '@kit.NetworkKit';
import { ChoseFile, UPLOAD_STATUS, UploadComponent } from '../views/UploadView';
import { showToast } from '../utils/CommonUtils';
import {
  getMultiPathQuota,
  NetHandleChange,
  releaseMultiPath,
  reportQoe,
  requestMultiPath,
  setOffMultiPathStateChange,
  setOnMultiPathStateChange,
  setUploadSceneDesc
} from '../net/NetBoostManager';
import { getDefaultNetHandle } from '../net/NetConnectionManager';
import { FilePartsUploadManager } from '../viewmodel/upload/FilePartsUploadManager';
import { PhotoUtils } from '../utils/PhotoUtils';
import { formatFileSize } from '../utils/FileUtils';
import { CommonConst } from '../common/CommonConst';


const DOMAIN = 0x0000;
const TAG = 'UploadPage';

@Builder
export function UploadPageBuilder() {
  UploadPage()
}

@Component
struct UploadPage {
  @State uploadBtnEnable: boolean = false;
  @State chooseFileEnable: boolean = true;
  @State showUploadComponent: boolean = false;
  @State multiPathNetEnable: boolean = true;
  @State multiPathNetOpened: boolean = false;
  @State fileSize: string = '';
  @State submitResult: string = '';
  @State uploadStatus: UPLOAD_STATUS = UPLOAD_STATUS.NORMAL;
  @State uploadProgress: number = 0;
  @State takesTime: number = 0;
  @Provide imageInfo: image.PixelMap | string = '';
  private context: Context | undefined
  private secondNetHandle: connection.NetHandle | undefined = undefined;
  private photoUtils: PhotoUtils = new PhotoUtils();
  private selectFileUri: string = '';
  private uploader: FilePartsUploadManager | undefined = undefined;
  private intervalId: number = -1;
  private netHandleChange: NetHandleChange = {
    onMultiNetSuccess: async (netHandle: connection.NetHandle): Promise<void> => {
      this.secondNetHandle = netHandle;
      this.multiPathNetOpened = true;
      this.uploader?.addNetHandle(netHandle);
    },

    onMultiNetRelease: async (netHandle: connection.NetHandle): Promise<void> => {
      this.multiPathNetOpened = false;
      this.secondNetHandle = undefined;
    }
  }
  private onChooseFile: () => void = async () => {
    let fileUri = await this.selectFile();
    if (fileUri) {
      this.imageInfo = await this.photoUtils.acquireThumbnailByUrl(fileUri);
      this.showUploadComponent = true;
      this.uploadBtnEnable = true;
      this.uploadStatus = UPLOAD_STATUS.NORMAL;
      this.selectFileUri = fileUri;
    } else {
      hilog.info(DOMAIN, TAG, `[onChooseFile] File not prepared`);
      this.showUploadComponent = false;
      this.uploadBtnEnable = false;
      this.selectFileUri = '';
    }
  }
  private onDeleteFile: () => void = async () => {
    this.showUploadComponent = false;
    this.uploadBtnEnable = false;
    this.chooseFileEnable = true;
  }
  private onCancelUpload: () => void = async () => {
    this.showUploadComponent = false;
    this.uploadBtnEnable = false;
    this.chooseFileEnable = true;
    this.closeMultiPathNet();
    this.uploader?.destroyTask();
    this.endTiming();
  }

  private initData() {
    this.context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  }

  aboutToAppear(): void {
    this.initData();
    setOnMultiPathStateChange(this.netHandleChange);
  }

  aboutToDisappear(): void {
    setOffMultiPathStateChange();
    this.closeMultiPathNet();
    this.uploader?.destroyTask();
    this.endTiming();
  }

  /**
   * Checks if the file size is within the expected range.
   * @param fileUri The file URI to be checked.
   * @returns Returns true if the file size meets the expectation, otherwise returns false.
   * */
  private fileSuits(fileUri: string): boolean {
    if (!fileUri) {
      hilog.error(DOMAIN, TAG, `[fileSuits] fileUri is null`);
      return false;
    }
    try {
      let file = fileIo.openSync(fileUri, fileIo.OpenMode.READ_ONLY);
      // read file info
      let stat = fileIo.statSync(file.fd);
      if (stat.location !== 1) {
        hilog.error(DOMAIN, TAG, `[fileSuits] file is not local file`);
        return false;
      }
      if (stat.size < CommonConst.FILE_SELECT_MIN_SIZE) {
        showToast($r('app.string.file_too_small'));
        return false;
      }
      if (stat.size > CommonConst.FILE_SELECT_MAX_SIZE) {
        showToast($r('app.string.file_too_big'));
        return false;
      }
      this.fileSize = formatFileSize(stat.size);
      return true;
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      hilog.error(DOMAIN, TAG, `[fileSuits] occurred error:${error.code},${error.name}`);
      return false;
    }
  }

  /**
   * Select a file.
   * @returns Returns the URI of the selected file.
   * */
  private selectFile(): Promise<string> {
    return new Promise((resolve) => {
      try {
        const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
        photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE;
        photoSelectOptions.isSearchSupported = true;
        photoSelectOptions.isPhotoTakingSupported = true;
        photoSelectOptions.isOriginalSupported = true;
        photoSelectOptions.maxSelectNumber = 1;
        photoSelectOptions.isPreviewForSingleSelectionSupported = false;
        photoSelectOptions.fileSizeFilter = {
          filterOperator: photoAccessHelper.FilterOperator.BETWEEN,
          fileSize: CommonConst.FILE_SELECT_MIN_SIZE, extraFileSize: CommonConst.FILE_SELECT_MAX_SIZE
        };
        const photoPicker = new photoAccessHelper.PhotoViewPicker();
        photoPicker.select(photoSelectOptions).then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
          if (photoSelectResult.photoUris.length > 0) {
            const uris: Array<string> = photoSelectResult.photoUris;
            if (this.fileSuits(uris[0])) {
              resolve(uris[0]);
            } else {
              resolve('');
            }
          } else {
            resolve('');
          }
        }).catch((err: BusinessError) => {
          hilog.error(DOMAIN, TAG, `[PhotoViewPicker] select failed with err: ${err.code}, ${err.message}`);
          resolve('');
        });
      } catch (error) {
        const err: BusinessError = error as BusinessError;
        hilog.error(DOMAIN, TAG, `[PhotoViewPicker] failed with err: ${err.code},${err.name}`);
        resolve('');
      }
    })
  }

  private closeMultiPathNet() {
    setUploadSceneDesc(false);
    releaseMultiPath();
    getMultiPathQuota();
    reportQoe('good');
  }

  private startTiming() {
    this.takesTime = 0;
    this.intervalId =
      setInterval(() => {
        this.takesTime += 0.5
      }, 500);
  }

  private endTiming() {
    clearInterval(this.intervalId);
    this.takesTime = 0;
  }

  private listenOnUpload(uploader: FilePartsUploadManager, startTime: number) {
    uploader.onProgress = (progress: number) => {
      this.uploadStatus = UPLOAD_STATUS.UPLOADING;
      this.uploadProgress = progress;
      this.uploadBtnEnable = false;
    };
    uploader.onSuccess = () => {
      hilog.info(DOMAIN, TAG, `[listenOnUpload] File upload onComplete`);
      this.uploadStatus = UPLOAD_STATUS.SUCCESS;
      this.uploadBtnEnable = true;
      this.chooseFileEnable = true;
      this.uploadProgress = 0;
      const takesTime = new Date().getTime() - startTime;
      try {
        this.submitResult =
          this.context!.resourceManager.getStringSync($r('app.string.upload_success').id, takesTime / 1000);
      } catch (error) {
        const err: BusinessError = error as BusinessError;
        hilog.error(DOMAIN, TAG, `Failed to getStringSync. Cause: ${err.code},${err.name}`);
      }
      this.multiPathNetOpened = false;
      this.closeMultiPathNet();
      this.endTiming();
    };
    uploader.onError = () => {
      hilog.error(DOMAIN, TAG, `[listenOnUpload] File upload error`);
      this.uploadStatus = UPLOAD_STATUS.FAIL;
      this.uploadBtnEnable = true;
      this.chooseFileEnable = true;
      this.uploadProgress = 0;
      try {
        this.submitResult = this.context!.resourceManager.getStringSync($r('app.string.upload_failed').id);
      } catch (error) {
        const err: BusinessError = error as BusinessError;
        hilog.error(DOMAIN, TAG, `Failed to getStringSync. Cause: ${err.code},${err.name}`);
      }
      this.multiPathNetOpened = false;
      this.closeMultiPathNet();
      this.endTiming();
    };
  }

  private async uploadFile() {
    const mainNetHandle = getDefaultNetHandle();
    if (mainNetHandle) {
      // reset upload status
      this.startTiming();
      const startTime = new Date();
      this.uploadBtnEnable = false;
      this.chooseFileEnable = false;
      this.uploadStatus = UPLOAD_STATUS.UPLOADING;
      this.uploadProgress = 0;
      // create upload
      if (this.secondNetHandle) {
        showToast($r('app.string.transfer_accelerating'));
        this.uploader = new FilePartsUploadManager(this.selectFileUri, [mainNetHandle, this.secondNetHandle]);
      } else {
        this.uploader = new FilePartsUploadManager(this.selectFileUri, [mainNetHandle]);
      }
      // init upload
      let initRes = await this.uploader.initUpload();
      if (initRes) {
        this.listenOnUpload(this.uploader, startTime.getTime());
        // start upload file
        this.uploader.startUpload();
      } else {
        // upload error,show error status
        hilog.error(DOMAIN, TAG, `[uploadFile] File initupload error`);
        this.uploadStatus = UPLOAD_STATUS.FAIL;
        this.uploadBtnEnable = true;
        this.chooseFileEnable = true;
        this.uploadProgress = 0;
        try {
          this.submitResult = this.context!.resourceManager.getStringSync($r('app.string.upload_failed').id);
        } catch (error) {
          const err: BusinessError = error as BusinessError;
          hilog.error(DOMAIN, TAG, `Failed to getStringSync. Cause: ${err.code},${err.name}`);
        }
        this.endTiming();
      }
    } else {
      // upload error,show error status
      hilog.error(DOMAIN, TAG, `[uploadFile] getAllNets error`);
      this.uploadStatus = UPLOAD_STATUS.FAIL;
      this.uploadBtnEnable = true;
      this.chooseFileEnable = true;
      this.uploadProgress = 0;
      try {
        this.submitResult = this.context!.resourceManager.getStringSync($r('app.string.upload_failed').id);
      } catch (error) {
        const err: BusinessError = error as BusinessError;
        hilog.error(DOMAIN, TAG, `Failed to getStringSync. Cause: ${err.code},${err.name}`,);
      }
    }
  }

  build() {
    NavDestination() {
      Column() {
        ChoseFile({
          onChooseFile: this.onChooseFile
        }).enabled(this.chooseFileEnable)
          .opacity(this.chooseFileEnable ? 1 : 0.4)

        if (this.showUploadComponent) {
          UploadComponent({
            uploadStatus: this.uploadStatus,
            fileSize: this.fileSize,
            takesTime: this.takesTime + 's',
            uploadProgress: this.uploadProgress,
            onDeleteFile: this.onDeleteFile,
            onCancelUpload: this.onCancelUpload,
            submitResult: this.submitResult
          })
            .margin({
              top: $r('app.float.size_24vp')
            })
        }

        Blank()
        Row() {
          Text($r('app.string.multi_net_upload'))
            .fontSize($r('app.float.size_14fp'))
            .fontWeight(FontWeight.Normal)
            .textAlign(TextAlign.Start)
            .fontColor($r('sys.color.font_primary'))
            .margin({
              left: $r('app.float.size_14vp')
            })
            .width('calc(100% - 38vp)')

          Toggle({ type: ToggleType.Switch, isOn: $$this.multiPathNetOpened })
            .selectedColor($r('sys.color.brand'))
            .height('app.float.size_20vp')
            .enabled(this.multiPathNetEnable)
            .margin({
              right: $r('app.float.size_2vp')
            })
            .switchPointColor($r('sys.color.comp_background_list_card'))
            .onChange(async (value: boolean) => {
              if (value) {
                reportQoe('packetLost');
                setUploadSceneDesc(true);
                if (await requestMultiPath()) {
                  getMultiPathQuota();
                  showToast($r('app.string.multi_net_enabled'));
                } else {
                  this.multiPathNetOpened = false;
                  showToast($r('app.string.multi_net_failed'));
                  setUploadSceneDesc(false);
                }
              } else {
                this.closeMultiPathNet();
              }
            });
        }
        .height('app.float.size_48vp')
        .width('100%')
        .padding({
          left: $r('app.float.size_12vp'),
          right: $r('app.float.size_12vp')
        })
        .onClick(() => {
          this.multiPathNetOpened = !this.multiPathNetOpened;
        })

        Button($r('app.string.submit'))
          .fontSize($r('app.float.size_16fp'))
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
          .borderRadius($r('app.float.size_20vp'))
          .height($r('app.float.size_40vp'))
          .backgroundColor($r('sys.color.comp_background_emphasize'))
          .width('100%')
          .enabled(this.uploadBtnEnable)
          .margin({
            top: $r('app.float.size_12vp'),
            bottom: $r('app.float.size_16vp')
          })
          .onClick(async () => {
            this.uploadFile();
          })
      }
      .padding({
        left: $r('app.float.size_16vp'),
        right: $r('app.float.size_16vp'),
      })
      .height('100%')
      .width('100%')
      .backgroundColor($r('app.color.bg_main'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(false)
    .title($r('app.string.submit_content'))
    .hideBackButton(false)
    .hideToolBar(true)
    .hideToolBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}