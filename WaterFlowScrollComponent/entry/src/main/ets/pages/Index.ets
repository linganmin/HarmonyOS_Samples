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

import { ChildRoute, CommonConstants, Route } from '../common/constants/CommonConstants';

@Entry
@Component
struct Index {
  private routes: Route[] = CommonConstants.ROUTES;
  private one: number = 1;

  build() {
    Column() {
      Row() {
        Text($r('app.string.title'))
          .fontWeight(FontWeight.Bold)
          .fontSize($r('app.float.large_title_font_size'))
          .width(CommonConstants.FULL_WIDTH)
          .fontColor($r('app.color.text_color'))
      }
      .padding(CommonConstants.PADDING)
      .width(CommonConstants.FULL_WIDTH)
      .height(CommonConstants.INDEX_TITLE_HEIGHT)

      Column() {
        ForEach(this.routes, (item: Route) => {
          Row() {
            Text(item.title)
              .width(CommonConstants.INDEX_CONTENT_WIDTH)
              .fontSize($r('app.float.double_text_size'))
              .fontColor($r('app.color.index_text_color'))
          }
          .height(CommonConstants.CARD_TITLE_HEIGHT)

          Column() {
            ForEach(item.child, (itemChild: ChildRoute, index: number) => {
              Column() {
                Row() {
                  Text(itemChild.text)
                    .height(CommonConstants.CARD_TEXT_HEIGHT)
                    .fontWeight(FontWeight.Medium)
                    .padding({ left: $r('app.float.index_item_padding_left') })
                    .fontSize($r('app.float.text_size'))
                  Column().layoutWeight(1)
                  Image($r('app.media.ic_public_arrow_right'))
                    .width($r('app.float.index_arrow_width')).height($r('app.float.index_arrow_height'))
                    .margin({ right: $r('app.float.index_item_margin_right') })
                }.justifyContent(FlexAlign.Start)
                .alignItems(VerticalAlign.Center)

                Stack() {
                  if (item.child.length - this.one !== index) {
                    Row()
                      .height(CommonConstants.DIVIDER_HEIGHT)
                      .backgroundColor($r('app.color.index_divider_color'))
                      .width(CommonConstants.DIVIDER_WIDTH)
                  }
                }
              }
              .onClick(() => {
                this.getUIContext().getRouter().pushUrl({
                  url: 'pages/' + itemChild.to
                });
              })
              .width(CommonConstants.INDEX_CONTENT_WIDTH)
              .height(CommonConstants.CARD_TEXT_HEIGHT)
            }, (item: ChildRoute, index: number) => JSON.stringify(item) + index)
          }
          .margin({ top: $r('app.float.margin_index_top'), bottom: $r('app.float.margin_index_bottom') })
          .borderRadius(CommonConstants.BORDER_RADIUS_INDEX_LIST)
          .backgroundColor(Color.White)
        }, (item: Route, index: number) => JSON.stringify(item) + index)
      }
      .width(CommonConstants.FULL_WIDTH)
    }
    .padding({ top: $r('app.float.padding_index_top') })
    .translate({ y: CommonConstants.TRANSLATE_TOP })
    .backgroundColor($r('app.color.home_background_color'))
    .width(CommonConstants.FULL_WIDTH)
    .height(CommonConstants.LIST_CONTENT_HEIGHT)
    .alignItems(HorizontalAlign.Center)
  }
}

