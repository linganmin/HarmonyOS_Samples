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
import { News } from '../viewmodel/ImageAndTextViewModel';

@Component
export default struct VideoCard {
  @Prop news: News;

  build() {
    Column() {
      RelativeContainer() {
        Image(this.news.getFirstImage())
          .width(Constants.FULL_WIDTH)
          .borderRadius($r("app.float.normal_border_radius"))
          .alignRules({
            top: { anchor: "__container__", align: VerticalAlign.Top },
            left: { anchor: "__container__", align: HorizontalAlign.Start }
          })
          .id("backgroundImg")

        Row() {
          Image($r("app.media.ic_pause"))
            .width($r("app.float.play_icon_width"))
            .height($r("app.float.play_icon_height"))
        }
        .alignRules({
          middle: { anchor: "__container__", align: HorizontalAlign.Center },
          center: { anchor: "__container__", align: VerticalAlign.Center }
        })
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .backgroundColor(Color.Black)
        .opacity(Constants.OPACITY[0])
        .borderRadius($r("app.float.bigger_border_radius"))
        .width($r("app.float.play_icon_size"))
        .height($r("app.float.play_icon_size"))
        .id("playBtn")

        Column() {
          Row() {
            Text(this.news.getTitle())
              .opacity(Constants.OPACITY[2])
              .fontFamily($r("app.string.font_family"))
              .fontSize($r("app.float.normal_font_size"))
              .fontColor(Color.White)
              .letterSpacing(Constants.LETTER_SPACE)
              .textAlign(TextAlign.JUSTIFY)
              .fontWeight(Constants.FONT_WEIGHT[1])

          }
          .width($r("app.float.video_card_title_width"))
          .height($r("app.float.video_card_title_height"))

          Row() {
            Row() {
              Text(this.news.getPublisher())
                .opacity(Constants.OPACITY[0])
                .fontFamily($r("app.string.font_family_normal"))
                .fontSize($r("app.float.small_font_size"))
                .fontColor(Color.White)
                .fontWeight(Constants.FONT_WEIGHT[0])
              Text(' ')
              Text(this.news.getTimeToNow())
                .opacity(Constants.OPACITY[0])
                .fontFamily($r("app.string.font_family_normal"))
                .fontSize($r("app.float.small_font_size"))
                .fontColor(Color.White)
                .fontWeight(Constants.FONT_WEIGHT[0])
            }
            Image($r("app.media.ic_small_more"))
              .width($r("app.float.ic_more_size"))
              .height($r("app.float.ic_more_size"))
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .width($r("app.float.video_card_info_width"))
          .height($r("app.float.video_card_info_height"))

        }
        .alignItems(HorizontalAlign.Start)
        .alignRules({
          bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
        })
        .padding({
          left: $r("app.float.video_card_info_padding"),
          bottom: $r("app.float.video_card_info_padding")
        })
        .id("newsInfo")

        Row() {
          Text(this.news.getDuration())
            .width($r("app.float.duration_width"))
            .height($r("app.float.duration_height"))
            .fontFamily($r("app.string.font_family_normal"))
            .fontSize($r("app.float.smallest_font_size"))
            .fontColor(Color.White)
            .lineHeight($r("app.float.small_line_height"))
            .fontWeight(Constants.FONT_WEIGHT[0])
            .backgroundColor(Color.Black)
            .borderRadius($r("app.float.small_border_radius"))

        }
        .width($r("app.float.duration_container_width"))
        .height($r("app.float.duration_container_height"))
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Top)
        .opacity(Constants.OPACITY[1])
        .alignRules({
          right: { anchor: "__container__", align: HorizontalAlign.End },
          bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
        })
        .id("duration")

      }
    }
    .width(Constants.FULL_WIDTH)
    .height($r("app.float.cards_height"))
    .borderRadius($r("app.float.normal_border_radius"))
  }
}