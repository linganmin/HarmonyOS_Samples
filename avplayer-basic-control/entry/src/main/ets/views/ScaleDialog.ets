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

/**
 * Window scale dialog
 */
@CustomDialog
export struct ScaleDialog {
  @State scaleList: Resource[] =
    [$r('app.string.video_scale_fit'), $r('app.string.video_scale_fit_crop')];
  @Link @Watch('onWindowScaleSelectUpdate') windowScaleSelect: number; // Index of the current selection
  @StorageLink('avPlayerController') avPlayerController: AvPlayerController = new AvPlayerController();
  private controller: CustomDialogController;
  @Consume videoScaleType: number;

  onWindowScaleSelectUpdate() {
    this.videoScaleType = this.windowScaleSelect
  }

  build() {
    Column() {
      Text($r('app.string.dialog_play_scale'))
        .fontSize($r('app.float.size_20'))
        .fontWeight(FontWeight.Bold)
        .width('90%')
        .fontColor($r('app.color.dialog_title_color'))
        .textAlign(TextAlign.Center)
        .margin({ top: $r('app.float.size_20'), bottom: $r('app.float.size_12') })
      // [Start window_scale_dialog]
      List() {
        ForEach(this.scaleList, (item: Resource, index) => {
          ListItem() {
            Column() {
              Row() {
                Text(item)
                // [StartExclude window_scale_dialog]
                  .fontSize($r('app.float.size_16'))
                  .fontColor($r('app.color.dialog_text_color'))
                  .fontWeight(FontWeight.Medium)
                  .textAlign(TextAlign.Center)
                // [EndExclude window_scale_dialog]
                Blank()
                Image(this.windowScaleSelect === index ? $r('app.media.ic_radio_selected') :
                  $r('app.media.ic_radio'))
                // [StartExclude window_scale_dialog]
                  .width($r('app.float.size_24'))
                  .height($r('app.float.size_24'))
                  .objectFit(ImageFit.Contain)
                // [EndExclude window_scale_dialog]
              }
              // [StartExclude window_scale_dialog]
              .width('100%')

              if (index != this.scaleList.length - ONE) {
                Divider()
                  .vertical(false)
                  .strokeWidth(1)
                  .margin({ top: $r('app.float.size_10') })
                  .color($r('app.color.speed_dialog'))
                  .width('100%')
              }
              // [EndExclude window_scale_dialog]
            }
            .width('90%')
          }
          .width('100%')
          .height($r('app.float.size_48'))
          .onClick(() => {
            this.windowScaleSelect = index;
            switch (this.windowScaleSelect) {
              case ZERO:
                this.avPlayerController.videoScaleFit();
                break;
              case ONE:
                this.avPlayerController.videoScaleFitCrop();
                break;
              default:
                break;
            }
            this.controller.close();
          })
        })
      }
      // [End window_scale_dialog]
      .width('100%')
      .height('auto')
      .margin({
        top: $r('app.float.size_12'),
        bottom: $r('app.float.size_15')
      })

      Row() {
        Text($r('app.string.dialog_cancel'))
          .fontSize($r('app.float.size_16'))
          .fontColor($r('app.color.dialog_cancel_color'))
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.controller.close()
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