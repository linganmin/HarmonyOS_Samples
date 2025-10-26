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

import { CardListComponent } from '../view/CardListComponent';
import { CardListParameter } from '../viewmodel/CardListParameter';
import { CardListItemData } from '../../common/CommonData';
// [Start widget_card]
let storageLocal = new LocalStorage();

@Entry(storageLocal)
@Component
struct WidgetCard {
  // [StartExclude widget_card]
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
   * The width percentage setting.
   */
  readonly FULL_WIDTH_PERCENT: string = '100%';
  /*
   * The height percentage setting.
   */
  readonly FULL_HEIGHT_PERCENT: string = '100%';
  // [EndExclude widget_card]
  @LocalStorageProp('formTime') @Watch('onFormTimeChange') formTime: string = '';
  @LocalStorageProp('formId') formId: string = '';
  // [StartExclude widget_card]
  @LocalStorageProp('cardList') cardList: Array<CardListItemData> = [];
  @State cardListParameter: CardListParameter = new CardListParameter($r('sys.color.ohos_id_color_background'),
    $r('app.string.card_list_title'), '', ImageSize.Cover, $r('app.media.logo'), false,
    $r('sys.color.ohos_id_color_background'), true, this.cardList.length, $r('sys.color.ohos_id_color_emphasize'),
    $r('app.color.list_item_count_background'), '', false);
  // [EndExclude widget_card]
  onFormTimeChange() {
    // [StartExclude widget_card]
    postCardAction(this, {
      action: 'call',
      abilityName: 'EntryAbility',
      params: {
        formId: this.formId,
        method: 'updateCardInfo',
        message: 'Call refresh card.'
      }
    });
    // [EndExclude widget_card]
  }
  // [StartExclude widget_card]
  @Builder
  buttonBuilder(text: ResourceStr) {
    Column() {
      Image($r('app.media.refresh'))
        .width($r('app.float.refresh_image_size'))
        .height($r('app.float.refresh_image_size'))

      Text(text)
        .fontColor($r('app.color.refresh_color'))
        .fontSize($r('app.float.item_content_font_size'))
        .margin({ top: $r('app.float.text_image_space') })
    }
    .justifyContent(FlexAlign.Center)
    .height($r('app.float.refresh_area_height'))
    .width($r('app.float.refresh_area_width'))
    .borderRadius($r('app.float.border_radius'))
    .backgroundColor($r('sys.color.comp_background_focus'))
  }

  @Builder
  cardListBuilder() {
    if (this.cardList.length > 0) {
      Column() {
        Column() {
          ForEach(this.cardList, (item: CardListItemData) => {
            ListItem() {
              Row() {
                Column() {
                  Text(item.title)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .fontSize($r('app.float.item_content_font_size'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Color.Black)
                    .height($r('app.float.item_text_height'))
                    .margin({ top: $r('app.float.item_text_margin') })
                  Text(item.content)
                    .maxLines(1)
                    .fontSize($r('app.float.item_content_font_size'))
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .fontWeight(FontWeight.Regular)
                    .height($r('app.float.item_text_height'))

                  Divider()
                    .strokeWidth(0.38)
                    .lineCap(LineCapStyle.Square)
                    .margin({ top: $r('app.float.list_divider_margin') })
                    .visibility(item.id === 4 ? Visibility.None : Visibility.Visible)
                }
                .margin({ right: $r('app.float.list_row_margin') })
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Image(item.icon)
                  .width($r('app.float.item_image_size'))
                  .height($r('app.float.item_image_size'))
                  .borderRadius($r('app.float.border_radius'))
              }
              .alignItems(VerticalAlign.Center)
              .width(this.FULL_WIDTH_PERCENT)
            }
            .width(this.FULL_WIDTH_PERCENT)
            .height($r('app.float.item_height'))
          }, (item: CardListItemData, index) => index + JSON.stringify(item))
        }

        Row() {
          // [Start button_builder2]
          Row(){
            this.buttonBuilder($r('app.string.router'))
          }
          .onClick(() => {
            postCardAction(this, {
              action: 'router',
              abilityName: 'EntryAbility',
              params: {
                message: 'Router refresh card.'
              }
            });
          })
          // [End button_builder2]

          // [Start button_builder1]
          Row() {
            this.buttonBuilder($r('app.string.call'))
          }
          .onClick(() => {
            postCardAction(this, {
              action: 'call',
              abilityName: 'EntryAbility',
              params: {
                formId: this.formId,
                method: 'updateCardInfo',
                params: {
                  message: 'Call refresh card.'
                }
              }
            });
          })
          // [End button_builder1]

          // [Start button_builder]
          Row() {
            this.buttonBuilder($r('app.string.message'))
          }
          .onClick(() => {
            postCardAction(this, {
              action: 'message',
              params: {
                message: 'Message refresh card.'
              }
            });
          })
          // [End button_builder]
        }
        .width(this.FULL_WIDTH_PERCENT)
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .height(this.FULL_HEIGHT_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
    }
  }
  // [EndExclude widget_card]
  build() {
    // [StartExclude widget_card]
    Row() {
      CardListComponent({ cardListParameter: this.cardListParameter }) {
        this.cardListBuilder()
      }
    }
    .height(this.FULL_HEIGHT_PERCENT)
    .onClick(() => {
      postCardAction(this, {
        action: this.ACTION_TYPE,
        abilityName: this.ABILITY_NAME,
        params: {
          message: this.MESSAGE
        }
      });
    })
    // [EndExclude widget_card]
  }
}
// [End widget_card]