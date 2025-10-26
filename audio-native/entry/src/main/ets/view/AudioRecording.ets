/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import { abilityAccessCtrl } from '@kit.AbilityKit';
import { audio } from '@kit.AudioKit';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import testNapi from 'libentry.so';
import CommonConstants from '../constants/CommonConstants';
import { logger } from '../utils/Logger';

let atManager = abilityAccessCtrl.createAtManager();

@Component
export struct AudioRecording {
  /**
   * [init,started,continued,paused,stopped]
   */
  @State recordState: string = CommonConstants.PLAY_INIT;
  @State title: string = 'oh_test_audio';
  @State date: string = '';
  @State playSec: number = 0;
  @State renderState: number = 0;
  @State recordSec: number = 0;
  @State showTime: string = '00:00:00';
  @State isRecordOver: boolean = false;
  private audioCapturesLowLatency: boolean = false;
  private audioCaptures: boolean = false;
  private audioRendererLowLatency: boolean = false;
  private interval: number = 0;

  aboutToAppear() {
    this.initResource();
  }

  aboutToDisappear() {
    this.releaseResource();
  }

  @Builder
  InitRecord() {
    Column() {
      Image($r('app.media.ic_record'))
        .width($r('app.float.record_width'))
        .height($r('app.float.record_width'))
    }
    .width(CommonConstants.FULL_PERCENT)
    .height($r('app.float.common_title'))
    .id('start_record_btn')
    .onClick(() => {
      atManager.requestPermissionsFromUser(this.getUIContext().getHostContext(),
        ['ohos.permission.MICROPHONE']).then((data) => {
        if (data.authResults[0] !== 0) {
          return;
        }
        if (this.audioCapturesLowLatency) {
          testNapi.audioCapturesLowLatencyInit();
        }
        if (this.audioCaptures || (!this.audioCapturesLowLatency && !this.audioCaptures)) {
          testNapi.audioCapturesInit();
        }
        this.capturesStart();
      }).catch((err: BusinessError) => {
        logger.error('error:' + JSON.stringify(err));
      });
    })
  }

  @Builder
  StartedRecord() {
    Column() {
      Text(this.showTime)
        .fontSize($r('app.float.time_size'))
        .fontWeight(CommonConstants.FONT_WIGHT_500)
        .margin({ bottom: $r('app.float.time_margin') })
    }
    .width(CommonConstants.FULL_PERCENT)
    .height($r('app.float.start_height'))
    .position({ y: $r('app.float.start_position') })
    .id('show_time_txt')

    Column() {
      Image($r('app.media.ic_recording'))
        .width($r('app.float.record_width'))
        .height($r('app.float.record_width'))
    }
    .width(CommonConstants.FULL_PERCENT)
    .height($r('app.float.common_title'))
    .position({ y: $r('app.float.start_record_position') })
    .id('stop_record_btn')
    .onClick(() => {
      this.capturesStop();
    })

    Column() {
      Image($r('app.media.ic_record_pause'))
        .width($r('app.float.common_image'))
        .height($r('app.float.common_image'))
      Text($r('app.string.pause_audio'))
        .fontSize($r('app.float.small_size'))
        .id('pause_record_btn')
        .margin({ top: $r('app.float.pause_margin_top') })
    }
    .height($r('app.float.common_title'))
    .width($r('app.float.common_title'))
    .position({
      x: CommonConstants.PAUSE_POSITION_X,
      y: $r('app.float.start_record_position')
    })
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.capturesPause();
    })
  }

  @Builder
  PausedRecord() {
    Column() {
      Text(this.showTime)
        .fontSize($r('app.float.time_size'))
        .fontWeight(CommonConstants.FONT_WIGHT_500)
        .margin({ bottom: $r('app.float.time_margin') })
    }
    .width(CommonConstants.FULL_PERCENT)
    .height($r('app.float.start_height'))
    .position({ y: $r('app.float.start_position') })

    Column() {
      Image($r('app.media.ic_recording'))
        .width($r('app.float.record_width'))
        .height($r('app.float.record_width'))
    }
    .width(CommonConstants.FULL_PERCENT)
    .height($r('app.float.common_title'))
    .position({ y: $r('app.float.start_record_position') })
    .onClick(() => {
      this.capturesStop();
    })

    Column() {
      Image($r('app.media.ic_record_continue'))
        .width($r('app.float.common_image'))
        .height($r('app.float.common_image'))
      Text($r('app.string.CONTINUE'))
        .fontSize($r('app.float.small_size'))
        .margin({ top: $r('app.float.pause_margin_top') })
    }
    .height($r('app.float.common_title'))
    .width($r('app.float.common_title'))
    .position({
      x: CommonConstants.PAUSE_POSITION_X,
      y: $r('app.float.start_record_position')
    })
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .id('continue_record_btn')
    .onClick(() => {
      this.capturesContinue();
    })
  }

  @Builder
  FinishedRecord() {
    Column() {
      Image($r('app.media.ic_record'))
        .width($r('app.float.record_width'))
        .height($r('app.float.record_width'))
    }
    .width(CommonConstants.FULL_PERCENT)
    .height($r('app.float.common_title'))
    .position({ y: $r('app.float.start_record_position') })
    .opacity(CommonConstants.AUDIO_OPACITY)
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          Row() {
            Text($r('app.string.low_latency_captures'))
              .fontSize($r('app.float.common_font'))
              .fontWeight(CommonConstants.FONT_WIGHT_500)
              .fontColor($r('sys.color.font_primary'))
              .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
              .opacity(this.isRecordOver ? CommonConstants.AUDIO_OPACITY : 1)
            Toggle({
              type: ToggleType.Switch,
              isOn: this.audioCapturesLowLatency
            })
              .onChange((isOn: boolean) => {
                if (isOn) {
                  this.audioCaptures = false;
                  this.audioCapturesLowLatency = true;
                } else {
                  this.audioCaptures = true;
                  this.audioCapturesLowLatency = false;
                }
              })
              .enabled(this.recordState === CommonConstants.PLAY_INIT &&
                deviceInfo.deviceType === CommonConstants.DEVICE_PHONE)
          }
          .width(CommonConstants.FULL_PERCENT)
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .width(CommonConstants.FULL_PERCENT)
        .height($r('app.float.common_title'))
        .backgroundColor(Color.White)
        .borderRadius($r('app.float.border_radius'))
        .margin({ top: $r('app.float.small_margin') })
        .justifyContent(FlexAlign.Center)
        .padding({
          left: $r('app.float.small_padding'),
          right: $r('app.float.small_padding')
        })

        if (this.isRecordOver === true) {
          Column() {
            Row() {
              Text($r('app.string.low_latency_renderer'))
                .fontSize($r('app.float.common_font'))
                .fontWeight(CommonConstants.FONT_WIGHT_500)
                .fontColor($r('sys.color.font_primary'))
                .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
              Toggle({ type: ToggleType.Switch, isOn: (this.audioRendererLowLatency) })
                .id('renderer_low_latency_btn')
                .onChange((isOn: boolean) => {
                  if (isOn) {
                    testNapi.audioRendererLowLatencyInit();
                    this.audioRendererLowLatency = true;
                  } else {
                    testNapi.audioRendererInit();
                    this.audioRendererLowLatency = false;
                  }
                })
                .enabled(this.renderState === audio.AudioState.STATE_PREPARED && deviceInfo.deviceType === 'phone')
            }
            .width(CommonConstants.FULL_PERCENT)
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .width(CommonConstants.FULL_PERCENT)
          .height($r('app.float.common_title'))
          .backgroundColor(Color.White)
          .justifyContent(FlexAlign.Center)
          .borderRadius($r('app.float.border_radius'))
          .margin({ top: $r('app.float.small_margin') })
          .padding({
            left: $r('app.float.small_padding'),
            right: $r('app.float.small_padding')
          })

          Column() {
            Text($r('app.string.record_result'))
              .fontSize($r('app.float.result_size'))
              .opacity(CommonConstants.COMMON_OPACITY)
              .position({ x: 0 })
          }
          .height($r('app.float.result_height'))
          .width(CommonConstants.FULL_PERCENT)
          .margin({ top: $r('app.float.common_padding') })

          Column() {
            Row() {
              Text(this.title)
                .fontSize($r('app.float.common_font'))
                .fontWeight(CommonConstants.FONT_WIGHT_500)
                .fontColor($r('sys.color.font_primary'))
                .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
              Image(this.renderState === audio.AudioState.STATE_RUNNING ?
                $r('app.media.ic_record_playing') : $r('app.media.ic_record_paused'))
                .width($r('app.float.common_image'))
                .height($r('app.float.common_image'))
                .id('playing_state')
            }
            .width(CommonConstants.FULL_PERCENT)
            .height($r('app.float.common_height'))
            .justifyContent(FlexAlign.SpaceBetween)

            Row() {
              Text(this.date)
                .fontSize($r('app.float.common_font'))
                .fontColor($r('sys.color.font_primary'))
                .opacity(CommonConstants.COMMON_OPACITY)
                .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
              Text(this.getTimesBySecond(this.recordSec) + '')
                .fontSize($r('app.float.common_font'))
                .fontColor($r('sys.color.font_primary'))
                .opacity(CommonConstants.COMMON_OPACITY)
                .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
            }
            .width(CommonConstants.FULL_PERCENT)
            .height($r('app.float.common_height'))
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({
              top: $r('app.float.time_margin_top'),
              bottom: $r('app.float.small_margin')
            })

            Row() {
              Text($r('app.string.play_now'))
                .fontSize($r('app.float.small_size'))
                .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
                .fontColor($r('sys.color.font_primary'))
                .opacity(CommonConstants.COMMON_OPACITY)
              Text(this.getTimesBySecond(this.playSec) + '')
                .fontSize($r('app.float.small_size'))
                .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
                .fontColor($r('sys.color.font_primary'))
                .opacity(CommonConstants.COMMON_OPACITY)
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width(CommonConstants.FULL_PERCENT)

            Row() {
              Progress({ value: this.playSec, total: this.recordSec, type: ProgressType.Linear })
                .value(this.playSec)
                .width(CommonConstants.FULL_PERCENT)
            }
            .margin({
              top: $r('app.float.time_margin_top')
            })
          }
          .width(CommonConstants.FULL_PERCENT)
          .backgroundColor(Color.White)
          .borderRadius($r('app.float.border_radius'))
          .margin({ top: $r('app.float.play_margin_top') })
          .padding({
            left: $r('app.float.small_padding'),
            right: $r('app.float.small_padding'),
            top: $r('app.float.common_padding'),
            bottom: $r('app.float.common_padding')
          })
          .id('player_btn')
          .onClick(() => {
            if (this.renderState === audio.AudioState.STATE_PREPARED) {
              this.renderStart();
            } else if (this.renderState === audio.AudioState.STATE_RUNNING) {
              this.renderPause();
            } else if (this.renderState === audio.AudioState.STATE_PAUSED) {
              this.renderStart();
            } else if (this.renderState === audio.AudioState.STATE_STOPPED) {
              this.renderStart();
            }
          })
        }
        Row() {
          if (this.recordState === CommonConstants.PLAY_INIT) {
            this.InitRecord();
          } else if (this.recordState === CommonConstants.PLAY_STARTED) {
            this.StartedRecord();
          } else if (this.recordState === CommonConstants.PLAY_PAUSED) {
            this.PausedRecord();
          } else if (this.recordState === CommonConstants.PLAY_CONTINUED) {
            this.StartedRecord();
          } else if (this.recordState === CommonConstants.PLAY_STOPPED) {
            this.FinishedRecord();
          }
        }
        .width(CommonConstants.FULL_PERCENT)
        .alignItems(VerticalAlign.Center)
        .height($r('app.float.row_height'))
        .position({ y: CommonConstants.RECORD_POSITION_Y })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.Start)
      .padding($r('app.float.border_radius'))
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .title($r('app.string.audio_captures'))
    .backgroundColor($r('app.color.audio_background'))
  }

  initResource() {
    try {
      this.recordState = CommonConstants.PLAY_INIT;
      this.date = this.getDate(1);
    } catch (err) {
      logger.error(`AudioRecording:createAudioCapturer err = ${JSON.stringify(err)}`);
    }
  }

  releaseResource() {
    if (this.interval) {
      clearInterval(this.interval);
    }
    testNapi.audioCapturesRelease();
    this.recordState = 'init';
    testNapi.audioRendererRelease();
    testNapi.closeFile();
  }

  capturesStart() {
    try {
      testNapi.audioCapturesStart();
      this.recordSec = 0;
      this.recordState = CommonConstants.PLAY_STARTED;
      clearInterval(this.interval);
      this.interval = setInterval(async () => {
        if (this.recordSec >= CommonConstants.TOTAL_SECOND) {
          clearInterval(this.interval);
          this.capturesStop();
          return;
        }
        this.recordSec++;
        this.showTime = this.getTimesBySecond(this.recordSec);
      }, CommonConstants.INTERVAL_TIME);
    } catch (err) {
      logger.error(`AudioRecording:audioCapturer start err = ${JSON.stringify(err)}`);
    }
  }

  renderCreate() {
    try {
      testNapi.audioRendererInit();
      this.renderState = testNapi.getRendererState();
    } catch (err) {
      logger.error(`createAudioRenderer err = ${JSON.stringify(err)}`);
    }
  }

  renderStart() {
    try {
      testNapi.audioRendererStart();
      this.renderState = testNapi.getRendererState();
      if (this.playSec === this.recordSec) {
        this.playSec = 0;
      }
      this.interval = setInterval(async () => {
        let playNumber = Math.round(testNapi.getFramesWritten() * 4 / testNapi.getFileSize() * this.recordSec);
        this.playSec = (playNumber < 0 || this.playSec === this.recordSec) ? this.recordSec : playNumber;
        if (testNapi.getFileState()) {
          testNapi.audioRendererStop();
          testNapi.audioRendererRelease();
          testNapi.closeFile();
          if (testNapi.getFastState()) {
            testNapi.audioRendererLowLatencyInit();
          } else {
            testNapi.audioRendererInit();
          }
          clearInterval(this.interval);
          this.renderState = testNapi.getRendererState();
          return;
        }
      }, 50);
    } catch (err) {
      logger.error(`write err:${JSON.stringify(err)}`);
    }
  }

  renderPause() {
    try {
      testNapi.audioRendererPause();
      this.renderState = testNapi.getRendererState();
      clearInterval(this.interval);
    } catch (err) {
      logger.error(`pause err: ${JSON.stringify(err)}`);
    }
  }

  capturesContinue() {
    try {
      testNapi.audioCapturesStart();
      this.recordState = CommonConstants.PLAY_CONTINUED;
      logger.info('audioCaptures start ok');
      this.interval = setInterval(async () => {
        if (this.recordSec >= CommonConstants.TOTAL_SECOND) {
          clearInterval(this.interval);
          this.capturesStop();
          return;
        }
        this.recordSec++;
        this.showTime = this.getTimesBySecond(this.recordSec);
      }, CommonConstants.INTERVAL_TIME);
    } catch (err) {
      logger.error(`AudioRecording:audioCapturer start err = ${JSON.stringify(err)}`);
    }
  }

  capturesStop() {
    if (this.recordSec < CommonConstants.MIN_RECORD_SECOND) {
      return;
    }
    try {
      testNapi.audioCapturesStop();
      testNapi.audioCapturesRelease();
      testNapi.closeFile();
      this.recordState = CommonConstants.PLAY_STOPPED;
      clearInterval(this.interval);
    } catch (err) {
      this.recordState = CommonConstants.PLAY_STOPPED;
      logger.error(`AudioRecording:audioCapturer stop err = ${JSON.stringify(err)}`);
    }
    this.isRecordOver = true;
    this.renderCreate();
  }

  capturesPause() {
    try {
      testNapi.audioCapturesPause();
      this.recordState = CommonConstants.PLAY_PAUSED;
      clearInterval(this.interval);
    } catch (err) {
      logger.error(`AudioRecording:audioCapturer stop err = ${JSON.stringify(err)}`);
    }
  }

  formatNumber(num: number) {
    if (num <= 9) {
      return '0' + num;
    } else {
      return '' + num;
    }
  }

  getDate(mode: number) {
    let date = new Date();
    if (mode === 1) {
      return `${date.getFullYear()} / ${this.formatNumber(date.getMonth() + 1)} / ${this.formatNumber(date.getDate())}`;
    } else {
      return `${date.getFullYear()}${this.formatNumber(date.getMonth() + 1)}${this.formatNumber(date.getDate())}`;
    }
  }

  getTimesBySecond(t: number) {
    let h = Math.floor(t / 60 / 60 % 24);
    let m = Math.floor(t / 60 % 60);
    let s = Math.floor(t % 60);
    let hs = h < 10 ? '0' + h : h;
    let ms = m < 10 ? '0' + m : m;
    let ss = s < 10 ? '0' + s : s;
    return `${hs}:${ms}:${ss}`;
  }
}