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

import { RouterType } from '../model/FormCardConstant';

let storageUpdateCall2 = new LocalStorage();
// [Start type_entry_width]
// [Start music_recommended_card_update_image]
// [Start music_recommended_card_jump_card]
// src/main/ets/widget/pages/RecommendedMusic2x4.ets
@Entry(storageUpdateCall2)
@Component
struct RecommendedMusic2x4 {
  readonly ABILITY_NAME: string = 'EntryAbility';
  readonly ACTION_TYPE: string = 'router';
  // [StartExclude music_recommended_card_jump_card]
  @LocalStorageProp('imgBg') imgBg: ResourceStr = '';
  @LocalStorageProp('isLoaded') isLoaded: boolean = false;
  // [StartExclude type_entry_width]
  // [StartExclude music_recommended_card_update_image]
  @LocalStorageProp('imageColor') imageColor: string = '#5F1F1F';
  @LocalStorageProp('imageColorHex') imageColorHex: string = '18191d';
  // [EndExclude type_entry_width]
  // [EndExclude music_recommended_card_update_image]
  // [EndExclude music_recommended_card_jump_card]

  build() {
    FormLink({
      action: this.ACTION_TYPE,
      abilityName: this.ABILITY_NAME,
    }) {
      Row() {
        Image(this.isLoaded ? `memory://${this.imgBg}` : $r('app.media.ic_avatar16'))
          // [StartExclude music_recommended_card_jump_card]
          .height('100%')
          .borderRadius(10)
          .layoutWeight(1)
          .margin({ right: 6 })
        // [EndExclude music_recommended_card_jump_card]
        // [StartExclude type_entry_width]
        // [StartExclude music_recommended_card_update_image]
        Column() {
          FormLink({
            action: this.ACTION_TYPE,
            abilityName: this.ABILITY_NAME,
            params: {
              type: RouterType.COLLECTED
            }
          }) {
            Column() {
              Text($r('app.string.my_collect'))
                // [StartExclude music_recommended_card_jump_card]
                .fontWeight(700)
                .fontSize(16)
                .fontColor('#DBFFFFFF')
              // [EndExclude music_recommended_card_jump_card]
              Text('Favorite songs')
                // [StartExclude music_recommended_card_jump_card]
                .fontColor('#99FFFFFF')
                .margin({ top: 7 })
              // [EndExclude music_recommended_card_jump_card]
            }
            // [StartExclude music_recommended_card_jump_card]
            .padding({
              left: 12,
              right: 12
            })
            .borderRadius(10)
            .width('100%')
            .height('50%')
            .layoutWeight(1)
            .backgroundColor('#26000000')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Start)
            // [EndExclude music_recommended_card_jump_card]
          }

          FormLink({
            action: this.ACTION_TYPE,
            abilityName: this.ABILITY_NAME,
            params: {
              type: RouterType.PLAYLISTS
            }
          }) {
            Column() {
              Text($r('app.string.hot_playlists'))
                // [StartExclude music_recommended_card_jump_card]
                .fontWeight(700)
                .fontSize(16)
                .fontColor('#DBFFFFFF')
              // [EndExclude music_recommended_card_jump_card]
              Text('Hot playlists')
                // [StartExclude music_recommended_card_jump_card]
                .fontColor('#99FFFFFF')
                .margin({ top: 7 })
              // [EndExclude music_recommended_card_jump_card]
            }
            // [StartExclude music_recommended_card_jump_card]
            .padding({
              left: 12,
              right: 12
            })
            .borderRadius(10)
            .width('100%')
            .height('50%')
            .layoutWeight(1)
            .backgroundColor('#26000000')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Start)
            .margin({
              top: 5
            })
            // [EndExclude music_recommended_card_jump_card]
          }
        }
        .layoutWeight(1)
        .margin({ left: 6 })
        // [EndExclude type_entry_width]
        // [EndExclude music_recommended_card_update_image]
      }
      // [StartExclude type_entry_width]
      // [StartExclude music_recommended_card_update_image]
      // [StartExclude music_recommended_card_jump_card]
      .width('100%')
      .height('100%')
      .linearGradient({
        direction: GradientDirection.Bottom,
        repeating: false,
        colors: [[`#ff${this.imageColorHex}`, 0.0], [`#cc${this.imageColorHex}`, 0.5], [`#99${this.imageColorHex}`, 0.7]]
      })
      .padding(12)
      // [EndExclude type_entry_width]
      // [EndExclude music_recommended_card_update_image]
      // [EndExclude music_recommended_card_jump_card]
    }
  }
}
// [End type_entry_width]
// [End music_recommended_card_update_image]
// [End music_recommended_card_jump_card]
