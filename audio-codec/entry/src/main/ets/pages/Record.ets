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

import { abilityAccessCtrl, common } from '@kit.AbilityKit';
import { AlertDialog } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { CommonConstants } from '../common/CommonConstants';
import Logger from '../common/utils/Logger';
import { SelectPicker } from '../component/SelectPicker';
import { SavePicker } from '../component/SavePicker';
import recorder from 'librecorder.so';
import { fileIo, picker } from '@kit.CoreFileKit';
import { fileIo as fs } from '@kit.CoreFileKit';

let atManager = abilityAccessCtrl.createAtManager();

@Component
export struct Record {
  @State file: fileIo.File | undefined = undefined;
  @State recordState: string = CommonConstants.PLAY_INIT;
  @State recordSec: number = 0;
  @State showTime: string = '00:00:00';
  @State transCodeParam: string[] = [];
  @State saveFormat: string = '';
  @State desFile: fileIo.File | undefined = undefined
  private interval: number = 0;
  @State recordTitle: string = '';
  dialogController: CustomDialogController | null = new CustomDialogController({
    backgroundColor: Color.White,
    builder: SelectPicker({
      title: this.getUIContext().getHostContext()!.resourceManager.getStringSync($r('app.string.recording_format').id),
      transCodeParam: this.transCodeParam,
      confirmCancle: () => {
        this.dialogController?.close();
      },
      confirmBtn: () => {
        this.dialogController?.close();
        this.dialogSaveController?.open();
      }
    })
  })
  dialogSaveController: CustomDialogController | null = new CustomDialogController({
    builder: SavePicker({
      saveFormat: this.saveFormat,
      confirmCancle: () => {
        this.dialogSaveController?.close();
        this.recordState = CommonConstants.PLAY_INIT;
      },
      confirmBtn: () => {
        this.dialogSaveController?.close();
        this.recordState = CommonConstants.PLAY_STARTED;
        const audioSaveOptions = new picker.AudioSaveOptions();
        audioSaveOptions.newFileNames = [`${new Date().getTime()}.${this.saveFormat}`];

        let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
        const audioViewPicker = new picker.AudioViewPicker(context);

        audioViewPicker.save(audioSaveOptions).then((audioSelectResult: string[]) => {
          const uri = audioSelectResult[0];
          try {
            this.file = fs.openSync(uri, fs.OpenMode.READ_WRITE);
          } catch (err) {
            Logger.error('file open failed with err:' + JSON.stringify(err));
          }
          recorder.initNative(
            this.file!.fd,
            this.transCodeParam[0], // codec
            this.transCodeParam[1], // container
            this.transCodeParam[2], // sampleRate
            this.transCodeParam[3]  // channelCount
          );
          this.capturesStart();
        }).catch((err: BusinessError) => {
          this.showTime = '00:00:00';
          this.recordState = CommonConstants.PLAY_INIT;
          Logger.error('AudioViewPicker.save failed with err:' + JSON.stringify(err));
        });
      }
    })
  })
  dialogControllerConfirm: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: this.getUIContext().getHostContext()!.resourceManager.getStringSync($r('app.string.save_to_local')
        .id),
      primaryButton: {
        value: this.getUIContext().getHostContext()!.resourceManager.getStringSync($r('app.string.picker_btn_cancel')
          .id),
        action: () => {
          this.showTime = '00:00:00';
          this.recordState = CommonConstants.PLAY_INIT;
        },
      },
      secondaryButton: {
        value: this.getUIContext().getHostContext()!.resourceManager.getStringSync($r('app.string.picker_btn_confirm')
          .id),
        action: () => {
          this.showTime = '00:00:00';
          this.recordState = CommonConstants.PLAY_INIT;
          try {
            fileIo.closeSync(this.file?.fd)
          } catch (err) {
            Logger.error('file close failed with err:' + JSON.stringify(err));
          }
        }
      },
    }),
  })

  aboutToAppear() {
    this.initResource();
    try {
      this.recordTitle =
        this.getUIContext().getHostContext()!.resourceManager.getStringSync($r('app.string.audio_captures').id);
    } catch (err) {
      Logger.error('Get audio_captures failed:' + JSON.stringify(err));
    }
  }

  aboutToDisappear() {
    if (this.interval) {
      clearInterval(this.interval);
    }
    this.recordState = 'init';
  }

  @Builder
  InitRecord() {
    Column() {
      Image($r('app.media.ic_record'))
        .width($r('app.float.record_button_radius'))
        .height($r('app.float.record_button_radius'))
        .borderRadius($r('app.float.record_button_radius'))
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
        this.dialogController?.open();
      }).catch((err: BusinessError) => {
        Logger.error('error:' + JSON.stringify(err));
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
        .id('show_time_txt')
      Row() {
        Row() {
        }
        .width('calc(50% - 28vp)')

        Row() {
          Image($r('app.media.ic_recording'))
            .width($r('app.float.record_button_radius'))
            .height($r('app.float.record_button_radius'))
            .borderRadius($r('app.float.record_button_radius'))
            .onClick(() => {
              this.capturesStop();
            })
          Column() {
            Image($r('app.media.ic_record_playing_new'))
              .width($r('app.float.record_button_radius'))
              .height($r('app.float.record_button_radius'))
          }
          .margin({
            left: 24
          })
          .id('pause_record_btn')
          .onClick(() => {
            this.capturesPause();
          })
        }
        .width('calc(50% + 28vp)')
        .alignItems(VerticalAlign.Center)
      }
      .width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.Center)
    }
    .width(CommonConstants.FULL_PERCENT)
  }

  @Builder
  PausedRecord() {
    Column() {
      Text(this.showTime)
        .fontSize($r('app.float.time_size'))
        .fontWeight(CommonConstants.FONT_WIGHT_500)
        .margin({ bottom: $r('app.float.time_margin') })
      Row() {
        Row() {
        }
        .width('calc(50% - 28vp)')

        Row() {
          Image($r('app.media.ic_recording'))
            .width($r('app.float.record_button_radius'))
            .height($r('app.float.record_button_radius'))
            .borderRadius($r('app.float.record_button_radius'))
            .onClick(() => {
              this.capturesStop();
            })
          Column() {
            Image($r('app.media.ic_record_paused_new'))
              .width($r('app.float.record_button_radius'))
              .height($r('app.float.record_button_radius'))
          }
          .margin({
            left: 24
          })
          .id('continue_record_btn')
          .onClick(() => {
            this.capturesContinue();
          })
        }
        .width('calc(50% + 28vp)')
        .alignItems(VerticalAlign.Center)
      }
      .width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.Center)
    }
    .width(CommonConstants.FULL_PERCENT)
  }

  @Builder
  FinishedRecord() {
    Column() {
      Image($r('app.media.ic_record'))
        .width($r('app.float.record_button_radius'))
        .height($r('app.float.record_button_radius'))
        .borderRadius($r('app.float.record_button_radius'))
    }
    .width(CommonConstants.FULL_PERCENT)
    .height($r('app.float.common_title'))
    .opacity(CommonConstants.AUDIO_OPACITY)
  }

  initResource() {
    try {
      this.recordState = CommonConstants.PLAY_INIT;
    } catch (err) {
      Logger.error(`AudioRecording:createAudioCapturer err = ${JSON.stringify(err)}`);
    }
  }

  async capturesStart() {
    try {
      recorder.startNative();
      this.recordSec = 0;
      this.recordState = CommonConstants.PLAY_STARTED;
      clearInterval(this.interval);
      this.interval = setInterval(() => {
        this.recordSec++;
        this.showTime = this.getTimesBySecond(this.recordSec);
      }, CommonConstants.INTERVAL_TIME);
    } catch (err) {
      Logger.error(`Start failed: ${JSON.stringify(err)}`);
    }
  }

  capturesContinue() {
    try {
      recorder.resumeNative();
      this.recordState = CommonConstants.PLAY_CONTINUED;
      this.recordState = CommonConstants.PLAY_CONTINUED;
      Logger.info('audioCaptures start ok');
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
      Logger.error(`AudioRecording:audioCapturer start err = ${JSON.stringify(err)}`);
    }
  }

  async capturesStop() {
    try {
      recorder.stopNative();
      this.recordState = CommonConstants.PLAY_STOPPED;
      clearInterval(this.interval);
      this.dialogControllerConfirm?.open();
    } catch (err) {
      this.recordState = CommonConstants.PLAY_STOPPED;
      Logger.error(`AudioRecording:audioCapturer stop err = ${JSON.stringify(err)}`);
    }
  }

  capturesPause() {
    try {
      recorder.pauseNative();
      this.recordState = CommonConstants.PLAY_PAUSED;
      clearInterval(this.interval);
    } catch (err) {
      Logger.error(`AudioRecording:audioCapturer stop err = ${JSON.stringify(err)}`);
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

  build() {
    NavDestination() {
      Column() {
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
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.End)
      .padding($r('app.float.border_radius'))
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .title(this.recordTitle)
    .backgroundColor($r('app.color.audio_background'))
  }
}