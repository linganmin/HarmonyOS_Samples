/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import { CustomDataSource } from '../components/CustomDataSource';
import {
  FileModel,
  FileType,
  fileUtils,
  logger,
  requestFiles,
  requestDownload,
  TOAST_BOTTOM,
  TASK_PAUSE_MSG,
  TASK_RESUME_MSG,
  TASK_NET_PAUSE_MSG,
  TASK_NET_RESUME_MSG
} from '@ohos/uploaddownload';
import { SelectFolderDialog } from '../components/SelectFolderDialog';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'Download';

const OFFSET_DY: Length = -12;
const OFFSET_DX: Length = 0;
const LOADING_PROGRESS_WIDTH: Length = 100;
const FULL_WIDTH: Length = '100%';
const FULL_HEIGHT: Length = '100%';
const LIST_WIDTH: Length = '100%';
const LIST_HEIGHT: Length = 'auto';
const LIST_BORDER_RADIUS: Length | BorderRadiuses = 24;
const PADDING_TOP: Length = 4;
const PADDING_BOTTOM: Length = 4;
const STROKE_WIDTH: Length = 1;
const START_MARGIN: Length = 44;
const END_MARGIN: Length = 12;
const COLUMN_PADDING_LEFT: Length = 12;
const COLUMN_PADDING_RIGHT: Length = 12;
const COLUMN_PADDING_BOTTOM: Length = 12;
const BUTTON_FONT_SIZE = 16;
const MARGIN_TOP: Length = 12;
const MARGIN_LEFT: Length = 12;
const MARGIN_RIGHT: Length = 12;
const MARGIN_BOTTOM: Length = 12;
const BUTTON_HEIGHT: Length = 45;

@Entry
@Component
struct Download {
  private fileData: CustomDataSource = new CustomDataSource([]);
  @StorageLink('isBackground') isBackground: boolean = false;
  @Provide downloadFolder: Array<string> = [];
  @State isGetData: boolean = false;
  @State checkFile: Array<string> = [];
  @State checkList: Array<boolean> = [];
  @State isRunning: boolean = false;
  @State isPause: boolean = false;
  @State isNetPause: boolean = false;
  @State progress: number = 0;
  private selectFolder = (folder: string) => {
    logger.info(TAG, `selectFolder = ${folder}`);
    this.download(folder);
  }
  private folderDialogController: CustomDialogController = new CustomDialogController({
    builder: SelectFolderDialog({ selectFolder: this.selectFolder }),
    autoCancel: true,
    alignment: DialogAlignment.Bottom,
    offset: {
      dx: OFFSET_DX,
      dy: OFFSET_DY
    }
  });

  build() {
    Navigation() {
      Column() {
        if (this.isGetData) {
          LoadingProgress()
            .width(LOADING_PROGRESS_WIDTH)
            .layoutWeight(1)
        } else {
          List({ space: 12 }) {
            LazyForEach(this.fileData, (item: FileModel, index: number) => {
              ListItem() {
                this.FileItem(item, index)
              }
            }, (item: FileModel, index: number) => index + item.name)
          }
          .width(LIST_WIDTH)
          .height(LIST_HEIGHT)
          .constraintSize({ maxHeight: '80%' })
          .scrollBar(BarState.Off)
          .backgroundColor(Color.White)
          .borderRadius(LIST_BORDER_RADIUS)
          .padding({
            top: PADDING_TOP,
            bottom: PADDING_BOTTOM
          })
          .divider({
            strokeWidth: STROKE_WIDTH,
            startMargin: START_MARGIN,
            endMargin: END_MARGIN
          })
        }
        Blank()
          .layoutWeight(1)

        this.BottomView()
      }
      .padding({
        left: COLUMN_PADDING_LEFT,
        right: COLUMN_PADDING_RIGHT,
        bottom: COLUMN_PADDING_BOTTOM
      })
      .height(FULL_HEIGHT)
    }
    .width(FULL_WIDTH)
    .height(FULL_HEIGHT)
    .hideBackButton(false)
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
    .backgroundColor($r('app.color.light_gray'))
    .hideToolBar(false)
    .title($r('app.string.download'))
  }

  @Builder
  FileItem(file: FileModel, index: number) {
    Row() {
      Row() {
        if (file.fileType === FileType.FOLDER) {
          Image($r('app.media.ic_files_folder'))
            .size({ width: 24, height: 24 })
            .objectFit(ImageFit.Contain)
        } else if (file.fileType === FileType.IMAGE) {
          Image($r('app.media.ic_public_picture'))
            .size({ width: 24, height: 24 })
            .objectFit(ImageFit.Contain)
        } else if (file.fileType === FileType.MUSIC) {
          Image($r('app.media.ic_public_music'))
            .size({ width: 24, height: 24 })
            .objectFit(ImageFit.Contain)
        } else if (file.fileType === FileType.Video) {
          Image($r('app.media.ic_public_video'))
            .size({ width: 24, height: 24 })
            .objectFit(ImageFit.Contain)
        } else {
          Image($r('app.media.ic_public_document'))
            .size({ width: 24, height: 24 })
            .objectFit(ImageFit.Contain)
        }

        Text(decodeURIComponent(file.name))
          .fontSize(16)
          .fontWeight(400)
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ left: 12 })
      }
      .layoutWeight(1)

      Checkbox({ name: '', group: 'checkboxGroup' })
        .select(this.checkList[index])
        .selectedColor($r('app.color.button_blue'))
        .margin({ left: 12 })
        .hitTestBehavior(HitTestMode.None)
    }
    .width('100%')
    .padding({ left: 12, right: 12 })
    .height(48)
    .onClick(() => {
      this.fileCheck(index);
    })
  }

  @Builder
  BottomView() {
    Column({ space: 12 }) {
      Button() {
        Row() {
          if (!this.isBackground && this.isRunning) {
            if (this.isPause || this.isNetPause) {
              Text($r('app.string.continue'))
                .fontColor(Color.White)
                .fontSize(BUTTON_FONT_SIZE)
            } else {
              Text(`${this.progress}%`)
                .fontColor(Color.White)
                .fontSize(BUTTON_FONT_SIZE)
              Text($r('app.string.downloading'))
                .fontColor(Color.White)
                .fontSize(BUTTON_FONT_SIZE)
                .margin({ left: MARGIN_LEFT })
            }
          } else {
            Text($r('app.string.download'))
              .fontColor(Color.White)
              .fontSize(BUTTON_FONT_SIZE)
          }
        }
      }
      .id('download_to')
      .type(ButtonType.Capsule)
      .height(BUTTON_HEIGHT)
      .width(FULL_WIDTH)
      .backgroundColor($r('app.color.button_blue'))
      .onClick(() => {
        if (!this.isRunning) {
          this.folderDialogController.open();
        } else {
          if (!this.isNetPause) {
            if (this.isPause) {
              requestDownload.resume();
            } else {
              requestDownload.pause();
            }
          }
        }
      })

      Button($r('app.string.view_download_files'))
        .id('view_download_files')
        .type(ButtonType.Capsule)
        .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
        .width('100%')
        .fontSize(BUTTON_FONT_SIZE)
        .margin({ bottom: MARGIN_BOTTOM })
        .fontColor($r('app.color.btn_text_blue'))
        .onClick(() => {
          this.getUIContext().getRouter().pushUrl({
            url: 'pages/DownloadFiles'
          });
        })
    }
    .margin({
      top: MARGIN_TOP,
      left: MARGIN_LEFT,
      right: MARGIN_RIGHT
    })
  }

  aboutToAppear() {
    this.isRunning = false;
    this.isPause = false;
    this.isGetData = true;
    requestFiles.requestFiles().then((data: FileModel[]) => {
      this.checkList = [];
      this.isRunning = false;
      this.fileData.dataArray = data;
      this.fileData.dataArray.forEach(() => {
        this.checkList.push(false);
      })
      this.isGetData = false;
      this.fileData.notifyDataReload();
    })
    fileUtils.listFolders().then((folders: Array<string>) => {
      this.downloadFolder = folders;
    })
  }

  fileCheck(index: number) {
    if (!this.isBackground) {
      for (let i = 0; i < this.checkList.length; i++) {
        if (i !== index) {
          this.checkList[i] = false;
        }
      }
    }
    this.checkList[index] = !this.checkList[index];
    logger.info(TAG, `this.checkList = ${JSON.stringify(this.checkList)}`);
  }

  download(folder: string) {
    try {
      this.checkFile = [];
      if (this.checkList === undefined) {
        return;
      }
      logger.info(TAG, `this.checkList = ${JSON.stringify(this.checkList)}`);
      for (let i = 0; i < this.checkList.length; i++) {
        if (this.checkList[i]) {
          let fileModel = this.fileData.getData(i);
          logger.info(TAG, `fileModel = ${JSON.stringify(fileModel)}`);
          fileModel.files.forEach((url: string) => {
            let splitUrl = url.split('//')[1].split('/');
            if (splitUrl[splitUrl.length-1] !== '') {
              this.checkFile.push(url);
            }
          });
        }
      }
      logger.info(TAG, `this.checkFile = ${JSON.stringify(this.checkFile)}`);
      if (this.checkFile.length === 0) {
        this.getUIContext()
          .getPromptAction()
          .showToast({ message: $r('app.string.check_file_tips'), bottom: TOAST_BOTTOM });
        return;
      }
      this.progress = 0;
      if (this.isBackground) {
        this.isRunning = false;
        requestDownload.downloadFilesBackground(folder, this.checkFile);
        this.checkFile = [];
        this.checkList = [];
        this.fileData.dataArray.forEach(() => {
          this.checkList.push(false);
        })
        this.fileData.notifyDataReload();
        this.getUIContext()
          .getPromptAction()
          .showToast({ message: $r('app.string.background_task_start'), bottom: TOAST_BOTTOM });
      } else {
        this.isRunning = true;
        requestDownload.downloadFile(folder, this.checkFile[0], this.downloadFileCallback);
      }
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `download showToast failed, error code=${err.code}, message=${err.message}`);
    }
  }

  downloadFilesCallback = (downloadCount: number, isSuccess: boolean) => {
    this.progress = downloadCount;
    if (downloadCount === this.checkFile.length) {
      this.downloadFinish(isSuccess);
    }
  }
  downloadFileCallback = (progress: number, isSuccess: boolean) => {
    logger.info(TAG, `downloadFileCallback = ${progress}`);
    try {
      if (progress === TASK_PAUSE_MSG) {
        this.isPause = true;
      } else if (progress === TASK_RESUME_MSG) {
        this.isPause = false;
      } else if (progress === TASK_NET_PAUSE_MSG) {
        this.isNetPause = true;
        let message = $r('app.string.net_pause');
        this.getUIContext().getPromptAction().showToast({ message: message, bottom: TOAST_BOTTOM });
      } else if (progress === TASK_NET_RESUME_MSG) {
        this.isNetPause = false;
        let message = $r('app.string.net_resume');
        this.getUIContext().getPromptAction().showToast({ message: message, bottom: TOAST_BOTTOM });
      } else {
        this.progress = progress;
        if (this.progress === 100) {
          this.downloadFinish(isSuccess);
        }
      }
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `downloadFileCallback showToast failed, error code=${err.code}, message=${err.message}`);
    }
  }

  downloadFinish(isSuccess: boolean) {
    this.isRunning = false;
    this.checkFile = [];
    this.checkList = [];
    this.fileData.dataArray.forEach(() => {
      this.checkList.push(false);
    })
    this.fileData.notifyDataReload();
    let message = isSuccess ? $r('app.string.download_finish') : $r('app.string.download_fail');
    try {
      this.getUIContext().getPromptAction().showToast({ message: message, bottom: TOAST_BOTTOM });
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `downloadFinish showToast failed, error code=${err.code}, message=${err.message}`);
    }
  }
}