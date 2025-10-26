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

import { fileIo } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import Logger from '../common/utils/Logger';
import DateTimeUtil from '../common/utils/DateTimeUtils';
import { CommonConstants as Const } from '../common/CommonConstants';
import { CameraDataModel } from '../model/CameraDateModel';
import { CameraController } from '../controller/CameraController';
import { BgmController } from '../controller/BgmController';
import { DistributeFileManager } from '../controller/DistributeFileManager';

const TAG: string = Const.INDEX_TAG;
const DATETIME: DateTimeUtil = new DateTimeUtil();
const uiContext: UIContext | undefined = AppStorage.get('uiContext');

@Entry
@Component
struct Player {
  @State buttonEnabled: boolean = true;
  @State isShow: boolean = false;
  @State isShowSelectFile: boolean = false;
  @State videoUriList: Array<string> = [];
  @Provide('pageStack') pageStack: NavPathStack = new NavPathStack();
  @Provide('cameraController') cameraController: CameraController | undefined = undefined;
  @Provide('bgmController') bgmController: BgmController | undefined = undefined;
  @Provide('fileNameSandbox') fileNameSandbox: string | undefined = undefined;
  @State isLoading: boolean = false;
  private cameraData: CameraDataModel = new CameraDataModel();

  @Builder
  Authorized() {
    Column() {
      Text($r('app.string.saveButtonNote'))
        .width('100%')
        .fontSize('16vp')
        .margin({ bottom: '12vp' })

      Row() {
        Button($r('app.string.saveButtonCancel'))
          .onClick(() => {
            this.isShow = false;
          })
          .width('48%')

        Blank()

        SaveButton({ text: SaveDescription.SAVE })
          .onClick(async () => {
            let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
            let pathDir: string = context.filesDir;
            let fileName: string = `/HMOSLiveStream_${DATETIME.getDate()}_${DATETIME.getTime()}.mp4`;
            let filePath: string = pathDir + fileName;
            let file: fileIo.File;
            try {
              file = await fileIo.open(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
            } catch (error) {
              let err = error as BusinessError;
              Logger.error(TAG, `open file failed, errCode = ${err.code}, errMessage = ${err.message}.`);
              return;
            }
            if(file.fd == undefined){
              Logger.error(TAG, `get outputfd failed!`);
              return ;
            }
            this.cameraData.reset();
            this.cameraData.outputFd = file.fd;
            this.cameraData.isOpenEchoCancel = 1;
            if (this.cameraData.outputFd >= 0) {
              let context = uiContext?.getHostContext() as common.UIAbilityContext;
              this.cameraController = new CameraController(this.cameraData, context);

              this.cameraController.initNative().then((data) => {
                if (data.surfaceId !== undefined) {
                  this.cameraData.surfaceId = data.surfaceId;
                  this.isShow = false;
                  this.pageStack.pushPath({ name: 'StartLiveStream' });
                }
                this.bgmController = new BgmController(this.cameraController?.getNativeRecorderObj());
                this.fileNameSandbox = fileName;
              })
            } else {
              Logger.error(TAG, `get outputfd failed!`);
            }
          })
          .width('48%')
          .height('40vp')
      }
      .justifyContent(FlexAlign.SpaceAround)
      .alignItems(VerticalAlign.Bottom)
      .margin({ bottom: '44vp' })
      .width('100%')
      .height('52vp')
    }
    .justifyContent(FlexAlign.End)
    .padding({ left: '16vp', right: '16vp' })
    .width('100%')
    .height('100%')
  }

  aboutToDisappear(): void {
    if (this.cameraData.outputFd !== undefined && this.cameraData.outputFd >= 0) {
      // Close file fd.
      fileIo.close(this.cameraData.outputFd).catch((error: BusinessError) => {
        Logger.error(TAG, `fileIo close  fail ${error}`);
      });
    }
  }

  build() {
    Navigation(this.pageStack) {
      RelativeContainer() {
        Column() {
          Button($r('app.string.watch_live_stream'))
            .onClick(async () => {
              this.isLoading = true;
              const distributeFileManager = new DistributeFileManager();
              const filePath = await distributeFileManager.getVideoFile(this.getUIContext()
                .getHostContext() as common.UIAbilityContext);
              this.isLoading = false;
              if (filePath === '') {
                try {
                  this.getUIContext()
                    .getPromptAction()
                    .showToast({ message: $r('app.string.no_video_alert'), duration: 200 });
                } catch (error) {
                  let err = error as BusinessError;
                  Logger.error(TAG, `showToast failed, errCode = ${err.code}, errMessage = ${err.message}.`);
                }
              } else {
                this.pageStack.pushPath({ name: 'WatchLiveStream', param: filePath });
              }
            })
            .fontSize('16vp')
            .fontWeight(FontWeight.Medium)
            .size({
              width: '328vp',
              height: '40vp'
            })
            .fontSize('16vp')
            .fontWeight(FontWeight.Medium)
            .backgroundColor("#0E5BF5")
            .margin({
              bottom: '12vp'
            })

          Button($r('app.string.start_live_stream'))
            .size({
              width: '328vp',
              height: '40vp'
            })
            .fontSize('16vp')
            .fontWeight(FontWeight.Medium)
            .backgroundColor("#0E5BF5")
            .onClick(() => {
              this.isShow = true;
            })
            .bindSheet($$this.isShow, this.Authorized, {
              height: 210,
              title: {
                title: $r('app.string.saveButtonTitle')
              }
            })
        }
        .alignRules({
          'bottom': { 'anchor': '__container__', 'align': VerticalAlign.Bottom },
          'left': { 'anchor': '__container__', 'align': HorizontalAlign.Start }
        })
        .padding({ left: '16vp', right: '16vp', bottom: '32vp' })
        .width('100%')
        .height('200vp')
        .justifyContent(FlexAlign.End)
        .visibility(this.isLoading ? Visibility.None : Visibility.Visible)

        LoadingProgress()
          .width(50)
          .height(50)
          .visibility(this.isLoading ? Visibility.Visible : Visibility.None)
          .alignRules({
            'center': { 'anchor': '__container__', 'align': VerticalAlign.Center },
            'middle': { 'anchor': '__container__', 'align': HorizontalAlign.Center }
          })
      }
      .width('100%')
      .height('100%')
    }
    .mode(NavigationMode.Stack)
    .title($r('app.string.home_page_title'))
  }
}