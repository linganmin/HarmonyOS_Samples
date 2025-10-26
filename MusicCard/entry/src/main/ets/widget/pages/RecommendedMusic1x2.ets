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

let storageUpdateCall3 = new LocalStorage();

@Entry(storageUpdateCall3)
@Component
struct RecommendedMusic1x2 {
  @LocalStorageProp('imgBg') imgBg: ResourceStr = '';
  @LocalStorageProp('isLoaded') isLoaded: boolean = false;
  @LocalStorageProp('imageColor') imageColor: string = '#5F1F1F';
  @LocalStorageProp('imageColorHex') imageColorHex: string = '18191d';
  /*
   * The action type.
   */
  readonly ACTION_TYPE: string = 'router';
  /*
   * The ability name.
   */
  readonly ABILITY_NAME: string = 'EntryAbility';

  build() {
    FormLink({
      action: this.ACTION_TYPE,
      abilityName: this.ABILITY_NAME,
      params: {
        type: '3'
      }
    }) {
      Row() {
        Image(this.isLoaded ? `memory://${this.imgBg}` : $r('app.media.ic_avatar16'))
          .height(30)
          .width(30)
          .borderRadius(5)
        Column() {
          Text($r('app.string.my_collect'))
            .fontSize(12)
            .fontWeight(700)
            .fontColor('#DBFFFFFF')
            .lineHeight(16)
            .maxLines(1)
          Text($r('app.string.your_liked_music'))
            .fontSize(10)
            .fontWeight(500)
            .fontColor('#99FFFFFF')
            .lineHeight(13)
            .maxLines(1)
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 6 })
      }
      .width('100%')
      .height('100%')
      .linearGradient({
        direction: GradientDirection.Bottom,
        repeating: false,
        colors: [[`#ff${this.imageColorHex}`, 0.0], [`#cc${this.imageColorHex}`, 0.5],
          [`#99${this.imageColorHex}`, 0.7]]
      })
      .padding({
        left: 12,
        right: 12
      })
    }
  }
}

