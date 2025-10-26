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

import { curves } from '@kit.ArkUI';
import { camera } from '@kit.CameraKit';
import { BreakpointType } from '../utils/BreakpointType';
import { CameraUtil } from '../utils/CameraUtil';

@Component
export struct ChooseMusic {
  @StorageLink('heightBp') heightBp: HeightBreakpoint = HeightBreakpoint.HEIGHT_SM;

  build() {
    Row() {
      Image($r('app.media.icon_music'))
        .width(this.heightBp === HeightBreakpoint.HEIGHT_MD ? 12 : 16)
        .height(this.heightBp === HeightBreakpoint.HEIGHT_MD ? 12 : 16)
        .margin({ right: 10 })
      Text($r('app.string.choose_music'))
        .fontSize(16)
        .lineHeight(21)
        .fontColor(Color.White)
    }
    .width(140)
    .height(40)
    .backgroundColor('#1AFFFFFF')
    .justifyContent(FlexAlign.Center)
    .borderRadius(8)
  }
}

@Component
export struct SettingButton {
  @StorageLink('heightBp') heightBp: HeightBreakpoint = HeightBreakpoint.HEIGHT_SM;
  @StorageLink('widthBp') widthBp: WidthBreakpoint = WidthBreakpoint.WIDTH_SM;
  imageButton?: Resource;
  text?: Resource;

  build() {
    Column() {
      Image(this.imageButton)
        .height(new BreakpointType((this.heightBp === HeightBreakpoint.HEIGHT_LG ? 48 : 30), 48,
          48).getValue(this.widthBp))
        .width(new BreakpointType((this.heightBp === HeightBreakpoint.HEIGHT_LG ? 48 : 30), 48,
          48).getValue(this.widthBp))
        .margin({ bottom: 2 })
      Text(this.text)
        .lineHeight(new BreakpointType((this.heightBp === HeightBreakpoint.HEIGHT_LG ? 16 : 14), 16,
          16).getValue(this.widthBp))
        .fontSize(new BreakpointType((this.heightBp === HeightBreakpoint.HEIGHT_LG ? 12 : 10), 12,
          12).getValue(this.widthBp))
        .fontColor(Color.White)
    }
    .width(52 )
    .margin({
      bottom: new BreakpointType((this.heightBp === HeightBreakpoint.HEIGHT_LG ? 16 : 8), 16, 16).getValue(this.widthBp)
    })
  }
}

@Component
export struct ShotAreaSm {
  @StorageLink('heightBp') heightBp: HeightBreakpoint = HeightBreakpoint.HEIGHT_SM;
  @StorageLink('photoUri') photoUri: string | Resource | PixelMap = '';
  @StorageLink('surfaceId') surfaceId: string = '';
  @StorageLink('cameraUtil') cameraUtil: CameraUtil = new CameraUtil();
  context?: Context = this.getUIContext().getHostContext();

  build() {
    Column() {
      // Photo and video mode.
      Column() {
        Row() {
          Column() {
            Text($r('app.string.photo'))
              .fontSize(14)
              .lineHeight(20)
              .fontColor(Color.White)
              .fontWeight(700)
              .margin({ bottom: 6 })
            Image($r('app.media.icon_red_circle'))
              .height(6)
              .width(6)
          }
          .height('100%')
          .width(40)

          Blank()

          Text($r('app.string.video'))
            .fontSize(14)
            .lineHeight(20)
            .fontColor(Color.White)
            .width(40)
        }
        .height(32)
        .width(this.heightBp === HeightBreakpoint.HEIGHT_LG ? 102 : 94)
        .alignItems(VerticalAlign.Top)
      }
      .width(this.heightBp === HeightBreakpoint.HEIGHT_LG ? 80 : 72)
      .height(32)
      .margin({ bottom: this.heightBp === HeightBreakpoint.HEIGHT_LG ? 24 : 16 })

      // Shooting button.
      Row() {
        Image(this.photoUri)
          .width(this.heightBp === HeightBreakpoint.HEIGHT_LG ? 44 : 28)
          .height(this.heightBp === HeightBreakpoint.HEIGHT_LG ? 44 : 28)
          .borderWidth(this.photoUri === '' ? 0 : 1)
          .borderColor(Color.White)
          .borderRadius(44)
          .animation({ curve: curves.springMotion() })
          .onClick(() => {
            if (this.photoUri !== '') {
              this.cameraUtil.previewPhoto();
            }
          })
        Image($r('app.media.icon_shoot'))
          .width(this.heightBp === HeightBreakpoint.HEIGHT_LG ? 76 : 46)
          .height(this.heightBp === HeightBreakpoint.HEIGHT_LG ? 76 : 46)
          .onClick(() => {
            this.cameraUtil.capture();
          })
        Image($r('app.media.icon_flip'))
          .width(this.heightBp === HeightBreakpoint.HEIGHT_LG ? 44 : 28)
          .height(this.heightBp === HeightBreakpoint.HEIGHT_LG ? 44 : 28)
          .onClick(() => {
            let isFront: boolean | undefined = AppStorage.get('isFront');
            if (isFront) {
              this.cameraUtil.cameraShooting(this.surfaceId, this.context!,
                camera.CameraPosition.CAMERA_POSITION_BACK);
              return;
            }
            this.cameraUtil.cameraShooting(this.surfaceId, this.context!, camera.CameraPosition.CAMERA_POSITION_FRONT);
          })
      }
      .width(this.heightBp === HeightBreakpoint.HEIGHT_LG ? 256 : 158)
      .height(this.heightBp === HeightBreakpoint.HEIGHT_LG ? 76 : 46)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height(this.heightBp === HeightBreakpoint.HEIGHT_LG ? 132 : 94)
    .margin({ bottom: this.heightBp === HeightBreakpoint.HEIGHT_LG ? 84 : 16 })
  }
}

@Component
export struct ShotArea {
  @StorageLink('heightBp') heightBp: HeightBreakpoint = HeightBreakpoint.HEIGHT_SM;
  @StorageLink('widthBp') widthBp: WidthBreakpoint = WidthBreakpoint.WIDTH_SM;
  @StorageLink('photoUri') photoUri: string | Resource | PixelMap = '';
  @StorageLink('surfaceId') surfaceId: string = '';
  @StorageLink('cameraUtil') cameraUtil: CameraUtil = new CameraUtil();
  context?: Context = this.getUIContext().getHostContext();

  build() {
    Stack() {
      Column() {
        Image($r('app.media.icon_flip'))
          .width(44)
          .height(44)
          .onClick(() => {
            let isFront: boolean | undefined = AppStorage.get('isFront');
            if (isFront) {
              this.cameraUtil.cameraShooting(this.surfaceId, this.context!,
                camera.CameraPosition.CAMERA_POSITION_BACK);
              return;
            }
            this.cameraUtil.cameraShooting(this.surfaceId, this.context!, camera.CameraPosition.CAMERA_POSITION_FRONT);
          })
        Image($r('app.media.icon_shoot'))
          .width(76)
          .height(76)
          .onClick(() => {
            this.cameraUtil.capture();
          })
        Image(this.photoUri)
          .width(44)
          .height(44)
          .borderWidth(this.photoUri === '' ? 0 : 1)
          .borderColor(Color.White)
          .borderRadius(22)
          .animation({ curve: curves.springMotion() })
          .onClick(() => {
            if (this.photoUri !== '') {
              this.cameraUtil.previewPhoto();
            }
          })
      }
      .height(288)
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

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
      .width('100%')
      .height(56)
      .alignItems(HorizontalAlign.Center)
      .position({ x: 0, y: 416 })
    }
    .height(472)
    .width('100%')
    .alignContent(Alignment.Center)
  }
}

@Component
export struct ShotAreaHalfFolded {
  @StorageLink('heightBp') heightBp: HeightBreakpoint = HeightBreakpoint.HEIGHT_SM;
  @StorageLink('widthBp') widthBp: WidthBreakpoint = WidthBreakpoint.WIDTH_SM;
  @StorageLink('photoUri') photoUri: string | Resource | PixelMap = '';
  @StorageLink('surfaceId') surfaceId: string = '';
  @StorageLink('cameraUtil') cameraUtil: CameraUtil = new CameraUtil();
  context?: Context = this.getUIContext().getHostContext();

  build() {
    Column() {
      Image($r('app.media.icon_flip'))
        .width(44)
        .height(44)
        .onClick(() => {
          let isFront: boolean | undefined = AppStorage.get('isFront');
          if (isFront) {
            this.cameraUtil.cameraShooting(this.surfaceId, this.context!, camera.CameraPosition.CAMERA_POSITION_BACK);
            return;
          }
          this.cameraUtil.cameraShooting(this.surfaceId, this.context!, camera.CameraPosition.CAMERA_POSITION_FRONT);
        })
      Image($r('app.media.icon_shoot'))
        .width(76)
        .height(76)
        .onClick(() => {
          this.cameraUtil.capture();
        })
      Image(this.photoUri)
        .width(44)
        .height(44)
        .borderWidth(this.photoUri === '' ? 0 : 1)
        .borderColor(Color.White)
        .borderRadius(22)
        .animation({ curve: curves.springMotion() })
        .onClick(() => {
          if (this.photoUri !== '') {
            this.cameraUtil.previewPhoto();
          }
        })
    }
    .height(236)
    .width(76)
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ right: 24 })
  }
}