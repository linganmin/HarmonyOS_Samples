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

let storageUpdateCall1 = new LocalStorage();
// [Start lyrics_card]
// [Start music_heart_card_color]
// src/main/ets/widget/pages/LyricsCard.ets
@Entry(storageUpdateCall1)
@Component
struct LyricsCard {
  @LocalStorageProp('musicCover') musicCover: Resource = $r('app.media.ic_dream');
  @LocalStorageProp('imageColor') imageColor: string = 'rgba(76, 72, 68, 1)';
  // [StartExclude lyrics_card]
  // [StartExclude music_heart_card_color]
  @LocalStorageProp('lrcArray') lrcArray: Array<string> =
    ['This is lyrics sample', 'This is lyrics sample', 'This is lyrics sample', 'This is lyrics sample'];
  @LocalStorageProp('formId') formId: string = '';
  @LocalStorageProp('title') title: string = 'Song Name';
  @LocalStorageProp('singer') singer: string = 'Singer';
  @LocalStorageProp('songId') songId: string = '1';
  // [EndExclude lyrics_card]
  // [EndExclude music_heart_card_color]
  build() {
    FormLink({
      action: FormCarAction.ROUTER,
      abilityName: ENTRY_ABILITY,
      params: {
        songId: this.songId,
        type: RouterType.LYRICS
      }
    }) {
      Stack() {
        Image(this.musicCover)
          .height('200%')
          .width('200%')
          .objectFit(ImageFit.Cover)
          .opacity(0.5)
          .blur(100)

        Column() {
          // [StartExclude music_heart_card_color]
          // [StartExclude lyrics_card]
          Column() {
            ForEach(this.lrcArray, (item: string, index: number) => {
              Text(item)
                .fontSize(18)
                .fontWeight(700)
                .fontColor(Color.White)
                .lineHeight(30)
                .margin({ top: index === 0 ? 0 : 12 })
                .displayPriority(this.lrcArray.length - index)
            }, (item: string, index: number) => (item + index))
          }
          .layoutWeight(1)
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Start)
          .padding({
            left: 16,
            right: 16,
            bottom: 16
          })

          Row() {
            Image(this.musicCover)
              .height(36)
              .width(36)
              .borderRadius(18)
            Text($r(this.title))
              .fontSize(14)
              .fontColor(Color.White)
              .fontWeight(700)
              .margin({
                left: 12
              })

            Divider()
              .vertical(false)
              .width(27)
              .strokeWidth(2)
              .color('#99FFFFFF')
              .lineCap(LineCapStyle.Round)
              .margin({
                left: 8,
                right: 8
              })

            Text($r(this.singer))
              .fontSize(12)
              .fontColor(Color.White)
              .opacity(0.6)
              .fontWeight(500)
          }
          .width('100%')
          // [EndExclude lyrics_card]
          // [EndExclude music_heart_card_color]
        }
        // [StartExclude lyrics_card]
        // [StartExclude music_heart_card_color]
        .padding(12)
        .backgroundImagePosition(Alignment.Start)
        .backgroundImageSize(ImageSize.Cover)
        .height('100%')
        .width('100%')
        // [EndExclude lyrics_card]
        // [EndExclude music_heart_card_color]
      }
      .backgroundColor(this.imageColor)
    }
  }
}
// [End lyrics_card]
// [End music_heart_card_color]