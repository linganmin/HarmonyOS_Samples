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

import { ENTRY_ABILITY, FormCarAction, RouterType } from '../model/FormCardConstant';
import ActionUtils from '../model/ActionUtils';
import { PlayActionType } from '../model/FormCardConstant';

// [Start dynamic_lyrics_main]
// [Start dynamic_lyrics_request_data]
// [Start dynamic_lyrics_play_pause_control]
// src/main/ets/widget/pages/DynamicLyrics.ets
let storageUpdateCall1 = new LocalStorage();
// [StartExclude dynamic_lyrics_play_pause_control]
const ControlAlignRules: Record<string, Record<string, string | VerticalAlign | HorizontalAlign>> = {
  'bottom': { 'anchor': '__container__', 'align': VerticalAlign.Bottom },
  'left': { 'anchor': 'musicCover', 'align': HorizontalAlign.End }
};

@Extend(Image)
function controlImageBuilder() {
  .aspectRatio(1)
  .opacity(0.86)
  .objectFit(ImageFit.Contain)
}

// [EndExclude dynamic_lyrics_play_pause_control]
// [Start dynamic_lyrics_arr_local_prop]
@Entry(storageUpdateCall1)
@Component
struct DynamicLyrics {
  // [StartExclude dynamic_lyrics_play_pause_control]
  @LocalStorageProp('lrcArray') lrcArray: Array<string> =
    ['This is lyrics sample', 'This is lyrics sample', 'This is lyrics sample', 'This is lyrics sample'];
  // [EndExclude dynamic_lyrics_play_pause_control]
  @LocalStorageProp('formId') formId: string = '';
  @LocalStorageProp('isPlay') isPlay: boolean = false;
  // [StartExclude dynamic_lyrics_arr_local_prop]
  // [StartExclude dynamic_lyrics_play_pause_control]
  @LocalStorageProp('title') title: string = 'Song Name';
  @LocalStorageProp('singer') singer: string = 'Singer';
  @LocalStorageProp('musicCover') musicCover: Resource = $r('app.media.ic_dream');
  @LocalStorageProp('songId') songId: string = '';
  @LocalStorageProp('imageColor') imageColor: string = 'rgba(76, 72, 68, 1)';
  @LocalStorageProp('currentLyricIndex') currentLyricIndex: number = 0;
  @LocalStorageProp('isNeedRequestUpdate') @Watch('requestData') isNeedRequestUpdate: boolean = false;

  requestData() {
    ActionUtils.updateControlCardAction(this, this.formId);
  }

  // [End dynamic_lyrics_request_data]
  // [EndExclude dynamic_lyrics_play_pause_control]
  // [StartExclude dynamic_lyrics_request_data]
  // [StartExclude dynamic_lyrics_main]
  build() {
    // [StartExclude dynamic_lyrics_play_pause_control]
    FormLink({
      action: FormCarAction.ROUTER,
      abilityName: ENTRY_ABILITY,
      params: {
        songId: this.songId,
        type: RouterType.LYRICS
      }
    }) {
      // [EndExclude dynamic_lyrics_main]
      Stack() {
        Image(this.musicCover)
          // [StartExclude dynamic_lyrics_main]
          .height('200%')
          .width('200%')
          .objectFit(ImageFit.Cover)
          .opacity(0.5)
          .blur(100)
        // [EndExclude dynamic_lyrics_main]
        Column() {
          // [Start dynamic_lyrics_animation]
          Column() {
            ForEach(this.lrcArray.slice(0, 2), (item: string, index: number) => {
              Text(item)
                .fontSize(index <= this.currentLyricIndex ? 16 : 13)
                .fontWeight(700)
                .fontColor(index <= this.currentLyricIndex ? Color.White : '#99FFFFFF')
                .lineHeight(30)
                .margin({ top: index === 0 ? 0 : 12 })
                .displayPriority(this.lrcArray.length - index)
                .transition(TransitionEffect.OPACITY.animation({ duration: 200, curve: Curve.Smooth,tempo:2 }))
            }, (item: string, index: number) => (item + index))
          }
          // [End dynamic_lyrics_animation]
          // [StartExclude dynamic_lyrics_main]
          .layoutWeight(1)
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Start)
          .padding({
            left: 16,
            right: 16,
            bottom: 10
          })

          // [EndExclude dynamic_lyrics_main]
          Row() {
            Row() {
              Image(this.musicCover)// [StartExclude dynamic_lyrics_main]
                .height(36)
                .width(36)
                .borderRadius(10)
              // [EndExclude dynamic_lyrics_main]
              Text($r(this.title))
                // [StartExclude dynamic_lyrics_main]
                .fontSize(14)
                .fontColor(Color.White)
                .fontWeight(700)
                .margin({
                  left: 12
                })
              // [EndExclude dynamic_lyrics_main]
            }
            .width('40%')

            // [EndExclude dynamic_lyrics_play_pause_control]
            Row() {
              SymbolGlyph($r('sys.symbol.backward_end_fill'))
                // [StartExclude dynamic_lyrics_main]
                .fontSize(24)
                .fontColor(['#E5FFFFFF'])
                .onClick(() => {
                  ActionUtils.playByAction(this, PlayActionType.PREVIOUS, this.formId);
                })
              // [EndExclude dynamic_lyrics_main]
              Image(this.isPlay ? $r('app.media.ic_public_pause') :
              $r('app.media.ic_public_play'))
                // [StartExclude dynamic_lyrics_main]
                .controlImageBuilder()
                .width(25)
                .margin({
                  left: 20,
                  right: 20
                })
                .onClick(() => {
                  if (this.isPlay) {
                    ActionUtils.playByAction(this, PlayActionType.PAUSE, this.formId);
                  } else {
                    ActionUtils.playByAction(this, PlayActionType.PLAY, this.formId);
                  }
                })
              // [EndExclude dynamic_lyrics_main]
              SymbolGlyph($r('sys.symbol.forward_end_fill'))// [StartExclude dynamic_lyrics_main]
                .fontSize(24)
                .fontColor(['#E5FFFFFF'])
                .onClick(() => {
                  ActionUtils.playByAction(this, PlayActionType.NEXT, this.formId);
                })
              // [EndExclude dynamic_lyrics_main]
            }
          }
          // [StartExclude dynamic_lyrics_play_pause_control]
          // [StartExclude dynamic_lyrics_main]
          .width('100%')
          .height(50)
          .justifyContent(FlexAlign.SpaceBetween)
          .alignRules(ControlAlignRules)
          .backgroundColor(this.imageColor)
          .opacity(0.8)
          .padding({
            top: 13,
            left: 10,
            right: 10,
            bottom: 10
          })

          // [EndExclude dynamic_lyrics_main]
        }
        // [StartExclude dynamic_lyrics_main]
        .backgroundImagePosition(Alignment.Start)
        .backgroundImageSize(ImageSize.Cover)
        .height('100%')
        .width('100%')

        // [EndExclude dynamic_lyrics_main]
      }
      // [StartExclude dynamic_lyrics_main]
      .backgroundColor(this.imageColor)
      .onClick(() => {
        ActionUtils.jumpPlayPage(this);
      })

      // [EndExclude dynamic_lyrics_main]
    }
  }

  // [EndExclude dynamic_lyrics_play_pause_control]

  // [EndExclude dynamic_lyrics_request_data]
  // [EndExclude dynamic_lyrics_arr_local_prop]
}
// [End dynamic_lyrics_arr_local_prop]

// [End dynamic_lyrics_main]
// [End dynamic_lyrics_play_pause_control]