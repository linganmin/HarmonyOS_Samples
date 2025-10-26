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

import { AvPlayerController } from '../controller/AvPlayerController';

// Index of the playback rate list.
const ZERO = 0;
const ONE = 1;
const TWO = 2;
const THREE = 3;

// [Start video_speed_dialog]
/**
 * Set speed dialog
 */
@CustomDialog
export struct SpeedDialog {
  @State speedList: Resource[] =
    [$r('app.string.video_speed_1_0X'), $r('app.string.video_speed_1_25X'), $r('app.string.video_speed_1_75X'),
      $r('app.string.video_speed_2_0X')];
  @Link speedSelect: number; // Index of the current selection
  @Link speedIndex: number; // Index of the playback rate list.
  @Link speedName: Resource;
  @Link avPlayerController: AvPlayerController;
  private controller: CustomDialogController;

  build() {
    Column() {
      Text($r('app.string.dialog_play_speed'))
        .fontSize($r('app.float.size_20'))
        .fontWeight(FontWeight.Bold)
        .width('90%')
        .fontColor($r('app.color.dialog_title_color'))
        .textAlign(TextAlign.Center)
        .margin({ top: $r('app.float.size_20'), bottom: $r('app.float.size_12') })

      List() {
        ForEach(this.speedList, (item: Resource, index) => {
          ListItem() {
            Column() {
              Row() {
                Text(item)
                  .fontSize($r('app.float.size_16'))
                  .fontColor($r('app.color.dialog_text_color'))
                  .fontWeight(FontWeight.Medium)
                  .textAlign(TextAlign.Center)

                Blank()
                Image(this.speedSelect == index ? $r('app.media.ic_radio_selected') :
                $r('app.media.ic_radio'))
                  .width($r('app.float.size_24'))
                  .height($r('app.float.size_24'))
                  .objectFit(ImageFit.Contain)

              }
              .width('100%')

              if (index != this.speedList.length - ONE) {
                Divider()
                  .vertical(false)
                  .strokeWidth(1)
                  .margin({ top: $r('app.float.size_10') })
                  .color($r('app.color.speed_dialog'))
                  .width('100%')
              }
            }
            .width('90%')
          }
          .width('100%')
          .height($r('app.float.size_48'))
          .onClick(() => {
            this.speedSelect = index;
            this.speedIndex = this.speedSelect;
            this.speedName = this.speedList[this.speedSelect];
            switch (this.speedSelect) {
              case ZERO:
                this.avPlayerController.videoSpeedOne();
                break;
              case ONE:
                this.avPlayerController.videoSpeedOnePointTwentyFive();
                break;
              case TWO:
                this.avPlayerController.videoSpeedOnePointSeventyFive();
                break;
              case THREE:
                this.avPlayerController.videoSpeedTwo();
                break;
              default:
                break;
            }
            this.controller.close();
          })
        }, (item: Resource, index) => index + '_' + JSON.stringify(item))
      }
      .width('100%')
      .height('192vp')
      .margin({
        top: $r('app.float.size_12')
      })

      Row() {
        Text($r('app.string.dialog_cancel'))
          .fontSize($r('app.float.size_16'))
          .fontColor($r('app.color.dialog_cancel_color'))
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.controller.close();
          })
      }
      .alignItems(VerticalAlign.Center)
      .height($r('app.float.size_50'))
      .padding({ bottom: $r('app.float.size_5') })
      .width('100%')

    }
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .margin({ left: $r('app.float.size_16'), right: $r('app.float.size_16') })
    .borderRadius($r('app.float.size_24'))
    .backgroundColor($r('app.color.dialog_background_color'))
  }
}

// [End video_speed_dialog]