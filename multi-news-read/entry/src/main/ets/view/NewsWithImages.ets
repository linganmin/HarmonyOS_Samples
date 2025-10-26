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
export default struct NewsWithImages {
  @Prop news: News;

  build() {
    Column() {
      Text(this.news.getTitle())
        .fontSize($r("app.float.normal_font_size"))
        .lineHeight($r("app.float.multi_image_news_line_height"))
        .opacity(Constants.OPACITY[2])
        .fontColor(Color.Black)
        .fontWeight(Constants.FONT_WEIGHT[1])
        .width(Constants.FULL_WIDTH)
        .margin({ bottom: $r("app.float.text_margin_image") })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Row() {
        ForEach(this.news.getImages(), (item: Resource) => {
          Image(item)
            .width(Constants.ONE_THIRD_WIDTH)
            .objectFit(ImageFit.Cover)
        }, (item: Resource) => JSON.stringify(item))
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .width(Constants.FULL_WIDTH)

      Row() {
        Row() {
          Text(this.news.getPublisher())
            .opacity(Constants.OPACITY[0])
            .fontFamily($r("app.string.font_family"))
            .fontSize($r("app.float.small_font_size"))
            .fontColor(Color.Black)
            .fontWeight(Constants.FONT_WEIGHT[0])
          Text(' ')
          Text(this.news.getTimeToNow())
            .opacity(Constants.OPACITY[0])
            .fontFamily($r("app.string.font_family"))
            .fontSize($r("app.float.small_font_size"))
            .fontColor(Color.Black)
            .fontWeight(Constants.FONT_WEIGHT[0])
        }

        Image($r("app.media.ic_small_more"))
          .width($r("app.float.small_more_icon_size"))
          .height($r("app.float.small_more_icon_size"))
      }
      .width(Constants.FULL_WIDTH)
      .height($r("app.float.bigger_line_height"))
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width(Constants.FULL_WIDTH)

  }
}