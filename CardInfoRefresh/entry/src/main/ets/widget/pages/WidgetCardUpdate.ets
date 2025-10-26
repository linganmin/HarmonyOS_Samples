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

import { CommonConstants } from '../../common/CommonConstants';
import { CardListItemData } from '../../common/CommonData';

let localStorage = new LocalStorage();

@Entry(localStorage)
@Component
struct Widget1Card {
  @LocalStorageProp('formId') formId: string = '';
  @LocalStorageProp('cardList') itemData: CardListItemData[] = [CommonConstants.CARD_LIST_DATA_FIRST[0]];
  /*
   * The action type.
   */
  readonly ACTION_TYPE: string = 'router';
  /*
   * The ability name.
   */
  readonly ABILITY_NAME: string = 'EntryAbility';
  /*
   * The message.
   */
  readonly MESSAGE: string = 'add detail';
  /*
   * The height percentage setting.
   */
  readonly FULL_HEIGHT_PERCENT: string = '100%';

  build() {
    Column() {
      Text(this.itemData[0].title)
        .maxLines(1)
        .fontColor(Color.White)
        .fontSize(18)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontWeight(FontWeight.Bold)
        .margin({
          left: 12,
          top: 12,
          right: 12
        })
      Blank()
      Row({ space: 12 }) {
          Text(this.itemData[0].content)
            .layoutWeight(1)
            .maxLines(2)
            .fontColor(Color.White)
            .fontSize(14)
            .lineHeight(19)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row(){
          if (!this.itemData[0].favour) {
            SymbolGlyph($r('sys.symbol.heart'))
              .fontSize(24)
              .aspectRatio(1)
              .fontColor([Color.White])
          } else {
            SymbolGlyph($r('sys.symbol.heart_fill'))
              .fontSize(24)
              .aspectRatio(1)
              .fontColor(['#E64566'])
          }
        }
          .height(26)
          .aspectRatio(1)
          .onClick(() => {
            postCardAction(this, {
              action: 'call',
              abilityName: 'EntryAbility',
              params: {
                formId: this.formId,
                msgId: this.itemData[0].id,
                method: 'updateFormFavour',
                message: 'Call refresh card.'
              }
            });
          })
      }
      .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
      .height(56)
      .alignItems(VerticalAlign.Bottom)
      .padding({
        top: 6,
        left: 12,
        right: 12,
        bottom: 12
      })
    }
    .onClick(() => {
      postCardAction(this, {
        action: this.ACTION_TYPE,
        abilityName: this.ABILITY_NAME,
        params: {
          message: this.MESSAGE
        }
      });
    })
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height('100%')
    .backgroundImage(this.itemData[0].bgImage)
    .backgroundImageSize(ImageSize.Cover)
  }
}