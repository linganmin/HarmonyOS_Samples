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

import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';
import { CommonConstants as Const } from '../common/CommonConstants';
import Logger from '../../../common/Logger';
import { AudioRecorderDemo, AVPlayerDemo } from '../utils/AudioRecorder';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const permissions: Array<Permissions> = ['ohos.permission.MICROPHONE'];

function reqPermissionsFromUser(permissions: Array<Permissions>, context: common.UIAbilityContext): void {
  const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
  atManager.requestPermissionsFromUser(context, permissions).then((data) => {
    const granStatus: Array<number> = data.authResults;
    const length: number = granStatus.length;
    for (let i = 0; i < length; i++) {
      if (granStatus[i] === 0) {
        Logger.info('User authorized.');
      } else {
        return;
      }
    }
  }).catch((error: BusinessError) => {
    hilog.error(0x0000, 'reqPermissionsFromUser',
      `requestPermissionsFromUser failed. error code=${error.code}, message=${error.message}`);
  })
}

// 使用Foreach渲染出18个宽度相等，高度随机的Column。
// 当音频振幅传过来的时候，column高度会随之随机变化。
@Component
struct ButtonWithWaterRipples {
  @Link columnX: number; // 矩形width
  @Link yMax: number; // 矩形height最大值
  @Link yMin: number; // 矩形height最小值
  @State arr: Array<number> = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18];

  build() {
    Row({ space: Const.COLUMN_WIDTH }) {
      ForEach(this.arr, (_: number) => {
        Column()
          .width(this.columnX)
          .height(Math.floor(Math.random() * (this.yMin - this.yMax + Const.OPACITY_TRUE) + this.yMax))
          .backgroundColor(Color.Gray)
          .borderRadius($r('app.integer.voice_record_dynamic_effect_radius_column'))
      }, (index: number) => index.toString())
    }
    .padding({
      left: Const.PADDING_SIZE,
      right: Const.PADDING_SIZE
    })
    .borderRadius(Const.BLANK_COLUMN)
    .backgroundColor($r('app.color.voice_record_dynamic_effect_color_message'))
    .width($r('app.string.voice_record_dynamic_effect_width_half'))
    .height(Const.COLUMN_HEIGHT)
    .justifyContent(FlexAlign.Center)
  }
}

@Entry
@Component
struct GestureGroupExample {
  @State columnX: number = Const.COLUMN_WIDTH;
  @State yMax: number = Const.OPACITY_FALSE;
  @State yMin: number = Const.OPACITY_FALSE;
  @State isListening: boolean = false;
  @State count: number = Const.OPACITY_FALSE;
  @State flagUpOpacity: number = Const.OPACITY_FALSE;
  @State flagInfoOpacity: number = Const.OPACITY_FALSE;
  @State maxNumber: number = Const.OPACITY_FALSE;
  @State minNumber: number = Const.OPACITY_FALSE;
  @State timeStart: number = Const.OPACITY_FALSE;
  @State timeEnd: number = Const.OPACITY_FALSE;
  @State timeAv: number = Const.OPACITY_FALSE;
  @Consume('NavPathStack') pageInfos: NavPathStack;
  private panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.Up });
  AVRecord = new AudioRecorderDemo();
  AVPlayer = new AVPlayerDemo();

  aboutToAppear() {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    reqPermissionsFromUser(permissions, context);
  }

  // 聊天页面渲染-对方
  @Builder
  message(message: string | Resource) {
    Row({ space: Const.BLANK_ROW }) {
      Image($r('app.media.voice_record_dynamic_effect_avatar_friend'))
        .width($r('app.integer.voice_record_dynamic_effect_width_image'))
        .height($r('app.integer.voice_record_dynamic_effect_height_image'))

      Text(message)
        .fontSize($r('app.integer.voice_record_dynamic_effect_font_size_text'))
        .textAlign(TextAlign.Center)
        .margin(Const.MARGIN_SIZE)
        .backgroundColor(Color.White)
        .padding({
          left: $r('app.integer.voice_record_dynamic_effect_margin_left'),
          right: $r('app.integer.voice_record_dynamic_effect_margin_left'),
          top: $r('app.integer.voice_record_dynamic_effect_margin_left'),
          bottom: $r('app.integer.voice_record_dynamic_effect_margin_left')
        })
        .borderRadius(Const.COLUMN_WIDTH)
    }
    .justifyContent(FlexAlign.Start)
    .width($r('app.string.voice_record_dynamic_effect_width_full'))
    .margin({ top: $r('app.integer.voice_record_dynamic_effect_margin_top') })
    .padding({
      left: $r('app.integer.voice_record_dynamic_effect_margin_left'),
      right: $r('app.integer.voice_record_dynamic_effect_margin_left')
    })
  }

  // 聊天页面渲染
  @Builder
  myMessage() {
    Row({ space: Const.BLANK_ROW }) {
      Text($r('app.string.voice_record_dynamic_effect_talk_message_thr'))
        .fontSize($r('app.integer.voice_record_dynamic_effect_font_size_text'))
        .textAlign(TextAlign.Center)
        .margin(Const.MARGIN_SIZE)
        .backgroundColor($r('app.color.voice_record_dynamic_effect_color_message'))
        .padding({
          left: $r('app.integer.voice_record_dynamic_effect_margin_left'),
          right: $r('app.integer.voice_record_dynamic_effect_margin_left'),
          top: $r('app.integer.voice_record_dynamic_effect_margin_left'),
          bottom: $r('app.integer.voice_record_dynamic_effect_margin_left')
        })
        .borderRadius(Const.COLUMN_WIDTH)

      Image($r('app.media.voice_record_dynamic_effect_avatar_own'))
        .width($r('app.integer.voice_record_dynamic_effect_width_image'))
        .height($r('app.integer.voice_record_dynamic_effect_height_image'))
    }
    .justifyContent(FlexAlign.End)
    .width($r('app.string.voice_record_dynamic_effect_width_full'))
    .margin({ top: $r('app.integer.voice_record_dynamic_effect_margin_top') })
    .padding({
      left: $r('app.integer.voice_record_dynamic_effect_margin_left'),
      right: $r('app.integer.voice_record_dynamic_effect_margin_left')
    })
  }

  // 整体页面渲染
  build() {
    Stack() {
      Column() {
        Row() {
          Image($r('app.media.voice_record_dynamic_effect_left'))
            .width($r('app.integer.voice_record_dynamic_effect_width_image'))
            .height($r('app.integer.voice_record_dynamic_effect_height_image'))
            .onClick(() => {
              this.pageInfos.pop();
            })
          Text($r('app.string.voice_record_dynamic_effect_friend'))
            .fontSize($r('app.integer.voice_record_dynamic_effect_font_size_text'))
            .textAlign(TextAlign.Center)
          Image($r('app.media.voice_record_dynamic_effect_qmz0nuwq'))
            .width($r('app.integer.voice_record_dynamic_effect_width_image'))
            .height($r('app.integer.voice_record_dynamic_effect_height_image'))
        }
        .backgroundColor($r('app.color.voice_record_dynamic_effect_color_all'))
        .justifyContent(FlexAlign.SpaceBetween)
        .width($r('app.string.voice_record_dynamic_effect_width_full'))
        .padding($r('app.integer.voice_record_dynamic_effect_padding_row'))

        // 聊天内容渲染
        Column() {
          this.message($r('app.string.voice_record_dynamic_effect_talk_info'))
          this.message($r('app.string.voice_record_dynamic_effect_talk_message'))
          this.message($r('app.string.voice_record_dynamic_effect_talk_message_one'))
          this.message($r('app.string.voice_record_dynamic_effect_talk_message_two'))
          this.myMessage()
          this.message($r('app.string.voice_record_dynamic_effect_talk_message_four'))

          Row({ space: Const.BLANK_ROW }) {
            Row() {
              Image($r('app.media.playback_recording'))
                .width($r('app.integer.voice_record_dynamic_effect_width_image'))
                .height($r('app.integer.voice_record_dynamic_effect_height_image'))
              Text(this.timeAv.toString())
                .fontSize($r('app.integer.voice_record_dynamic_effect_font_size_text'))
                .margin(Const.MARGIN_SIZE)
            }
            .borderRadius(Const.COLUMN_WIDTH)
            .justifyContent(FlexAlign.SpaceAround)
            .width(this.timeAv * Const.COLUMN_WIDTH + Const.HEIGHT_MIN)
            .backgroundColor($r('app.color.voice_record_dynamic_effect_color_message'))
            .margin({ top: $r('app.integer.voice_record_dynamic_effect_margin_top') })
            .padding({
              left: $r('app.integer.voice_record_dynamic_effect_margin_left'),
              right: $r('app.integer.voice_record_dynamic_effect_margin_left')
            })
            .onClick(() => {
              // 播放录制音频
              this.AVPlayer.avPlayerUrlDemo();
            })

            Image($r('app.media.voice_record_dynamic_effect_avatar_own'))
              .width($r('app.integer.voice_record_dynamic_effect_width_image'))
              .height($r('app.integer.voice_record_dynamic_effect_height_image'))
          }
          .width($r('app.string.voice_record_dynamic_effect_width_full'))
          .justifyContent(FlexAlign.End)
          .opacity(this.flagInfoOpacity)
          .margin({ top: $r('app.integer.voice_record_dynamic_effect_margin_top') })
          .padding({
            left: $r('app.integer.voice_record_dynamic_effect_margin_left'),
            right: $r('app.integer.voice_record_dynamic_effect_margin_left')
          })

          Blank(Const.BLANK_COLUMN)

          Row() {
            Image($r('app.media.voice_record_dynamic_effect_icon'))
              .width($r('app.integer.voice_record_dynamic_effect_width_image'))
              .height($r('app.integer.voice_record_dynamic_effect_height_image'))

            Button($r('app.string.voice_record_dynamic_effect_button'))
              .type(ButtonType.Normal)
              .borderRadius(Const.MARGIN_SIZE)
              .backgroundColor(Color.White)
              .width($r('app.integer.voice_record_dynamic_effect_width_button'))
              .height($r('app.integer.voice_record_dynamic_effect_height_button'))
              .fontColor(Color.Black)
              .gesture(
                GestureGroup(GestureMode.Sequence,
                  LongPressGesture()
                    .onAction(() => {
                      // 获取时间戳
                      this.timeStart = Math.floor(new Date().getTime() / Const.ANIMATION_DURATION);
                      this.flagInfoOpacity = Const.OPACITY_FALSE;
                      this.isListening = !this.isListening;
                      this.flagUpOpacity = Const.OPACITY_TRUE;
                      this.AVRecord.startRecordingProcess();
                      // 每隔100ms获取一次振幅。
                      this.count = setInterval(() => {
                        if (this.AVRecord.maxAmplitude > Const.MIN_AMPLITUDE) {
                          this.maxNumber = (this.AVRecord.maxAmplitude) / Const.MAX_AMPLITUDE * Const.COLUMN_HEIGHT;
                          this.minNumber =
                            (this.AVRecord.maxAmplitude) / Const.MAX_AMPLITUDE * Const.COLUMN_HEIGHT - Const.HEIGHT_MIN;
                        } else {
                          this.maxNumber = Const.OPACITY_FALSE;
                          this.minNumber = Const.OPACITY_FALSE;
                        }
                        if (this.isListening) {

                          this.getUIContext()
                            .animateTo({ duration: Const.ANIMATION_DURATION, curve: Curve.EaseInOut }, () => {
                              Logger.info(this.timeStart.toString() + 'ANIMATION_DURATION' + Const.ANIMATION_DURATION);
                              this.yMax = this.maxNumber;
                              this.yMin = this.minNumber;
                            })
                        }
                      }, Const.SET_INTERVAL_TIME);
                    })
                    .onActionEnd(() => {
                      clearInterval(this.count);
                      this.flagInfoOpacity = Const.OPACITY_TRUE;
                      this.yMax = Const.OPACITY_FALSE;
                      this.yMin = Const.OPACITY_FALSE;
                      this.AVRecord.stopRecordingProcess();
                    }),
                  // 上划取消录制
                  PanGesture(this.panOption)
                    .onActionStart(() => {
                      clearInterval(this.count);
                    })
                    .onActionEnd(() => {
                      this.isListening = false;
                      this.getUIContext().animateTo({ duration: Const.OPACITY_FALSE }, () => {
                        this.yMax = Const.OPACITY_FALSE;
                        this.yMin = Const.OPACITY_FALSE;
                      });
                      this.flagUpOpacity = Const.OPACITY_FALSE;
                      this.flagInfoOpacity = Const.OPACITY_FALSE;
                      this.AVRecord.stopRecordingProcess();
                    })
                )
                  .onCancel(() => {
                    // 获取结束时间戳并计算出手势持续时间
                    this.timeEnd = Math.floor(new Date().getTime() / Const.ANIMATION_DURATION);
                    this.timeAv = this.timeEnd - this.timeStart;
                    clearInterval(this.count);
                    // 当不需要动画时设置duration为0打断动画。
                    this.getUIContext().animateTo({ duration: Const.OPACITY_FALSE }, () => {
                      this.yMax = Const.OPACITY_FALSE;
                      this.yMin = Const.OPACITY_FALSE;
                    });
                    this.flagUpOpacity = Const.OPACITY_FALSE;
                    if (this.timeStart === 0 || this.isListening === false) {
                      try {
                        this.getUIContext().getPromptAction().showToast({
                          message: Const.SHOW_TOAST_MESSAGE,
                          duration: Const.SHOW_TOAST_DURATION
                        });
                      } catch (err) {
                        let error = err as BusinessError;
                        hilog.error(0x0000, 'GestureGroupExample', `error code=${error.code}, message=${error.message}`);
                      }
                      this.flagInfoOpacity = Const.OPACITY_FALSE;
                    } else {
                      this.flagInfoOpacity = Const.OPACITY_TRUE;
                    }
                    this.isListening = false;
                    this.AVRecord.stopRecordingProcess();
                  })
              )
            Image($r('app.media.voice_record_dynamic_effect_emoji'))
              .width($r('app.integer.voice_record_dynamic_effect_width_image'))
              .height($r('app.integer.voice_record_dynamic_effect_height_image'))
            Image($r('app.media.voice_record_dynamic_effect_add'))
              .width($r('app.integer.voice_record_dynamic_effect_width_image'))
              .height($r('app.integer.voice_record_dynamic_effect_height_image'))
          }
          .justifyContent(FlexAlign.SpaceAround)
          .width($r('app.string.voice_record_dynamic_effect_width_full'))
          .height($r('app.integer.voice_record_dynamic_effect_height_row'))
          .backgroundColor($r('app.color.voice_record_dynamic_effect_color_row'))

        }
        .backgroundColor($r('app.color.voice_record_dynamic_effect_color_all'))
        .justifyContent(FlexAlign.End)
        .width($r('app.string.voice_record_dynamic_effect_width_full'))
        .height($r('app.string.voice_record_dynamic_effect_width_nine'))
      }
      .width($r('app.string.voice_record_dynamic_effect_width_full'))
      .height($r('app.string.voice_record_dynamic_effect_height_full'))

      if (this.flagUpOpacity === 1) {
        Column() {
          Column() {
            ButtonWithWaterRipples({
              columnX: this.columnX,
              yMax: this.yMax,
              yMin: this.yMin
            })
            Text($r('app.string.voice_record_dynamic_effect_top_fig'))
              .fontSize($r('app.integer.voice_record_dynamic_effect_font_size_text'))
              .height($r('app.integer.voice_record_dynamic_effect_height_text'))
          }
          .justifyContent(FlexAlign.Center)
          .width($r('app.string.voice_record_dynamic_effect_width_full'))
          .height($r('app.string.voice_record_dynamic_effect_width_nine'))

          Row() {
            Text($r('app.string.voice_record_dynamic_effect_send_message'))
              .fontSize($r('app.integer.voice_record_dynamic_effect_font_size_text'))
              .fontColor(Color.White)
          }
          .justifyContent(FlexAlign.Center)
          .height(Const.HEIGHT_ST)
          .width($r('app.string.voice_record_dynamic_effect_width_full'))
          .borderRadius($r('app.integer.voice_record_dynamic_effect_radius_row'))
          .backgroundColor(Color.Gray)
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .backgroundColor($r('app.string.voice_record_dynamic_effect_color_stack'))
        .width($r('app.string.voice_record_dynamic_effect_width_full'))
        .height($r('app.string.voice_record_dynamic_effect_height_full'))
      }
    }
    .alignContent(Alignment.Bottom)
    .width($r('app.string.voice_record_dynamic_effect_width_full'))
    .height($r('app.string.voice_record_dynamic_effect_height_full'))
  }
}

@Builder
export function getVoiceRecordDynamic(name: string): void {
  if (name === 'VoiceRecordDynamic') {
    NavDestination() {
      GestureGroupExample()
    }
    .hideTitleBar(true)
  }
}

export const wrappedBuilderVoiceRecordDynamic: WrappedBuilder<[string, number]> = wrapBuilder(getVoiceRecordDynamic);