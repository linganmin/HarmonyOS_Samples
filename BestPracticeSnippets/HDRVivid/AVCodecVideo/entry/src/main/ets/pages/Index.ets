/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
import { display, promptAction } from '@kit.ArkUI';
import { camera } from '@kit.CameraKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import player from 'libplayer.so';
import recorder from 'librecorder.so';
import Logger from '../common/utils/Logger';
import DateTimeUtil from '../common/utils/DateTimeUtils';
import { CommonConstants as Const } from '../common/CommonConstants';
import { CameraDataModel } from '../model/CameraDateModel';
import { videoProfileCheck } from '../common/utils/CameraCheck';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG: string = Const.INDEX_TAG;
const DATETIME: DateTimeUtil = new DateTimeUtil();

@Entry
@Component
struct Player {
  @State buttonEnabled: boolean = true;
  @State isShow: boolean = false;
  private cameraData: CameraDataModel = new CameraDataModel();
  private selectFilePath: string | null = null;
  private display: display.Display | null = null;
  private heightPx = '';

  aboutToAppear() {
    try {
      this.display = display.getDefaultDisplaySync();
      this.heightPx = (this.display.width * Const.DEFAULT_HEIGHT / Const.DEFAULT_WIDTH) + Const.PX;
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(`getDefaultDisplaySync failed. code=${err.code}, message=${err.message}`);
    }
  }

  selectFile() {
    let photoPicker = new photoAccessHelper.PhotoViewPicker();
    photoPicker.select({
      MIMEType: photoAccessHelper.PhotoViewMIMETypes.VIDEO_TYPE,
      maxSelectNumber: 1
    })
      .then((photoSelectResult) => {
        this.selectFilePath = photoSelectResult.photoUris[0];
        if (this.selectFilePath === null) {
          promptAction.openToast({
            message: $r('app.string.alert'),
            duration: Const.DURATION,
            bottom: Const.BOTTOM
          })
            .catch((err: BusinessError) => {
              Logger.error(`promptAction openToast failed. code=${err.code}, message=${err.message}`);
            })
        } else {
          this.play();
          Logger.info(TAG, 'documentViewPicker.select to file succeed and URI is:' + this.selectFilePath);
        }
      })
      .catch((err: BusinessError) => {
        Logger.error(`photoPicker select failed. code=${err.code}, message=${err.message}`);
      })
  }

  play() {
    try {
      let inputFile = fileIo.openSync(this.selectFilePath, fileIo.OpenMode.READ_ONLY);
      if (!inputFile) {
        Logger.error(TAG, 'player inputFile is null');
      }
      let inputFileState = fileIo.statSync(inputFile.fd);
      if (inputFileState.size <= 0) {
        Logger.error(TAG, 'player inputFile size is 0');
      }
      this.buttonEnabled = false;
      player.playNative(inputFile.fd, Const.DEFAULT_VALUE, inputFileState.size, () => {
        Logger.info(TAG, 'player JSCallback');
        this.buttonEnabled = true;
        fileIo.close(inputFile)
          .catch((err: BusinessError) => {
            Logger.error(`fileIo close failed. code=${err.code}, message=${err.message}`);
          })
      })
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(`fileIo failed. code=${error.code}, message=${error.message}`);
    }
  }

  async checkIsProfileSupport(): Promise<void> {
    let context = this.getUIContext()?.getHostContext();
    let cameraManager: camera.CameraManager;
    try {
      cameraManager = camera.getCameraManager(context)
      if (!cameraManager) {
        Logger.error(TAG, 'camera.getCameraManager error!');
      }

      let videoProfile: undefined | camera.VideoProfile = videoProfileCheck(cameraManager, this.cameraData);
      if (!videoProfile) {
        Logger.error(TAG, 'videoProfile is not found');
        promptAction.openToast({
          message: $r('app.string.alert_setting'),
          duration: Const.DURATION,
          bottom: Const.BOTTOM,
          backgroundColor: Color.White,
          backgroundBlurStyle: BlurStyle.NONE
        })
          .catch((err: BusinessError) => {
            Logger.error(`promptAction openToast failed. code=${err.code}, message=${err.message}`);
          })
        this.cameraData = new CameraDataModel();
        return;
      }
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(`getCameraManager failed. code=${error.code}, message=${error.message}`);
    }
  }

  @Builder
  SettingButton() {
    Button() {
      Image($r('app.media.gearshape'))
        .width($r('app.float.set_image_width'))
        .height($r('app.float.set_image_height'))
    }
    .width($r('app.float.set_button_width'))
    .height($r('app.float.set_button_height'))
    .type(ButtonType.Circle)
    .backgroundColor($r('app.color.set_button_background'))
    .margin({ right: $r('app.float.set_button_margin_right') })
    .onClick(() => {
      this.getUIContext().showTextPickerDialog({
        defaultPickerItemHeight: Const.DEFAULT_PICKER_ITEM_HEIGHT,
        selectedTextStyle: ({
          font: ({
            size: Const.SELECTED_TEXT_STYLE_FONT_SIZE
          })
        }),
        range: Const.RECORDER_INFO,
        canLoop: false,
        alignment: DialogAlignment.Center,
        backgroundColor: Color.White,
        backgroundBlurStyle: BlurStyle.BACKGROUND_ULTRA_THICK,
        onAccept: (value: TextPickerResult) => {
          switch (value.value[0]) {
            case Const.VIDEO_MIMETYPE[0]: {
              this.cameraData.setCodecFormat(Const.TRUE, Const.MIME_VIDEO_HEVC);
              break;
            }
            case Const.VIDEO_MIMETYPE[1]: {
              this.cameraData.setCodecFormat(Const.FALSE, Const.MIME_VIDEO_AVC);
              break;
            }
            case Const.VIDEO_MIMETYPE[2]: {
              this.cameraData.setCodecFormat(Const.FALSE, Const.MIME_VIDEO_HEVC);
              break;
            }
            default:
              break;
          }

          switch (value.value[1]) {
            case Const.VIDEO_RESOLUTION[0]: {
              this.cameraData.setResolution(Const.VIDEO_WIDTH_4K, Const.VIDEO_HEIGHT_4K, Const.BITRATE_VIDEO_30M);
              break;
            }
            case Const.VIDEO_RESOLUTION[1]: {
              this.cameraData.setResolution(Const.VIDEO_WIDTH_1080P, Const.VIDEO_HEIGHT_1080P, Const.BITRATE_VIDEO_20M);
              break;
            }
            case Const.VIDEO_RESOLUTION[2]: {
              this.cameraData.setResolution(Const.VIDEO_WIDTH_720P, Const.VIDEO_HEIGHT_720P, Const.BITRATE_VIDEO_10M);
              break;
            }
            default:
              break;
          }

          switch (value.value[2]) {
            case Const.VIDEO_FRAMERATE[0]: {
              this.cameraData.frameRate = Const.FRAMERATE_VIDEO_30FPS;
              break;
            }
            case Const.VIDEO_FRAMERATE[1]: {
              this.cameraData.frameRate = Const.FRAMERATE_VIDEO_60FPS;
              break;
            }
            default:
              break;
          }
          this.checkIsProfileSupport();
        }
      });
    })
  }

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
            let context = this.getUIContext()?.getHostContext();
            let helper = photoAccessHelper.getPhotoAccessHelper(context);
            try {
              let uri = await helper.createAsset(photoAccessHelper.PhotoType.VIDEO, 'mp4', {
                title: `AVCodecVideo_${DATETIME.getDate()}_${DATETIME.getTime()}`
              });
              let file = await fileIo.open(uri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
              this.cameraData.outputfd = file.fd;
              if (this.cameraData.outputfd !== null) {
                recorder.initNative(this.cameraData.outputfd, this.cameraData.videoCodecMime,
                  this.cameraData.cameraWidth,
                  this.cameraData.cameraHeight, this.cameraData.frameRate, this.cameraData.isHDRVivid,
                  this.cameraData.bitRate).then((data) => {
                  if (data.surfaceId !== null) {
                    this.cameraData.surfaceId = data.surfaceId;
                    let uiContext = this.getUIContext();
                    let router = uiContext.getRouter();
                    router.pushUrl({
                      url: 'pages/Recorder',
                      params: this.cameraData
                    })
                      .then(() => {
                        Logger.info(`router pushUrl success`);
                      })
                      .catch((error: BusinessError) => {
                        Logger.error(`router pushUrl failed. code=${error.code}, message=${error.message}`);
                      })
                  }
                })
              } else {
                Logger.error(TAG, 'get outputfd failed!');
              }
            } catch (err) {
              let error = err as BusinessError;
              Logger.error(`fileIo open failed. code=${error.code}, message=${error.message}`);
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

  @Builder
  Window() {
    Row() {
      XComponent({
        id: 'player',
        type: XComponentType.SURFACE,
        libraryname: 'player'
      })
        .height(this.heightPx)
        .width(Const.FULL_SIZE)
    }
    .alignRules({
      'top': { 'anchor': '__container__', 'align': VerticalAlign.Top },
      'left': { 'anchor': '__container__', 'align': HorizontalAlign.Start }
    })
    .margin({ top: $r('app.float.window_margin_top') })
  }

  build() {
    RelativeContainer() {
      Row() {
        this.SettingButton()
      }
      .width($r('app.string.full_width'))
      .height($r('app.float.set_row_height'))
      .margin({ top: $r('app.float.set_row_margin_top') })
      .justifyContent(FlexAlign.End)
      .alignRules({
        'top': { 'anchor': '__container__', 'align': VerticalAlign.Top },
        'left': { 'anchor': '__container__', 'align': HorizontalAlign.Start }
      })

      this.Window()

      Column() {
        Button(this.buttonEnabled ? $r('app.string.play') : $r('app.string.playing'))
          .onClick(() => {
            this.selectFile();
          })
          .size({
            width: '100%',
            height: $r('app.float.index_button_height')
          })
          .enabled(this.buttonEnabled)
          .margin({ bottom: $r('app.float.button_margin_bottom') })

        Button($r('app.string.record'))
          .onClick(() => {
            this.isShow = true;
          })
          .bindSheet($$this.isShow, this.Authorized, {
            height: 210,
            title: {
              title: $r('app.string.saveButtonTitle')
            }
          })
          .size({
            width: '100%',
            height: $r('app.float.index_button_height')
          })
          .enabled(this.buttonEnabled)
      }
      .alignRules({
        'bottom': { 'anchor': '__container__', 'align': VerticalAlign.Bottom },
        'left': { 'anchor': '__container__', 'align': HorizontalAlign.Start }
      })
      .padding({ left: '16vp', right: '16vp', bottom: '16vp' })
      .width($r('app.string.full_width'))
      .height($r('app.float.index_column_height'))
      .justifyContent(FlexAlign.End)
    }
    .width($r('app.string.full_width'))
    .height($r('app.string.full_height'))
  }
}