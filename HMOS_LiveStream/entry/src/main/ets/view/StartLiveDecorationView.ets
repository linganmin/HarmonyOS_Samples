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
import { camera } from '@kit.CameraKit';
import { common } from '@kit.AbilityKit';
import { fileIo } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { BackgroundTaskManager } from '../common/utils/BackgroundTaskManager';
import { CameraController } from '../controller/CameraController';
import { SettingPopupDialog } from '../components/SettingPopupDialog';
import { SettingPopupOptionItem } from '../model/SettingPopupOptionItem';
import { CommonConstants } from '../common/CommonConstants';
import { BgmController } from '../controller/BgmController';
import Logger from '../common/utils/Logger';
import { DistributeFileManager } from '../controller/DistributeFileManager';


const uiContext: UIContext | undefined = AppStorage.get('uiContext');
const TAG: string = "[StartLiveDecorationView]";

@Component
export struct StartLiveDecorationView {
  @Consume('pageStack') pageStack: NavPathStack;
  @Consume('cameraController') cameraController: CameraController;
  @Consume('bgmController') bgmController: BgmController;
  @Consume('fileNameSandbox') fileNameSandbox: string;
  @State fov: number = 1;
  @State currentFovToShow: number = 1.0;
  @State isCurrentFovOnShow: boolean = false;
  @State settingTitle: string | undefined = "";
  @State isOpenROI: boolean = false;
  @State isOpenBGM: boolean = false;
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: SettingPopupDialog({
      title: this.settingTitle,
      options: [
        new SettingPopupOptionItem(CommonConstants.ROI_ID,
          $r('app.string.set_roi'),
          this.isOpenROI,
          (checked: boolean) => {
            this.isOpenROI = checked;
            this.cameraController.setIsOpenROI(this.isOpenROI);
          }
        ),
        new SettingPopupOptionItem(CommonConstants.BGM_ID,
          $r('app.string.set_bgm'),
          this.isOpenBGM,
          (checked: boolean) => {
            this.isOpenBGM = checked;
            if (this.isOpenBGM) {
              this.playBgm();
            } else {
              this.bgmController.stopPlay();
            }
          }
        ),
      ],

    }),
    cornerRadius: "32vp"
  });

  async aboutToAppear(): Promise<void> {
    try {
      this.settingTitle = uiContext?.getHostContext()?.resourceManager.getStringSync($r("app.string.setting_title").id);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `get setting_title failed, errCode = ${err.code}, errMessage = ${err.message}.`);
      this.settingTitle = 'Setting';
    }
  }

  async playBgm() {
    let fileName = 'Delacey_DreamItPossible.mp3';
    try {
      this.getUIContext().getHostContext()?.resourceManager.getRawFileContent(fileName, (_err, value) => {
        if (_err) {
          Logger.error(TAG, `get raw file failed: ${_err}`);
          return;
        }
        let fileBuffer: ArrayBufferLike = value.buffer;
        let context = this.getUIContext().getHostContext();
        let bgmFilePath = context!.filesDir + '/' + fileName;
        Logger.info(TAG, `bgm file filePath: ${bgmFilePath}.`);
        let file = fileIo.openSync(bgmFilePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
        let writeLen = fileIo.writeSync(file.fd, fileBuffer);
        Logger.info(TAG, `write bgm raw data to file succeed and size is: ${writeLen}.`);
        fileIo.closeSync(file);
        let callback: () => void = () => {
          Logger.info(TAG, `player JSCallback.`);
          this.isOpenBGM = false;
        }
        this.bgmController?.play(bgmFilePath, callback);
      });
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `getRawFileContent failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
  }

  @Builder
  TopBar() {
    Row() {
      Text($r('app.string.people_in_live_room'))
        .fontSize('12vp')
        .fontColor(Color.White);

      Image($r('app.media.close_button'))
        .width('48vp')
        .height('48vp')
        .onClick(async () => {
          BackgroundTaskManager.stopContinuousTask(uiContext?.getHostContext() as common.UIAbilityContext);
          await this.cameraController.release();
          this.bgmController.release();
          // copy file from sandbox to distribute file
          const distributeFileManager = new DistributeFileManager();
          await distributeFileManager.copyFileToDistribute(uiContext?.getHostContext() as common.UIAbilityContext,
            this.fileNameSandbox);
          this.pageStack.pop();
        })
    }
    .position({
      top: '32vp',
    })
    .width('100%')
    .padding({
      left: '24vp',
      right: '24vp'
    })
    .justifyContent(FlexAlign.SpaceBetween);
  }

  @Builder
  FocusText() {
    if (this.isCurrentFovOnShow) {
      Text(this.currentFovToShow.toFixed(1) + 'x')
        .fontSize(20)
        .fontColor(Color.White);
    }
  }

  @Builder
  BottomBar() {
    Row() {
      Image($r('app.media.toggle_position'))
        .width('48vp')
        .height('48vp')
        .onClick(() => {
          // Camera rotation / switching between front and rear cameras
          let cameraPosition = this.cameraController.getCameraPosition()
          if (cameraPosition === camera.CameraPosition.CAMERA_POSITION_FRONT) {
            cameraPosition = camera.CameraPosition.CAMERA_POSITION_BACK;
          } else {
            cameraPosition = camera.CameraPosition.CAMERA_POSITION_FRONT;
          }
          this.cameraController.setCameraPosition(cameraPosition);
          this.cameraController.releaseCamera();
          this.cameraController.createRecorder();
        })

      Button() {
        Image($r('app.media.gearshape'))
          .width('32vp')
          .height('32vp')
      }
      .width('48vp')
      .height('48vp')
      .type(ButtonType.Circle)
      .backgroundColor('#b3ffffff')
      .onClick(() => {
        this.dialogController.open();
      })
    }
    .position({
      bottom: '32vp',
    })
    .width('100%')
    .padding({
      left: '24vp',
      right: '24vp'
    })
    .justifyContent(FlexAlign.SpaceBetween);

  }

  build() {
    Stack() {
      this.TopBar();
      this.FocusText();
      this.BottomBar();
    }
    .width('100%')
    .height('100%')
    .gesture(
      PinchGesture()
        .onActionUpdate((event: GestureEvent) => {
          Logger.debug(TAG, "begin action update ");
          this.isCurrentFovOnShow = true;
          this.cameraController.doGestureUpdate(this.fov, event);
          let curFov = this.cameraController.getCurrentZoomRatio();
          if (curFov) {
            this.currentFovToShow = curFov;
          }
        })
        .onActionEnd((_: GestureEvent) => {
          Logger.debug(TAG, 'action End ');
          let curFov = this.cameraController.getCurrentZoomRatio();
          if (curFov) {
            this.fov = curFov;
          }
          this.isCurrentFovOnShow = false;
        })
    )
  }
}