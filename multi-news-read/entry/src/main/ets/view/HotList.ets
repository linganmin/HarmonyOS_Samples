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

import Constants from '../common/Constants';

@Component
export default struct HotList {
  @Prop hotList: Resource[];

  build() {
    Column() {
      Row() {
        Text($r("app.string.hot_rank"))
          .fontFamily($r("app.string.font_family_bold"))
          .fontSize($r("app.float.hot_rank_font_size"))
          .fontColor($r("app.color.hot_rank_font_color"))
          .textAlign(TextAlign.Start)
          .lineHeight($r("app.float.bigger_line_height"))
          .fontWeight(Constants.FONT_WEIGHT[2])
        Image($r("app.media.ic_big_more"))
          .height($r("app.float.bigger_more_icon_size"))
          .width($r("app.float.bigger_more_icon_size"))
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width(Constants.FULL_WIDTH)
      .margin({ bottom: Constants.LIST_GUTTER })

      List() {
        ForEach(this.hotList, (item: string, index: number) => {
          ListItem() {
            Row() {
              Row() {
                Text(index + 1 + '')
                  .fontColor(Color.White)
                  .fontFamily("HarmonyHeiTi")
                  .fontSize($r("app.float.small_font_size"))
                  .textAlign(TextAlign.Center)
                  .lineHeight($r("app.float.line_height"))
                  .fontWeight(Constants.FONT_WEIGHT[0])
              }
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Center)
              .width($r("app.float.rank_card_size"))
              .height($r("app.float.rank_card_size"))
              .borderRadius($r("app.float.rank_card_border_radius"))
              .backgroundColor(Constants.HOT_LIST_BACKGROUND_COLORS[index])
              .margin({ right: $r("app.float.rank_span_text") })

              Text(item)
                .fontFamily($r("app.string.font_family_normal"))
                .fontSize($r("app.float.normal_font_size"))
                .fontColor(Color.Black)
                .textAlign(TextAlign.Start)
                .lineHeight($r("app.float.rank_list_line_height"))
                .fontWeight(Constants.FONT_WEIGHT[0])
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }

          }

        }, (item: string) => item)
      }
      .width(Constants.FULL_WIDTH)
      .height(Constants.FULL_HEIGHT)
    }
    .width(Constants.FULL_WIDTH)
    .height($r("app.float.cards_height"))
    .padding($r("app.float.rank_list_padding"))
    .backgroundColor($r("app.color.news_background"))
    .borderRadius($r("app.float.normal_border_radius"))
  }
}