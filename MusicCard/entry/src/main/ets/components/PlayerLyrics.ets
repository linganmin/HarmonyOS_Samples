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

import { common } from '@kit.AbilityKit';
import { util } from '@kit.ArkTS';
import { LrcEntry } from '../lyric/LrcEntry';
import { parseKrcLyric, parseLrcLyric } from '../lyric/LrcUtils';
import LrcView from '../lyric/LrcView';
import { LyricFile, LyricScrollEffect, LyricTopPosition } from '../lyric/LyricConst';
import { PlayerControlArea } from './PlayerControlArea';
import { SongItem } from '../viewmodel/SongItem';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from '../utils/Logger';

const TAG = 'PlayerLyricsLogTag';

@Component
export struct PlayerLyrics {
  @StorageLink('progress') time: number = 0;
  @StorageLink('isPlay') isPlay: boolean = false;
  @StorageProp('currentSong') @Watch('getLrcEntryList') currentSong: SongItem = new SongItem();
  @State progressText: string = '';
  @State lyricScrollEffect: LyricScrollEffect = LyricScrollEffect.Line;
  @State mLrcEntryList: Array<LrcEntry> = [];
  private context: common.UIAbilityContext | undefined = AppStorage.get('context');

  aboutToAppear() {
    this.getLrcEntryList();
  }

  getLrcEntryList() {
    this.mLrcEntryList = [];
    if (!this.context) {
      return;
    }
    this.context.resourceManager.getRawFileContent(this.currentSong.lyric)
      .then((value: Uint8Array) => {
        let textDecoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
        let stringData = textDecoder.decodeToString(value, { stream: false });
        if (this.currentSong.lyric.endsWith(LyricFile.KRC)) {
          this.mLrcEntryList = parseKrcLyric(stringData);
        } else if (this.currentSong.lyric.endsWith(LyricFile.LRC)) {
          this.mLrcEntryList = parseLrcLyric(stringData);
        }
      }).catch((error:BusinessError) => {
      Logger.error(TAG, `getLrcEntryList err, code: ${error.code}, mesage: ${error.message}`);
    })
  }

  build() {
    Column() {
      Row() {
        Image(this.currentSong.label)
          .width($r('app.float.label_width_sm'))
          .borderRadius($r('app.float.label_border'))
          .aspectRatio(1)
          .margin({
            right: $r('app.float.label_margin_right')
          })

        Column() {
          Text($r(this.currentSong.title))
            .fontSize(16)
            .fontColor(Color.White)
            .fontWeight(700)
            .width('90%')
          Text($r(this.currentSong.singer))
            .fontSize(12)
            .fontColor($r('sys.color.ohos_id_color_text_hint_contrary'))
            .fontWeight(500)
            .margin({
              top: $r('app.float.singer_margin_top')
            })
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({
        top: 48,
        bottom: $r('app.float.info_margin_bottom')
      })

      LrcView({
        lyricMilliSecondsTime: this.time,
        mLrcEntryList: this.mLrcEntryList,
        lyricScrollEffect: this.lyricScrollEffect,
        lyricTopPosition: LyricTopPosition.Middle
      })
        .layoutWeight(1)

      Row() {
        Text($r('app.string.music_image'))
          .fontColor(Color.White)
          .fontSize(12)
          .borderWidth(1.5)
          .borderRadius(3)
          .padding({
            top: 1,
            right: 2,
            bottom: 1,
            left: 2
          })
          .fontWeight(600)
          .textAlign(TextAlign.Center)
          .opacity(0.86)
          .borderColor(Color.White)
      }
      .width('100%')
      .height($r('app.float.control_icon_height'))
      .justifyContent(FlexAlign.End)
      .margin({
        top: $r('app.float.lyric_margin_top'),
        bottom: 8,
        right: 3
      })

      PlayerControlArea()
        .margin({
          top: $r('app.float.control_lyric_margin'),
          bottom: $r('app.float.music_component_bottom')
        })
    }
    .margin({
      top: $r('app.float.margin_lyric')
    })
    .padding({
      left: $r('app.float.common_padding'),
      right: $r('app.float.common_padding')
    })
  }
}