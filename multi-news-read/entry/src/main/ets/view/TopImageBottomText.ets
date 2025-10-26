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
export default struct TopImageBottomText {
  @Prop news: News;

  build() {
    Column() {
      Image(this.news.getFirstImage())
        .width(Constants.FULL_WIDTH)
        .borderRadius({
          topLeft: $r("app.float.normal_border_radius"),
          topRight: $r("app.float.normal_border_radius")
        })
      Text(this.news.getTitle())
        .fontSize($r("app.float.normal_font_size"))
        .fontColor(Color.Black)
        .fontFamily($r("app.string.font_family"))
        .opacity(Constants.OPACITY[2])
        .textAlign(TextAlign.JUSTIFY)
        .fontWeight(Constants.FONT_WEIGHT[1])
        .margin({
          left: $r("app.float.title_margin_space"),
          right: $r("app.float.title_margin_space")
        })
        .maxLines(Constants.MAX_LINES)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Row() {
        Row() {
          Text(this.news.getPublisher())
            .fontSize($r("app.float.small_font_size"))
            .fontColor(Color.Black)
            .fontWeight(Constants.FONT_WEIGHT[0])
            .opacity(Constants.OPACITY[0])
          Text(' ')
          Text(this.news.getTimeToNow())
            .fontSize($r("app.float.small_font_size"))
            .fontColor(Color.Black)
            .fontWeight(Constants.FONT_WEIGHT[0])
            .opacity(Constants.OPACITY[0])
          Blank()
          Image($r("app.media.ic_small_more"))
            .width($r("app.float.ic_more_size"))
            .height($r("app.float.ic_more_size"))
        }
        .width(Constants.CONTENT_WIDTH)
        .justifyContent(FlexAlign.SpaceAround)
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .width(Constants.FULL_WIDTH)
      .height($r("app.float.bigger_line_height"))
      .margin({ bottom: $r("app.float.publisher_info_space_bottom") })
    }
    .width(Constants.FULL_WIDTH)
    .height($r("app.float.cards_height"))
    .borderRadius($r("app.float.normal_border_radius"))
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r("app.color.news_background"))
  }
}