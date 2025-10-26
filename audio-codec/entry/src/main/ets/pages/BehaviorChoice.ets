/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { audio } from '@kit.AudioKit';
import { AlertDialog } from '@kit.ArkUI';
import { fileIo, picker } from '@kit.CoreFileKit';
import { CommonConstants } from '../common/CommonConstants';
import { METADATA_SERVICE, MusicMetadata } from '../common/utils/MusicMetadataService';
import { SelectPicker } from '../component/SelectPicker';
import { fileIo as fs } from '@kit.CoreFileKit';
import player from 'libplayer.so';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from '../common/utils/Logger';

@Observed
class Range {
  public data: string[][]

  constructor() {
    this.data = [[]]
  }
}

@Component
export struct BehaviorChoice {
  private uri: string = '';
  @State title: string = '';
  @State playSec: number = 0;
  @State renderState: number = 1;
  @State recordSec: number = 0;
  @State showTime: string = '00:00:00';
  @State range: Range = new Range();
  @State rangeIdx: number = 0;
  @Consume('pageInfos') pageInfos: NavPathStack;
  private interval: number = 0;
  private audioSamplingRate: number = 0;
  private audioChannelNumber: number = 0;
  @State transCodeParam: string[] = [];
  @State capturesTitle: string = '';
  dialogController: CustomDialogController | null = new CustomDialogController({
    backgroundColor: Color.White,
    builder: SelectPicker({
      title: this.getUIContext().getHostContext()!.resourceManager.getStringSync($r('app.string.transcoding_format')
        .id),
      transCodeParam: this.transCodeParam,
      audioSamplingRate: this.audioSamplingRate,
      audioChannelNumber: this.audioChannelNumber,
      confirmCancle: () => {
        this.dialogController?.close();
      },
      confirmBtn: () => {
        this.dialogController?.close();
        this.dialogControllerConfirm.open();
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
        },
      },
      secondaryButton: {
        value: this.getUIContext().getHostContext()!.resourceManager.getStringSync($r('app.string.picker_btn_confirm')
          .id),
        action: () => {
          console.info('Callback when the second button is clicked')
          this.saveFile()
          player.stop();
        }
      },
    }),
  })

  saveFile() {
    const audioSaveOptions = new picker.AudioSaveOptions();
    audioSaveOptions.newFileNames = [`${new Date().getTime()}.${this.transCodeParam[1]}`];
    let uri: string = '';
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    const audioViewPicker = new picker.AudioViewPicker(context);
    audioViewPicker.save(audioSaveOptions).then((audioSelectResult: Array<string>) => {
      uri = audioSelectResult[0];
      let file: fileIo.File | undefined;
      try {
        file = fs.openSync(uri, fs.OpenMode.READ_WRITE);
        let inputFile = fileIo.openSync(this.uri, fileIo.OpenMode.READ_ONLY);
        let inputFileState = fileIo.statSync(inputFile.fd);
        player.init(inputFile.fd, CommonConstants.DEFAULT_VALUE, inputFileState.size, file.fd, this.transCodeParam[0],
          this.transCodeParam[1]);

      } catch (err) {
        Logger.error('error:' + JSON.stringify(err));
      } finally {
        if (file !== undefined) {
          fileIo.closeSync(file.fd);
        }
      }
    }).catch((err: BusinessError) => {
      Logger.error('Save failed:' + JSON.stringify(err));
    });
  }

  aboutToAppear() {
    this.uri = this.pageInfos.getParamByName('BehaviorChoice')[0] as string;
    if (this.uri) {
      METADATA_SERVICE.fetchMetadata(this.uri).then((data: MusicMetadata) => {
        if (data.metadata?.title) {
          this.title = data.metadata.title;
        }
        if (data.metadata?.duration) {
          this.recordSec = Number(data.metadata.duration) / 1000;
        }
      })
      try {
        let inputFile = fileIo.openSync(this.uri, fileIo.OpenMode.READ_ONLY);
        let inputFileState = fileIo.statSync(inputFile.fd);
        const generatedObj = player.transcodingInit(inputFile.fd, CommonConstants.DEFAULT_VALUE, inputFileState.size);
        this.audioSamplingRate = generatedObj.sampleRate;
        this.audioChannelNumber = generatedObj.channelCount;
        player.transcodingStop();
      } catch (err) {
        Logger.error('Get file information failed:' + JSON.stringify(err));
      }
    }
    try {
      this.capturesTitle =
        this.getUIContext().getHostContext()!.resourceManager.getStringSync($r('app.string.audio_captures').id);
    } catch (err) {
      Logger.error('Get audio_captures failed:' + JSON.stringify(err));
    }
  }

  @Builder
  AudioPlayer() {
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
        Text(this.getRecordText())
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
        Progress({
          value: this.playSec,
          total: this.recordSec,
          type: ProgressType.Linear
        })
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
        this.renderState = player.capturerStart();
      } else if (this.renderState === audio.AudioState.STATE_STOPPED) {
        this.renderStart();
      }
    })
  }

  getRecordText(): Resource | string {
    let text: Resource | string;
    if (this.renderState === audio.AudioState.STATE_RUNNING) {
      text = $r('app.string.play_now');
    } else if (this.renderState === audio.AudioState.STATE_PAUSED) {
      text = $r('app.string.play_paused');
    } else {
      text = '';
    }
    return text;
  }

  renderStart() {
    try {
      player.release();
      let inputFile = fileIo.openSync(this.uri, fileIo.OpenMode.READ_ONLY);
      let inputFileState = fileIo.statSync(inputFile.fd);
      this.renderState = player.playNative(inputFile.fd, CommonConstants.DEFAULT_VALUE, inputFileState.size);
      if (this.renderState === audio.AudioState.STATE_RUNNING) {
        if (this.interval) {
          clearInterval(this.interval);
        }
        this.interval = setInterval(() => {
          let currentPosition = Math.round(player.getCurrentPosition());
          let newPlaySec = Math.floor(currentPosition / 1000);
          if (newPlaySec !== this.playSec) {
            this.playSec = newPlaySec;
          }
          if (this.playSec >= Math.floor(this.recordSec)) {
            this.renderState = audio.AudioState.STATE_STOPPED;
            this.playSec = this.recordSec;
            clearInterval(this.interval);
          }
        }, 200);
      }
    } catch (err) {
      Logger.error('RenderStart failed:' + JSON.stringify(err));
    }
  }

  renderPause() {
    this.renderState = player.pause();
  }

  aboutToDisappear() {
    if (this.interval) {
      clearInterval(this.interval);
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
      Flex({
        direction: FlexDirection.Column,
        alignItems: ItemAlign.Start,
        justifyContent: FlexAlign.SpaceBetween
      }) {
        if (this.uri) {
          this.AudioPlayer();
        }

        Button($r('app.string.transcoding'))
          .onClick(() => {
            this.renderPause();
            this.dialogController?.open();
          })
          .size({
            width: '100%',
            height: $r('app.float.index_button_height')
          })
      }
      .padding($r('app.float.border_radius'))
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .title(this.capturesTitle)
    .backgroundColor($r('app.color.audio_background'))
  }
}