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

import { media } from '@kit.MediaKit';
import { common } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { emitter } from '@kit.BasicServicesKit';
import { TimeUtil } from '../common/utils/TimeUtils';
import { AvPlayerController } from '../controller/AvPlayerController';
import { SpeedDialog } from './SpeedDialog';
import { ScaleDialog } from './ScaleDialog';
import { CommonConstants } from '../common/constants/CommonConstants';
import { BulletComment } from '../model/BulletCommentModel';
import { LanguageDialog } from './LanguageDialog';

const TAG = '[VideoOperate]';

@Component
export struct VideoOperate {
  @State speedSelect: number = 0; // Speed Magnification Selection
  @State windowScaleSelect: number = 0;
  @State languageSelect: number = 0;
  @State bulletCommentInput: string = ''; //user input bullet comment
  @Link bulletComments: BulletComment[]; //bullet comments storage array
  @Link @Watch('fullScreenChange') isFullScreen: boolean;
  @Link isSwiping: boolean;
  @Link avPlayerController: AvPlayerController;
  @StorageLink('speedIndex') speedIndex: number = 0; // Index of the playback rate list.
  @StorageLink('sliderWidth') sliderWidth: string = '';
  @StorageLink('speedName') speedName: Resource = $r('app.string.video_speed_1_0X');
  @StorageLink('isMuted') isMuted: boolean = false;
  @StorageLink('videoScaleType') videoScaleType: number = media.VideoScaleType.VIDEO_SCALE_TYPE_FIT;
  @StorageLink('currentLanguageType') currentLanguageType: number = 0;
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: SpeedDialog({ avPlayerController: this.avPlayerController, speedSelect: this.speedSelect }),
    alignment: DialogAlignment.Center,
    offset: { dx: $r('app.float.size_zero'), dy: $r('app.float.size_down_20') }
  });
  private scaleDialogController: CustomDialogController = new CustomDialogController({
    builder: ScaleDialog({ windowScaleSelect: $windowScaleSelect }),
    alignment: DialogAlignment.Center,
    offset: { dx: $r('app.float.size_zero'), dy: $r('app.float.size_down_20') }
  });
  private languageDialogController: CustomDialogController = new CustomDialogController({
    builder: LanguageDialog({ avPlayerController: this.avPlayerController, languageSelect: $languageSelect }),
    alignment: DialogAlignment.Center,
    offset: { dx: $r('app.float.size_zero'), dy: $r('app.float.size_down_20') }
  });
  private uiAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private windowClass = this.uiAbilityContext.windowStage.getMainWindowSync();

  fullScreenChange() {
    try {
      if (this.isFullScreen) {
        this.windowClass.setPreferredOrientation(window.Orientation.LANDSCAPE);
      } else {
        this.windowClass.setPreferredOrientation(window.Orientation.PORTRAIT);
      }
    } catch (err) {
      hilog.info(CommonConstants.LOG_DOMAIN, TAG,
        `windowClass.setPreferredOrientation failed, code is ${err.code}, message is ${err.message}`);
    }
  }

  aboutToAppear(): void {
    this.windowClass.on('windowSizeChange', (newSize: window.Size) => {
      let eventWHData: emitter.EventData = {
        data: {
          'width': newSize.width,
          'height': newSize.height
        }
      };
      emitter.emit(CommonConstants.innerEventWH, eventWHData);
    });
  }

  // [Start SendBulletComment]
  private sendBulletComment() {
    if (this.bulletCommentInput.trim()) {
      this.bulletComments = [...this.bulletComments, new BulletComment(this.bulletCommentInput, true)];
      this.bulletCommentInput = '';
      if (this.bulletComments.length > 50) {
        this.bulletComments = this.bulletComments.slice(1);
      }
    }
    this.avPlayerController.videoPlay(); //resume video playback after sending
  }

  // [End SendBulletComment]

  @BuilderParam
  progressBuilder: () => void = this.defaultProgressBuilder;

  @Builder
  defaultProgressBuilder() {
    Row() {
      // [Start progress_slider]
      /**
       * Progress slider
       */
      Slider({
        value: this.avPlayerController.currentTime,
        min: 0,
        max: this.avPlayerController.durationTime,
        style: SliderStyle.OutSet
      })
        .id('Slider')
        .blockColor(Color.White)
        .trackColor(Color.Gray)
        .selectedColor($r('app.color.slider_selected'))
        .showTips(false)
        .onChange((value: number, mode: SliderChangeMode) => {
          if (mode == SliderChangeMode.Begin) {
            this.isSwiping = true;
            this.avPlayerController.videoPause();
          }
          this.avPlayerController.videoSeek(value);

          if (mode == SliderChangeMode.End) {
            this.isSwiping = false;
            this.avPlayerController.videoPlay();
          }
        })
      // [End progress_slider]
    }
    .layoutWeight(1)
  }

  build() {
    Column() {
      Row() {
        Row() {
          Image(this.avPlayerController.isPlaying ? $r('app.media.ic_video_play') :
          $r('app.media.ic_video_pause'))// Play/Pause
            .id('play')
            .width($r('app.float.size_25'))
            .height($r('app.float.size_25'))
            .onClick(() => {
              this.avPlayerController.isPlaying ? this.avPlayerController.videoPause() :
              this.avPlayerController.videoPlay();
            })

          // Left side time
          Text(TimeUtil.millisecondsToTime(this.avPlayerController.currentTime))
            .fontColor(Color.White)
            .textAlign(TextAlign.End)
            .fontWeight(FontWeight.Regular)
            .margin({ left: $r('app.float.size_5') })
        }

        this.progressBuilder()

        Row() {
          // Right side time
          Text(TimeUtil.millisecondsToTime(this.avPlayerController.durationTime))
            .fontColor(Color.White)
            .fontWeight(FontWeight.Regular)

          if (this.isFullScreen) {
            // [Start video_speed_button]
            Button(this.speedName, { type: ButtonType.Normal })
              .border({ width: $r('app.float.size_1'), color: Color.White })
              .width($r('app.float.size_64'))
              .height($r('app.float.size_25'))
              .fontSize($r('app.float.size_15'))
              .borderRadius($r('app.float.size_20'))
              .fontColor(Color.White)
              .backgroundColor('#00000000')
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
                .width($r('app.float.size_25'))
                .height($r('app.float.size_25'))
            }
            .type(ButtonType.Normal)
            .width($r('app.float.size_25'))
            .height($r('app.float.size_25'))
            .borderRadius($r('app.float.size_20'))
            .backgroundColor('#00000000')
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
            .backgroundColor('#00000000')
            .margin({ left: $r('app.float.size_5') })
            .fontColor(Color.White)
            .onClick(() => {
              this.windowScaleSelect = this.videoScaleType;
              this.scaleDialogController.open();
            })

            // [End window_scale_button]
          }
          Image($r('app.media.fullscreen'))
            .size({ width: 25, height: 25 })
            .margin({ left: 10 })
            .onClick(() => {
              this.isFullScreen = !this.isFullScreen;
            })

        }
      }
      .height(this.isFullScreen ? 26 : 40)

      if (this.isFullScreen) {
        //third row:button
        Row() {
          Row({ space: 7 }) {

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
            .backgroundColor('rgba(0, 0, 0, 0)')
            .margin({ left: $r('app.float.size_5') })
            .fontColor(Color.White)
            .onClick(() => {
              this.languageSelect = this.currentLanguageType;
              this.languageDialogController.open();
            })

            TextInput({ text: this.bulletCommentInput, placeholder: $r('app.string.caption_placeholder') })
              .backgroundColor('rgba(255,255,255,0.1)')
              .placeholderColor('rgba(255,255,255,0.7)')
              .placeholderFont({ size: 14 })
              .padding({ top: 0, bottom: 0 })
              .fontColor(Color.White)
              .onFocus(() => {
                this.avPlayerController.videoPause();
              })
              .onBlur(() => {
                this.avPlayerController.videoPlay();
              })
              .layoutWeight(1)
              .onChange((value: string) => {
                this.bulletCommentInput = value;
              })
          }
          .padding({ right: 8 })
          .layoutWeight(1)

          Image($r('app.media.arrow_up_circle_fill'))
            .width('26vp')
            .onClick(() => {
              this.sendBulletComment();
            })
            .backgroundColor(Color.Transparent)
        }
        .height(26)

      }
    }
    .backgroundColor('#1a000000')
    // .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
    .justifyContent(FlexAlign.Center)
    .padding({
      top: 5,
      bottom: this.isFullScreen ? 10 : 20,
      left: $r('app.float.size_20'),
      right: $r('app.float.size_20')
    })
    .height('auto')
    .width('100%')
  }
}