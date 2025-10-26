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

import { dataSharePredicates } from '@kit.ArkData';
import { abilityAccessCtrl, Permissions } from '@kit.AbilityKit';
import { camera } from '@kit.CameraKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { CameraConstants } from '../constants/CameraConstants';
import { filePreview } from '@kit.PreviewKit';
import {
  getVideoZoom,
  previewVideo,
  setVideoFlashMode,
  setVideoSmoothZoom,
  setVideoZoom,
  startRecord,
  stopRecord,
  stopRecordPreview,
  videoRecording
} from '../utils/VideoRecorder';
import {
  burstCapture,
  cameraShooting,
  capture,
  enableLivePic,
  getPhotoZoom,
  previewPhoto,
  releaseCamera,
  setPhotoFlashMode,
  setPhotoSmoothZoom,
  setPhotoZoom
} from '../utils/CameraShooter';
import display from '@ohos.display';
import { curves, window } from '@kit.ArkUI';
import { sensor } from '@kit.SensorServiceKit';
import { Context } from '@ohos.arkui.UIContext';
import { getCurrentWindowSize, getPreviewSize } from '../utils/PreviewUtil';

let cameraPosition = 0;
let surfaceId = '';
let zoomRatioRange: number[] = [];
let isVideo = false;
let qualityLevel: number = 0;
let storage = new LocalStorage();
let videoUri: string;
let currentFov: number = 1;
const DEFAULT_TOP_OFFSET =
  CameraConstants.IMAGE_HEIGHT + CameraConstants.MARGIN * 2 + CameraConstants.MARGIN_TOP +
  CameraConstants.MARGIN_HEIGHT;

class CountDownTimerModifier implements ContentModifier<TextTimerConfiguration> {
  applyContent(): WrappedBuilder<[TextTimerConfiguration]> {
    return wrapBuilder(buildTextTimer);
  }
}

const ONE_THOUSAND = 1000;
@Builder
function buildTextTimer(config: TextTimerConfiguration) {
  Text(Math.ceil(config.count / ONE_THOUSAND - config.elapsedTime / 100).toString())
    .width(CameraConstants.FULL_PERCENT)
    .height(CameraConstants.FULL_PERCENT)
    .fontSize($r('app.float.count_down_font_size'))
    .fontColor(Color.White)
    .textAlign(TextAlign.Center)
}

@Component
@Entry(storage)
struct XComponentPage {
  mXComponentController: XComponentController = new XComponentController;
  permissions: Array<Permissions> = [
    'ohos.permission.CAMERA',
    'ohos.permission.MICROPHONE',
    'ohos.permission.MEDIA_LOCATION',
    'ohos.permission.READ_IMAGEVIDEO',
    'ohos.permission.WRITE_IMAGEVIDEO',
  ];
  @State isPhoto: boolean = true;
  @State isFront: boolean = false;
  // Is recording now
  @State recording: boolean = false;
  @StorageLink('photoUri') photoUri: string | Resource | PixelMap = '';
  // Indicates whether the current preview type is an image
  @State currentPic: boolean = true;
  // Flash icon
  @LocalStorageLink('flashPic') flashPic: Resource = $r('app.media.ic_camera_public_flash_off');
  @LocalStorageLink('zoom') zoom: number = 1;
  @LocalStorageLink('isStabilization') isStabilization: boolean = false;
  @LocalStorageLink('isMovingPhoto') isMovingPhoto: boolean = false;
  @LocalStorageLink('countDownTime') countDownTime: number = 0;
  @LocalStorageLink('isBurstCapture') isBurstCapture: boolean = false;
  @LocalStorageLink('burstCaptureCount') burstCaptureCount: number = CameraConstants.BURST_CAPTURE_MIN_COUNT;
  // Video record timer
  textTimerController: TextTimerController = new TextTimerController();
  // Custom count down timer
  countDownTimeController: TextTimerController = new TextTimerController();
  countDownTimeModifier: CountDownTimerModifier = new CountDownTimerModifier();
  countDownInterval: number = 0;
  // Window object from EntryAbility
  windowClass = AppStorage.get<window.Window>('window');
  // Fold status for camera auto switching
  foldStatus: display.FoldStatus = display.FoldStatus.FOLD_STATUS_UNKNOWN;
  // Icon rotate angle
  @State rotation: number = 0;
  // Show zoom info on screen
  @State isShowZoom: boolean = false;
  // Show count down time on screen
  @State isCountingDown: boolean = false;
  // Global context
  @State context: Context = this.getUIContext().getHostContext()!;
  // Count down view size
  @State countDownSize: Size = { width: 0, height: 0 };
  // Count down view offset relative to the screen
  @State countDownOffset: Position = { x: 0, y: 0 };

  @Builder
  burstCaptureView() {
    Column() {
      Row() {
        Text($r('app.string.enable_burst_capture'))
        Toggle({ type: ToggleType.Switch, isOn: this.isBurstCapture })
          .selectedColor($r('sys.color.brand'))
          .switchPointColor($r('sys.color.comp_background_list_card'))
          .onChange((isOn: boolean) => {
            this.isBurstCapture = isOn;
          })
      }
      .width(CameraConstants.FULL_PERCENT)
      .height($r('app.float.menu_item_height'))
      .justifyContent(FlexAlign.SpaceBetween)

      Divider()
        .color($r('app.color.divider_color'))

      Column() {
        Row() {
          Text($r('app.string.burst_capture_count'))
          Text($r('app.string.shot_count', this.burstCaptureCount.toFixed(0)))
        }
        .width(CameraConstants.FULL_PERCENT)
        .justifyContent(FlexAlign.SpaceBetween)

        Slider({
          value: this.burstCaptureCount,
          min: CameraConstants.BURST_CAPTURE_MIN_COUNT,
          step: CameraConstants.BURST_CAPTURE_STEP,
          max: CameraConstants.BURST_CAPTURE_MAX_COUNT,
          style: SliderStyle.OutSet
        })
          .onChange((value: number, _mode: SliderChangeMode) => {
            this.burstCaptureCount = value;
          })
      }
      .margin({
        top: $r('app.float.menu_item_margin_top')
      })
    }
    .width($r('app.float.burst_control_width'))
    .margin({
      left: $r('app.float.menu_item_margin_left'),
      right: $r('app.float.menu_item_margin_right')
    })
  }

  onPageShow(): void {
    filePreview.closePreview(this.context);
  }

  async aboutToAppear() {
    try {
      sensor.on(sensor.SensorId.GRAVITY, (data: sensor.GravityResponse) => {
        // Disable icon rotation when display rotation is not zero
        if (display.getDefaultDisplaySync().rotation !== 0) {
          this.rotation = 0;
          return;
        }
        let degree: number = -1;
        degree = this.getCalDegree(data.x, data.y, data.z);
        if (degree >= 0 && (degree <= 30 || degree >= 330)) {
          this.rotation = camera.ImageRotation.ROTATION_0;
        } else if (degree >= 60 && degree <= 120) {
          // Use ROTATION_90 when degree range is [60, 120]
          this.rotation = camera.ImageRotation.ROTATION_270;
        } else if (degree >= 150 && degree <= 210) {
          // Use ROTATION_180 when degree range is [150, 210]
          this.rotation = camera.ImageRotation.ROTATION_180;
        } else if (degree >= 240 && degree <= 300) {
          // Use ROTATION_270 when degree range is [240, 300]
          this.rotation = camera.ImageRotation.ROTATION_90;
        }
      });
      this.updatePreview(getPreviewSize(isVideo));
      abilityAccessCtrl.createAtManager().requestPermissionsFromUser(this.context, this.permissions).then(() => {
        setTimeout(async () => {
          // Update preview when window rectangle changed
          this.windowClass?.on('windowRectChange', () => {
            const currFoldStatus = display.getFoldStatus();
            if (currFoldStatus !== this.foldStatus) {
              // Update camera and preview when fold status changed
              this.foldStatus = currFoldStatus;
              cameraShooting(isVideo, cameraPosition, surfaceId, this.context, this.updatePreview);
            } else {
              // Update preview only
              this.updatePreview(getPreviewSize(isVideo));
            }
          });
          zoomRatioRange = await cameraShooting(isVideo, cameraPosition, surfaceId, this.context, this.updatePreview);
        }, 200);
      });
    } catch (error) {
      console.error(`The updatePreview call failed. error: ${JSON.stringify(error)}`);
    }
  }

  aboutToDisappear(): void {
    clearInterval(this.countDownInterval);
    try {
      this.windowClass?.off('windowRectChange');
    } catch (error) {
      console.error(`The aboutToDisappear call failed. error: ${JSON.stringify(error)}`);
    }
    sensor.off(sensor.SensorId.GRAVITY);
  }

  getCalDegree(x: number, y: number, z: number): number {
    let degree: number = -1;
    // three is Effective Delta Angle Threshold Coefficient
    if ((x * x + y * y) * 3 < z * z) {
      return degree;
    }
    degree = 90 - (Number)(Math.round(Math.atan2(y, -x) / Math.PI * 180));
    return degree >= 0 ? degree % 360 : degree % 360 + 360;
  }

  build() {
    RelativeContainer() {
      // Top count down view
      TextTimer({ isCountDown: true, count: this.countDownTime, controller: this.countDownTimeController })
        .contentModifier(this.countDownTimeModifier)
        .visibility(this.isCountingDown ? Visibility.Visible : Visibility.Hidden)
        .size(this.countDownSize)
        .offset(this.countDownOffset)
        .zIndex(1)
        .onClick(() => {
          clearInterval(this.countDownInterval);
          this.isCountingDown = false;
          this.countDownTimeController.reset();
        })

      // Main xComponent view
      XComponent({
        type: XComponentType.SURFACE,
        controller: this.mXComponentController
      })
        .gesture(
          PinchGesture({ fingers: 2 })
            .onActionUpdate((event: GestureEvent) => {
              if (event && !this.isStabilization && !this.isCountingDown) {
                this.zoom = currentFov * event.scale;
                this.isShowZoom = true;
                if (this.zoom > (this.isPhoto ? zoomRatioRange[1] : 15)) {
                  this.zoom = this.isPhoto ? zoomRatioRange[1] : 15;
                } else if (this.zoom < zoomRatioRange[0]) {
                  this.zoom = zoomRatioRange[0];
                }
                this.isPhoto ? setPhotoZoom(this.zoom) : setVideoZoom(this.zoom)
              }
            })
            .onActionEnd(() => {
              this.isPhoto ? currentFov = getPhotoZoom() : currentFov = getVideoZoom();
              this.isShowZoom = false;
            })
        )
        .onLoad(async () => {
          this.mXComponentController.setXComponentSurfaceRotation({ lock: true });
          surfaceId = this.mXComponentController.getXComponentSurfaceId();
        })

      // Option panel
      Row() {
        Image(this.isStabilization ? $r('app.media.stabilization_on') : $r('app.media.stabilization_off'))
          .height(CameraConstants.IMAGE_HEIGHT)
          .margin(CameraConstants.MARGIN)
          .visibility(this.isPhoto || this.isFront ? Visibility.Hidden : Visibility.Visible)
          .rotate({ angle: this.rotation })
          .animation({ curve: curves.springMotion() })
          .onClick(() => {
            this.isStabilization = !this.isStabilization;
            isVideo = true;
            videoRecording(this.isStabilization, cameraPosition, qualityLevel, surfaceId, this.context);
          })
        Image(this.isMovingPhoto ? $r('app.media.live_photo_on') : $r('app.media.live_photo_off'))
          .height(CameraConstants.IMAGE_HEIGHT)
          .margin(CameraConstants.MARGIN)
          .visibility(this.isPhoto && !this.isFront ? Visibility.Visible : Visibility.Hidden)
          .rotate({ angle: this.rotation })
          .animation({ curve: curves.springMotion() })
          .onClick(() => {
            this.isMovingPhoto = !this.isMovingPhoto;
            enableLivePic(this.isMovingPhoto);
          })
        Image(this.flashPic)
          .height(CameraConstants.IMAGE_HEIGHT)
          .margin(CameraConstants.MARGIN)
          .visibility(this.isFront ? Visibility.Hidden : Visibility.Visible)
          .rotate({ angle: this.rotation })
          .animation({ curve: curves.springMotion() })
          .bindMenu(this.isPhoto ? [
            {
              value: 'off',
              action: (): void => {
                this.flashPic = $r('app.media.ic_camera_public_flash_off');
                this.switchFlash(camera.FlashMode.FLASH_MODE_CLOSE);
              }
            },
            {
              value: 'on',
              action: (): void => {
                this.flashPic = $r('app.media.ic_camera_public_flash_on');
                this.switchFlash(camera.FlashMode.FLASH_MODE_OPEN);
              }
            },
            {
              value: 'auto',
              action: (): void => {
                this.flashPic = $r('app.media.ic_camera_public_flash_auto');
                this.switchFlash(camera.FlashMode.FLASH_MODE_AUTO);
              }
            },
            {
              value: 'always_on',
              action: (): void => {
                this.flashPic = $r('app.media.ic_camera_public_flash_always_on');
                this.switchFlash(camera.FlashMode.FLASH_MODE_ALWAYS_OPEN);
              }
            },
          ] :
            [
              {
                value: 'off',
                action: (): void => {
                  this.flashPic = $r('app.media.ic_camera_public_flash_off');
                  this.switchFlash(camera.FlashMode.FLASH_MODE_CLOSE);
                }
              },
              {
                value: 'on',
                action: (): void => {
                  this.flashPic = $r('app.media.ic_camera_public_flash_always_on');
                  this.switchFlash(camera.FlashMode.FLASH_MODE_ALWAYS_OPEN);
                }
              },
            ]
          )
        Image($r('sys.media.ohos_ic_public_clock'))
          .fillColor(Color.White)
          .height(CameraConstants.IMAGE_HEIGHT)
          .margin(CameraConstants.MARGIN)
          .visibility(this.isFront ? Visibility.Hidden : Visibility.Visible)
          .rotate({ angle: this.rotation })
          .animation({ curve: curves.springMotion() })
          .bindMenu(
            [
              {
                value: 'off',
                action: (): void => {
                  storage.setOrCreate('countDownTime', 0);
                }
              },
              {
                value: '2s',
                action: (): void => {
                  storage.setOrCreate('countDownTime', 2000);
                }
              },
              {
                value: '5s',
                action: (): void => {
                  storage.setOrCreate('countDownTime', 5000);
                }
              },
              {
                value: '10s',
                action: (): void => {
                  storage.setOrCreate('countDownTime', 10000);
                }
              },
            ]
          )
        Image(this.isPhoto ? $r('sys.media.ohos_ic_public_more') : $r('app.media.resolution'))
          .fillColor(Color.White)
          .height(CameraConstants.IMAGE_HEIGHT)
          .margin(CameraConstants.MARGIN)
          .visibility(this.isFront ? Visibility.Hidden : Visibility.Visible)
          .rotate({ angle: this.rotation })
          .animation({ curve: curves.springMotion() })
          .bindMenu(
            this.isPhoto ? this.burstCaptureView() :
              [
                {
                  value: '1080P | 60fps',
                  action: (): void => {
                    qualityLevel = 0;
                    stopRecordPreview();
                    videoRecording(this.isStabilization, cameraPosition, qualityLevel, surfaceId, this.context);
                  }
                },
                {
                  value: '2160P | 60fps',
                  action: (): void => {
                    qualityLevel = 1;
                    stopRecordPreview();
                    videoRecording(this.isStabilization, cameraPosition, qualityLevel, surfaceId, this.context);
                  }
                }
              ]
          )
      }
      .id('optionPanel')
      .visibility(this.recording || this.isCountingDown ? Visibility.Hidden : Visibility.Visible)
      .width(CameraConstants.FULL_PERCENT)
      .alignRules({
        top: { anchor: '__container__', align: VerticalAlign.Top }
      })
      .margin({ top: CameraConstants.MARGIN_TOP, bottom: CameraConstants.MARGIN_HEIGHT })
      .justifyContent(FlexAlign.SpaceAround)

      // Top zoom info view
      Text(this.zoom === zoomRatioRange[0] ? 'wide angle' : this.zoom.toFixed(1) + 'x')
        .fontColor(Color.White)
        .visibility(this.isShowZoom && !this.isFront && !this.isCountingDown ? Visibility.Visible : Visibility.Hidden)
        .alignRules({
          bottom: { anchor: 'zoomPanel', align: VerticalAlign.Top },
          middle: { anchor: 'zoomPanel', align: HorizontalAlign.Center }
        })
        .margin({ bottom: $r('app.float.zoom_margin_bottom') })
        .zIndex(1)

      // Zoom panel
      Row() {
        Image(0 < this.zoom && this.zoom < 1 ? $r('app.media.W_0') : $r('app.media.W'))
          .height(CameraConstants.ZOOM_SIZE)
          .rotate({ angle: this.rotation })
          .animation({ curve: curves.springMotion() })
          .onClick(() => {
            this.zoom = zoomRatioRange[0];
            this.setZoom();
          })
        Image($r('app.media.small_2x'))
          .height(CameraConstants.SMALL_DOT)
          .opacity(CameraConstants.OPACITY)
          .margin({ left: CameraConstants.MARGIN_LEFT })
        Image(1 <= this.zoom && this.zoom < 5 ? $r('app.media.1x_0') : $r('app.media.1x'))
          .margin({ left: CameraConstants.MARGIN_LEFT })
          .height(CameraConstants.ZOOM_SIZE)
          .rotate({ angle: this.rotation })
          .animation({ curve: curves.springMotion() })
          .onClick(() => {
            this.zoom = 1;
            this.setZoom();
          })
        Image($r('app.media.small_2x'))
          .margin({ left: CameraConstants.MARGIN_LEFT })
          .height(CameraConstants.SMALL_DOT)
          .opacity(CameraConstants.OPACITY)
        Image(5 <= this.zoom && this.zoom < 10 ? $r('app.media.5x_0') : $r('app.media.5x'))
          .margin({ left: CameraConstants.MARGIN_LEFT })
          .height(CameraConstants.ZOOM_SIZE)
          .rotate({ angle: this.rotation })
          .animation({ curve: curves.springMotion() })
          .onClick(() => {
            this.zoom = 5;
            this.setZoom();
          })
        Image($r('app.media.small_2x'))
          .margin({ left: CameraConstants.MARGIN_LEFT })
          .height(CameraConstants.SMALL_DOT)
          .opacity(CameraConstants.OPACITY)
        Image(this.zoom >= 10 ? $r('app.media.10x_0') : $r('app.media.10x'))
          .margin({ left: CameraConstants.MARGIN_LEFT })
          .height(CameraConstants.ZOOM_SIZE)
          .rotate({ angle: this.rotation })
          .animation({ curve: curves.springMotion() })
          .onClick(() => {
            this.zoom = 10;
            this.setZoom();
          })
      }
      .id('zoomPanel')
      .visibility(this.isFront || this.isStabilization || this.isCountingDown ? Visibility.Hidden : Visibility.Visible)
      .alignRules({
        bottom: { anchor: 'modePanel', align: VerticalAlign.Top },
        middle: { anchor: 'modePanel', align: HorizontalAlign.Center }
      })
      .margin({ bottom: $r('app.float.zoom_margin_bottom') })

      // Mode panel
      Row() {
        Text($r('app.string.Photo'))
          .fontColor(this.isPhoto ? Color.White : Color.Gray)
          .rotate({ angle: this.rotation === camera.ImageRotation.ROTATION_180 ? this.rotation : 0 })
          .animation({ curve: curves.springMotion() })
          .onClick(async () => {
            if (!this.isPhoto) {
              this.isPhoto = true;
              isVideo = false;
              stopRecordPreview();
              this.Initialize();
              cameraShooting(isVideo, cameraPosition, surfaceId, this.context, this.updatePreview);
            }
          })
        Text($r('app.string.Video'))
          .fontColor(this.isPhoto ? Color.Gray : Color.White)
          .rotate({ angle: this.rotation === camera.ImageRotation.ROTATION_180 ? this.rotation : 0 })
          .animation({ curve: curves.springMotion() })
          .onClick(() => {
            if (this.isPhoto) {
              this.isPhoto = false;
              isVideo = true;
              releaseCamera();
              // 1080P
              this.Initialize();
              videoRecording(this.isStabilization, cameraPosition, qualityLevel, surfaceId, this.context,
                this.updatePreview);
            }
          })
      }
      .id('modePanel')
      .visibility(this.recording || this.isCountingDown ? Visibility.Hidden : Visibility.Visible)
      .justifyContent(FlexAlign.SpaceAround)
      .width(CameraConstants.CENTER_WIDTH)
      .height(CameraConstants.CAPTURE_SIZE)
      .alignRules({
        bottom: { anchor: 'controlPanel', align: VerticalAlign.Top },
        middle: { anchor: 'controlPanel', align: HorizontalAlign.Center }
      })
      .margin({ bottom: $r('app.float.mode_margin_bottom') })

      // Control panel
      Row() {
        Image(this.photoUri)
          .borderWidth(this.photoUri === '' ? 0 : 1)
          .visibility(this.recording ? Visibility.Hidden : Visibility.Visible)
          .borderColor(Color.White)
          .height(CameraConstants.CAMERA_SWITCH_SIZE)
          .width(CameraConstants.CAMERA_SWITCH_SIZE)
          .borderRadius(CameraConstants.CAMERA_SWITCH_SIZE / 2)
          .rotate({ angle: this.rotation })
          .animation({ curve: curves.springMotion() })
          .onClick(() => {
            if (this.photoUri !== '') {
              this.currentPic ? previewPhoto(this.context) : previewVideo(this.context, videoUri);
            }
          })
        Stack() {
          Image($r('app.media.capture'))
            .height(CameraConstants.CAPTURE_SIZE)
            .visibility(this.isPhoto ? Visibility.Visible : Visibility.Hidden)
            .onClick(() => {
              if (this.countDownTime !== 0) {
                this.isCountingDown = true;
                this.countDownTimeController.start();
              }
              this.countDownInterval = setTimeout(() => {
                this.isCountingDown = false;
                this.countDownTimeController.reset();
                this.customCapture();
                this.currentPic = true;
              }, this.countDownTime);
            })
          Image($r('app.media.record'))
            .height(CameraConstants.CAPTURE_SIZE)
            .visibility(this.isPhoto ? Visibility.Hidden : this.recording ? Visibility.Hidden : Visibility.Visible)
            .onClick(async () => {
              if (this.countDownTime !== 0) {
                this.isCountingDown = true;
                this.countDownTimeController.start();
              }
              this.countDownInterval = setTimeout(() => {
                this.isCountingDown = false;
                this.countDownTimeController.reset();
                startRecord();
                this.textTimerController.start();
                this.recording = true;
              }, this.countDownTime);
            })
          Image($r('app.media.recording'))
            .visibility(this.isPhoto ? Visibility.Hidden : this.recording ? Visibility.Visible : Visibility.Hidden)
            .height(CameraConstants.CAPTURE_SIZE)
            .onClick(async () => {
              this.textTimerController.reset();
              this.recording = false;
              this.currentPic = false;
              this.zoom = 1;
              currentFov = 1;
              this.flashPic = $r('app.media.ic_camera_public_flash_off');
              videoUri = await stopRecord();
              stopRecordPreview();
              videoRecording(this.isStabilization, cameraPosition, qualityLevel, surfaceId, this.context);
              setTimeout(() => {
                this.getThumbnail();
              }, 500);
            })
        }

        Image($r('app.media.switch_camera'))
          .height(CameraConstants.CAMERA_SWITCH_SIZE)
          .visibility(this.recording ? Visibility.Hidden : Visibility.Visible)
          .rotate({ angle: this.rotation })
          .animation({ curve: curves.springMotion() })
          .onClick(async () => {
            cameraPosition = cameraPosition === camera.CameraPosition.CAMERA_POSITION_BACK ?
              camera.CameraPosition.CAMERA_POSITION_UNSPECIFIED : camera.CameraPosition.CAMERA_POSITION_BACK;
            if (this.isPhoto) {
              cameraShooting(isVideo, cameraPosition, surfaceId, this.context, this.updatePreview);
            } else {
              stopRecordPreview();
              videoRecording(this.isStabilization, cameraPosition, qualityLevel, surfaceId, this.context,
                this.updatePreview);
            }
            this.Initialize();
            this.isFront = cameraPosition !== 0;
          })
      }
      .id('controlPanel')
      .visibility(this.isCountingDown ? Visibility.Hidden : Visibility.Visible)
      .width(CameraConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceAround)
      .alignRules({
        bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
      })
      .margin({ bottom: $r('app.float.control_margin_bottom') })

      TextTimer({ controller: this.textTimerController })
        .format(CameraConstants.TIME_FORMAT)
        .fontColor(Color.White)
        .fontSize(CameraConstants.MARGIN_TOP)
        .visibility(this.recording ? Visibility.Visible : Visibility.Hidden)
        .alignRules({
          top: { anchor: 'controlPanel', align: VerticalAlign.Bottom },
          middle: { anchor: 'controlPanel', align: HorizontalAlign.Center }
        })
    }
    .height(CameraConstants.FULL_PERCENT)
    .backgroundColor(Color.Black)
  }

  Initialize(): void {
    this.zoom = 1;
    currentFov = 1;
    this.isStabilization = false;
    this.flashPic = $r('app.media.ic_camera_public_flash_off');
    this.isMovingPhoto = false;
  }

  switchFlash(flashMode: number): void {
    this.isPhoto ? setPhotoFlashMode(flashMode) : setVideoFlashMode(flashMode);
  }

  setZoom(): void {
    currentFov = this.zoom;
    this.isPhoto ? setPhotoSmoothZoom(this.zoom) : setVideoSmoothZoom(this.zoom);
  }

  customCapture(): void {
    if (this.isBurstCapture) {
      burstCapture(this.isFront, this.burstCaptureCount);
    } else {
      capture(this.isFront);
    }
  }

  async getThumbnail(): Promise<void> {
    let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    predicates.orderByDesc(photoAccessHelper.PhotoKeys.DATE_ADDED);
    let fetchOptions: photoAccessHelper.FetchOptions = {
      fetchColumns: [],
      predicates: predicates
    };
    let photoHelper = photoAccessHelper.getPhotoAccessHelper(this.context);
    try {
      let fetchResult: photoAccessHelper.FetchResult<photoAccessHelper.PhotoAsset> =
        await photoHelper.getAssets(fetchOptions);
      if (fetchResult !== undefined) {
        let photoAsset: photoAccessHelper.PhotoAsset = await fetchResult.getFirstObject();
        this.photoUri = await photoAsset.getThumbnail();
      }
    } catch (error) {
      console.error(`The getThumbnail call failed. error: ${JSON.stringify(error)}`);
    }
  }

  updatePreview = (previewSize: Size) => {
    const windowSize = getCurrentWindowSize();
    // Use setXComponentSurfaceRect to adjust preview size and position
    this.mXComponentController.setXComponentSurfaceRect({
      surfaceWidth: previewSize.width,
      surfaceHeight: previewSize.height,
      offsetY: previewSize.height >= windowSize.height ? 0 : this.getUIContext().vp2px(DEFAULT_TOP_OFFSET)
    });

    // Adjust count down view size and position to match preview
    this.countDownOffset = {
      x: previewSize.width >= windowSize.width ?
        0 : this.getUIContext().px2vp((windowSize.width - previewSize.width) / 2),
      y: previewSize.height >= windowSize.height ? 0 : DEFAULT_TOP_OFFSET
    };
    this.countDownSize = {
      width: this.getUIContext().px2vp(previewSize.width),
      height: this.getUIContext().px2vp(previewSize.height)
    };
  }
}

export async function fromBack(context: Context): Promise<void> {
  storage.setOrCreate('flashPic', $r('app.media.ic_camera_public_flash_off'));
  storage.setOrCreate('zoom', 1);
  currentFov = 1;
  storage.setOrCreate('isStabilization', false);
  storage.setOrCreate('isMovingPhoto', false);
  storage.setOrCreate('countDownTime', 0);
  storage.setOrCreate('isBurstCapture', false);
  storage.setOrCreate('burstCaptureCount', CameraConstants.BURST_CAPTURE_MIN_COUNT);
  cameraShooting(isVideo, cameraPosition, surfaceId, context);
}