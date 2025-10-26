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

import { timeConvert } from '../common/utils/TimeUtils';
import { AvPlayerController } from '../controller/AvPlayerController';
import { SpeedDialog } from './SpeedDialog';
import { ScaleDialog } from './ScaleDialog';
import { LanguageDialog } from './LanguageDialog';

@Component
export struct VideoOperate {
  @State speedSelect: number = 0; // Speed Magnification Selection
  @State windowScaleSelect: number = 0
  @State languageSelect: number = 0
  @Link currentTime: number;
  @Link durationTime: number;
  @Link isSwiping: boolean;
  @Link avPlayerController: AvPlayerController
  @Link flag: boolean; // Play/Pause
  @Link XComponentFlag: boolean;
  @Consume speedIndex: number; // Index of the playback rate list.
  @Consume speedName: Resource;
  @Consume videoScaleType: number;
  @Consume isMuted: boolean;
  @StorageLink('sliderWidth') sliderWidth: string = '';
  @Consume currentLanguageType: number;
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: SpeedDialog({ speedSelect: $speedSelect }),
    alignment: DialogAlignment.Center,
    offset: { dx: $r('app.float.size_zero'), dy: $r('app.float.size_down_4') }
  });
  private scaleDialogController: CustomDialogController = new CustomDialogController({
    builder: ScaleDialog({ windowScaleSelect: $windowScaleSelect }),
    alignment: DialogAlignment.Center,
    offset: { dx: $r('app.float.size_zero'), dy: $r('app.float.size_down_4') }
  });
  private languageDialogController: CustomDialogController = new CustomDialogController({
    builder: LanguageDialog({ languageSelect: $languageSelect }),
    alignment: DialogAlignment.Center,
    offset: { dx: $r('app.float.size_zero'), dy: $r('app.float.size_down_4') }
  });

  build() {
    Column(){
      Row() {
        // [Start video_language_switch_button]
        /**
         * Video Language switch
         */
        Button() {
          Image($r('app.media.ic_video_translate'))
            .width($r('app.float.size_25'))
            .height($r('app.float.size_25'))
        }
        .type(ButtonType.Normal)
        .width($r('app.float.size_25'))
        .height($r('app.float.size_25'))
        .backgroundColor('rgba(0, 0, 0, 0)')
        .margin({ left: $r('app.float.size_5') })
        .fontColor(Color.White)
        .onClick(() => {
          this.languageSelect = this.currentLanguageType;
          this.languageDialogController.open();
        })

        // [End video_language_switch_button]
      }
      .width('100%')
      .padding({ left: $r('app.float.size_12'), right: $r('app.float.size_20') })
      .justifyContent(FlexAlign.End)


      Row() {
        Row() {
          Image(this.flag ? $r('app.media.ic_video_play') : $r('app.media.ic_video_pause'))// Play/Pause
            .id('play')
            .width($r('app.float.size_30'))
            .height($r('app.float.size_30'))
            .onClick(() => {
              this.flag ? this.avPlayerController.videoPause() : this.avPlayerController.videoPlay();
              this.flag = !this.flag;
            })

          // Left side time
          Text(timeConvert(this.currentTime))
            .fontColor(Color.White)
            .textAlign(TextAlign.End)
            .fontWeight(FontWeight.Regular)
            .margin({ left: $r('app.float.size_5') })
        }

        Row() {
          // [Start progress_slider]
          /**
           * Progress slider
           */
          Slider({
            value: this.currentTime,
            min: 0,
            max: this.durationTime,
            style: SliderStyle.OutSet
          })
            .id('Slider')
            .blockColor(Color.White)
            .trackColor(Color.Gray)
            .selectedColor($r('app.color.slider_selected'))
            .showTips(false)
            .onChange((value: number, mode: SliderChangeMode) => {
              if (mode === SliderChangeMode.Begin) {
                this.isSwiping = true;
                this.avPlayerController.videoPause();
              }
              this.avPlayerController.videoSeek(value);
              this.currentTime = value;
              if (mode === SliderChangeMode.End) {
                this.isSwiping = false;
                this.flag = true;
                this.avPlayerController.videoPlay();
              }
            })
          // [End progress_slider]
        }
        .layoutWeight(1)
        Row() {
          // Right side time
          Text(timeConvert(this.durationTime))
            .fontColor(Color.White)
            .fontWeight(FontWeight.Regular)

          // [Start video_speed_button]
          Button(this.speedName, { type: ButtonType.Normal })
            .border({ width: $r('app.float.size_1'), color: Color.White })
            .width($r('app.float.size_64'))
            .height($r('app.float.size_30'))
            .fontSize($r('app.float.size_15'))
            .borderRadius($r('app.float.size_20'))
            .fontColor(Color.White)
            .backgroundColor('rgba(0, 0, 0, 0)')
            .opacity($r('app.float.size_1'))
            .padding({ left: $r('app.float.size_5'), right: $r('app.float.size_5') })
            .margin({ left: $r('app.float.size_8') })
            .id('Speed')
            .onClick(() => {
              this.speedSelect = this.speedIndex;
              this.dialogController.open();
            })
          // [End video_speed_button]

          // [Start video_muted_button]
          /**
           * Video Muted Button
           */
          Button() {
            Image(this.isMuted ? $r('app.media.ic_video_speaker_slash') : $r('app.media.ic_video_speaker'))
              .width($r('app.float.size_30'))
              .height($r('app.float.size_30'))
          }
          .type(ButtonType.Normal)
          .width($r('app.float.size_30'))
          .height($r('app.float.size_30'))
          .borderRadius($r('app.float.size_20'))
          .backgroundColor('rgba(0, 0, 0, 0)')
          .margin({ left: $r('app.float.size_5') })
          .fontColor(Color.White)
          .onClick(() => {
            this.isMuted = !this.isMuted;
            this.avPlayerController.videoMuted(this.isMuted)
          })

          // [End video_muted_button]

          // [Start window_scale_button]
          /**
           * Window scale button
           */
          Button() {
            Image($r('app.media.ic_video_window_scale'))
              .width($r('app.float.size_25'))
              .height($r('app.float.size_25'))
          }
          .type(ButtonType.Normal)
          .width($r('app.float.size_25'))
          .height($r('app.float.size_25'))
          .backgroundColor('rgba(0, 0, 0, 0)')
          .margin({ left: $r('app.float.size_5') })
          .fontColor(Color.White)
          .onClick(() => {
            this.windowScaleSelect = this.videoScaleType;
            this.scaleDialogController.open();
          })

          // [End window_scale_button]
        }
      }
      .justifyContent(FlexAlign.Center)
      .padding({ left: $r('app.float.size_12'), right: $r('app.float.size_20'), bottom: '28vp' })
      .width('100%')
    }
  }
}