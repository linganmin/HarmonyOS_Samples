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

import { abilityAccessCtrl, Permissions } from '@kit.AbilityKit';
import { display, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { camera } from '@kit.CameraKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { ChooseMusic, SettingButton, ShotArea, ShotAreaHalfFolded, ShotAreaSm } from '../views/CommonView';
import { CameraUtil } from '../utils/CameraUtil';
import { WindowUtil } from '../utils/WindowUtil';

@Entry
@Component
struct Index {
  @StorageLink('widthBp') widthBp: WidthBreakpoint = WidthBreakpoint.WIDTH_SM;
  @StorageLink('heightBp') heightBp: HeightBreakpoint = HeightBreakpoint.HEIGHT_SM;
  @StorageLink('windowSize') windowSize: window.Size = { width: 0, height: 0 };
  @StorageLink('displayOrientation') displayOrientation: display.Orientation =
    display.getDefaultDisplaySync().orientation;
  @StorageLink('photoUri') photoUri: string | Resource | PixelMap = '';
  @StorageLink('surfaceId') surfaceId: string = '';
  @StorageLink('isFront') isFront: boolean = false;
  @StorageLink('isHalfFolded') isHalfFolded: boolean = false;
  @StorageLink('oldFoldStatus') oldFoldStatus: display.FoldStatus = display.FoldStatus.FOLD_STATUS_UNKNOWN;
  @StorageLink('creaseRegion') creaseRegion: number[] = [];
  @StorageLink('windowUtil') windowUtil: WindowUtil = new WindowUtil();
  @StorageLink('cameraUtil') cameraUtil: CameraUtil = new CameraUtil();
  context?: Context = this.getUIContext().getHostContext();
  xComponentController: XComponentController = new XComponentController();
  permissions: Array<Permissions> = [
    'ohos.permission.CAMERA',
    'ohos.permission.READ_IMAGEVIDEO',
    'ohos.permission.WRITE_IMAGEVIDEO'
  ];
  // [Start FoldStatusChange]
  // [Start SelectCamera2]
  onFoldStatusChange: (foldStatus: display.FoldStatus) => void = (foldStatus: display.FoldStatus) => {
    if (foldStatus === display.FoldStatus.FOLD_STATUS_HALF_FOLDED) {
      let orientation: display.Orientation = display.getDefaultDisplaySync().orientation;
      // Determine the page layout that has entered half folded status and prohibit portrait orientation.
      if (this.widthBp === WidthBreakpoint.WIDTH_MD && (orientation === display.Orientation.LANDSCAPE ||
        orientation === display.Orientation.LANDSCAPE_INVERTED)) {
        this.isHalfFolded = true;
        this.windowUtil.setMainWindowOrientation(window.Orientation.LANDSCAPE);
        this.cameraUtil.setHalfFoldedRect(this.windowUtil.getWindowSize());
      } else {
        if (this.oldFoldStatus === display.FoldStatus.FOLD_STATUS_FOLDED) {
          if (this.isFront) {
            this.cameraUtil.cameraShooting(this.surfaceId, this.context!, camera.CameraPosition.CAMERA_POSITION_FRONT);
          } else {
            this.cameraUtil.cameraShooting(this.surfaceId, this.context!, camera.CameraPosition.CAMERA_POSITION_BACK);
          }
        }
      }
      return;
    }
    // [StartExclude SelectCamera2]
    if (this.widthBp !== WidthBreakpoint.WIDTH_SM) {
      this.windowUtil.setMainWindowOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED);
    }
    // [EndExclude SelectCamera2]
    // Exit the half folded status page.
    if (this.isHalfFolded) {
      this.isHalfFolded = false;
      this.cameraUtil.setXComponentRect(this.windowUtil.getWindowSize());
    } else {
      if (foldStatus === display.FoldStatus.FOLD_STATUS_FOLDED ||
        (this.oldFoldStatus === display.FoldStatus.FOLD_STATUS_EXPANDED_WITH_SECOND_HALF_FOLDED &&
          foldStatus === display.FoldStatus.FOLD_STATUS_EXPANDED) ||
        (this.oldFoldStatus === display.FoldStatus.FOLD_STATUS_EXPANDED &&
          foldStatus === display.FoldStatus.FOLD_STATUS_EXPANDED_WITH_SECOND_HALF_FOLDED)) {
        if (this.isFront) {
          this.cameraUtil.cameraShooting(this.surfaceId, this.context!, camera.CameraPosition.CAMERA_POSITION_FRONT);
        } else {
          this.cameraUtil.cameraShooting(this.surfaceId, this.context!, camera.CameraPosition.CAMERA_POSITION_BACK);
        }
      }
    }
    // [StartExclude SelectCamera2]
    this.oldFoldStatus = foldStatus;
    // [EndExclude SelectCamera2]
  }
  // [End FoldStatusChange]

  aboutToAppear(): void {
    try {
      display.on('foldStatusChange', this.onFoldStatusChange);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'MultiDeviceCamera', `Failed to obtain fold status. Code: ${err.code}, message: ${err.message}`);
    }
  }
  // [End SelectCamera2]

  // [Start SelectCamera1]
  onPageShow(): void {
    abilityAccessCtrl.createAtManager().requestPermissionsFromUser(this.context, this.permissions).then(() => {
      setTimeout(() => {
        // After obtaining permission, load the camera preview stream and ensure it is consistent with the aspect ratio of the surface.
        // [StartExclude SelectCamera1]
        this.cameraUtil.setSurfaceProfile(this.xComponentController, this.getUIContext());
        // [EndExclude SelectCamera1]
        if (this.isFront) {
          this.cameraUtil.cameraShooting(this.surfaceId, this.context!, camera.CameraPosition.CAMERA_POSITION_FRONT);
        } else {
          this.cameraUtil.cameraShooting(this.surfaceId, this.context!, camera.CameraPosition.CAMERA_POSITION_BACK);
        }
      }, 200);
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, 'testTag', `Failed to requestPermissionsFromUser. Code: ${err.code}, message: ${err.message}`);
    })
  }
  // [End SelectCamera1]

  aboutToDisappear(): void {
    try {
      display.off('foldStatusChange');
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'MultiDeviceCamera', `Failed to requestPermissionsFromUser. Code: ${err.code}, message: ${err.message}`);
    }
    this.windowUtil.offWindowSizeChange();
  }

  build() {
    Navigation() {
      // [Start Bp1]
      // [Start CameraPage]
      Stack() {
        // Camera View.
        Column() {
          // [Start SetSurfaceRotation]
          // [Start Preview3]
          XComponent({
            type: XComponentType.SURFACE,
            controller: this.xComponentController
          }) {}
          // [StartExclude Bp1]
          // [StartExclude CameraPage]
          .onLoad(() => {
            // [StartExclude Preview3]
            // [StartExclude SetSurfaceRotation]
            this.surfaceId = this.xComponentController.getXComponentSurfaceId();
            // [EndExclude Preview3]
            // [EndExclude SetSurfaceRotation]
            // Set surface to lock direction when screen rotates.
            this.xComponentController.setXComponentSurfaceRotation({ lock: true });
          })
          // [End Preview3]
          // [End SetSurfaceRotation]
          .onDestroy(() => {
            // Release camera session and streams.
            this.cameraUtil?.releaseCamera();
          })
          .width('100%')
          .height(this.isHalfFolded ? this.creaseRegion[0] : '100%')
          // [EndExclude CameraPage]
          // [EndExclude Bp1]
        }
        // [StartExclude CameraPage]
        .width('100%')
        .height(this.isHalfFolded ? this.creaseRegion[0] : '')
        .layoutWeight(this.isHalfFolded ? 0 : 1)
        // [StartExclude Bp1]
        .margin({ bottom: (this.getUIContext().px2vp(this.windowSize.width) /
          this.getUIContext().px2vp(this.windowSize.height) < 0.5) && this.widthBp === WidthBreakpoint.WIDTH_SM ?
          156 : 0 })
        // [EndExclude CameraPage]
        // [EndExclude Bp1]

        // Shooting button view.
        Stack() {
          // Setting view for sm.
          Column() {
            // [StartExclude Bp1]
            // [StartExclude CameraPage]
            SettingButton({
              imageButton: $r('app.media.icon_lighting'),
              text: $r('app.string.flashlight')
            })
            SettingButton({
              imageButton: $r('app.media.icon_filters'),
              text: $r('app.string.filter')
            })
            SettingButton({
              imageButton: $r('app.media.icon_setting'),
              text: $r('app.string.setting')
            })
            // [EndExclude CameraPage]
            // [EndExclude Bp1]
          }
          // [StartExclude CameraPage]
          .width(this.heightBp === HeightBreakpoint.HEIGHT_MD ? 30 : 48)
          .height('100%')
          .margin({ right: 16 })
          .padding({ top: this.heightBp === HeightBreakpoint.HEIGHT_MD ? 16 : 108 })
          // [EndExclude CameraPage]
          .visibility(this.widthBp === WidthBreakpoint.WIDTH_SM ? Visibility.Visible : Visibility.None)

          // Choose music for sm.
          Row() {
            // [StartExclude Bp1]
            // [StartExclude CameraPage]
            Image($r('app.media.icon_close'))
              .width(this.heightBp === HeightBreakpoint.HEIGHT_MD ? 28 : 40)
              .height(this.heightBp === HeightBreakpoint.HEIGHT_MD ? 28 : 40)
              .position({ x: 16, y: 0 })

            ChooseMusic()
            // [EndExclude CameraPage]
            // [EndExclude Bp1]
          }
          .width('100%')
          .height(this.heightBp === HeightBreakpoint.HEIGHT_MD ? 28 : 40)
          .position({
            x: 0,
            y: this.heightBp === HeightBreakpoint.HEIGHT_MD ? 16 : 28
          })
          .justifyContent(FlexAlign.Center)
          .visibility(this.widthBp === WidthBreakpoint.WIDTH_SM ? Visibility.Visible : Visibility.None)

          // Shooting button for sm.
          Column() {
            // [StartExclude Bp1]
            // [StartExclude CameraPage]
            ShotAreaSm()
            // [EndExclude CameraPage]
            // [EndExclude Bp1]
          }
          .visibility(this.widthBp === WidthBreakpoint.WIDTH_SM ? Visibility.Visible : Visibility.None)
          .height(this.heightBp === HeightBreakpoint.HEIGHT_MD ? 96 : 132)
          .width('100%')
          .margin({ bottom: this.heightBp === HeightBreakpoint.HEIGHT_MD ? 16 : 84 })

          // Setting view for md/lg.
          Column() {
            // [StartExclude Bp1]
            // [StartExclude CameraPage]
            Column() {
              Image($r('app.media.icon_close'))
                .width(40)
                .height(40)
            }
            .width(40)
            .layoutWeight(1)
            .padding({ top: this.widthBp === WidthBreakpoint.WIDTH_MD ? 24 : 32 })

            Column() {
              Blank()
              SettingButton({
                imageButton: $r('app.media.icon_lighting'),
                text: $r('app.string.flashlight')
              })
              SettingButton({
                imageButton: $r('app.media.icon_filters'),
                text: $r('app.string.filter')
              })
              SettingButton({
                imageButton: $r('app.media.icon_setting'),
                text: $r('app.string.setting')
              })
              Blank()
            }
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Start)
            .width(48)

            Column() {
              ChooseMusic()
            }
            .layoutWeight(1)
            .width('100%')
            .padding({ top: this.heightBp === HeightBreakpoint.HEIGHT_MD ? 72 : 60 })
            // [EndExclude CameraPage]
            // [EndExclude Bp1]
          }
          .width(this.widthBp === WidthBreakpoint.WIDTH_MD ? 144 : 152)
          .height('100%')
          .justifyContent(FlexAlign.Start)
          .padding({ left: this.heightBp === HeightBreakpoint.HEIGHT_MD ? 24 : 32 })
          .position({ x: 0, y: 0 })
          .alignItems(HorizontalAlign.Start)
          .visibility(this.widthBp === WidthBreakpoint.WIDTH_MD || this.widthBp === WidthBreakpoint.WIDTH_LG ?
            Visibility.Visible : Visibility.None)

          // Shooting button for md/lg.
          Column() {
            // [StartExclude Bp1]
            // [StartExclude CameraPage]
            ShotArea()
            // [EndExclude CameraPage]
            // [EndExclude Bp1]
          }
          .width(92)
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .padding({ right: 16 })
          .visibility(this.widthBp === WidthBreakpoint.WIDTH_MD || this.widthBp === WidthBreakpoint.WIDTH_LG ?
            Visibility.Visible : Visibility.None)
        }
        .height('100%')
        .width('100%')
        .alignContent(Alignment.BottomEnd)
        .visibility(this.isHalfFolded ? Visibility.None : Visibility.Visible)
        // [StartExclude CameraPage]
        // [StartExclude Bp1]

        // Half folded view.
        Stack() {
          Row() {
            SettingButton({
              imageButton: $r('app.media.icon_lighting'),
              text: $r('app.string.flashlight')
            })
            SettingButton({
              imageButton: $r('app.media.icon_filters'),
              text: $r('app.string.filter')
            })
              .margin({
                left: 16,
                right: 16
              })
            SettingButton({
              imageButton: $r('app.media.icon_setting'),
              text: $r('app.string.setting')
            })
          }
          .width('100%')
          .height(72)
          .padding({ top: 6 })
          .justifyContent(FlexAlign.Center)
          .position({ x: 0, y: this.creaseRegion[0] + this.creaseRegion[1] })

          Row() {
            ChooseMusic()
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding({ bottom: 32 })

          Column() {
            Image($r('app.media.icon_close'))
              .width(40)
              .height(40)
              .position({ x: 0, y: this.creaseRegion[0] + this.creaseRegion[1] })

            Column() {
              Row() {
                Text($r('app.string.photo'))
                  .fontSize(14)
                  .fontColor(Color.White)
                  .fontWeight(700)
                Blank()
                Image($r('app.media.icon_red_circle'))
                  .height(6)
                  .width(6)
              }
              .height(20)
              .width(40)
              .margin({ bottom: 16 })

              Text($r('app.string.video'))
                .fontSize(14)
                .fontColor('#80FFFFFF')
                .width(40)
            }
            .width(40)
            .height(56)
            .position({ x: 0, y: this.creaseRegion[0] + this.creaseRegion[1] + 108 })
          }
          .width(64)
          .padding({ left: 24 })
          .position({ x: 0, y: 0 })

          ShotAreaHalfFolded()
            .position({ x: this.creaseRegion[2] - 100, y: this.creaseRegion[0] + this.creaseRegion[1] + 24 })
        }
        .width('100%')
        .height('100%')
        .alignContent(Alignment.BottomEnd)
        .visibility(this.isHalfFolded ? Visibility.Visible : Visibility.None)
        // [EndExclude CameraPage]
        // [EndExclude Bp1]
      }
      .height('100%')
      .width('100%')
      .alignContent(this.widthBp === WidthBreakpoint.WIDTH_MD ? (this.isHalfFolded ? Alignment.Top : Alignment.Start) :
        Alignment.Center)
      // [End CameraPage]
      // [End Bp1]
    }
    .height('100%')
    .width('100%')
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .hideToolBar(true)
    .backgroundColor(Color.Black)
  }
}