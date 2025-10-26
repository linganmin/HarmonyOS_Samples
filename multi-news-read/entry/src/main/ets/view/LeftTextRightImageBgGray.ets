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
export default struct LeftTextRightImageBgGray {
  @StorageProp('currentBreakpoint') curBp: string = '';
  @Prop news: News;

  build() {
    Flex({
      direction: FlexDirection.Column,
      justifyContent: FlexAlign.SpaceBetween,
      alignItems: ItemAlign.Center
    }) {
      Row() {
        Text(this.news.getTitle())
          .fontSize($r("app.float.normal_font_size"))
          .layoutWeight(Constants.LAYOUT_WEIGHT)
          .margin({ right: $r("app.float.text_margin_image") })
          .maxLines(Constants.MAX_LINES)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Image(this.news.getFirstImage())
          .height($r("app.float.square_image_size"))
          .width($r("app.float.square_image_size"))
          .borderRadius($r("app.float.image_border_radius"))
          .objectFit(ImageFit.Cover)
      }
      .width(Constants.FULL_WIDTH)
      .margin({ right: $r("app.float.text_margin_image") })
      .flexGrow(1)
      .flexShrink(1)
      .height($r("app.float.square_image_size"))
      .justifyContent(FlexAlign.SpaceAround)
      .alignItems(VerticalAlign.Center)


      Row() {
        Row() {
          Text(this.news.getPublisher())
            .fontSize($r("app.float.small_font_size"))
            .opacity(Constants.OPACITY[0])
          Text(' ')
          Text(this.news.getTimeToNow())
            .fontSize($r("app.float.small_font_size"))
            .opacity(Constants.OPACITY[0])
        }

        Blank()
        Row() {
          Image($r("app.media.ic_small_more"))
            .width($r("app.float.ic_more_size"))
            .height($r("app.float.ic_more_size"))
        }
      }
      .width(Constants.FULL_WIDTH)
      .height($r("app.float.publisher_info_height"))

    }
    .width(Constants.FULL_WIDTH)
    .height($r("app.float.left_text_right_image_height"))
    .padding({
      left: $r("app.float.left_text_right_image_normal_padding"),
      right: $r("app.float.left_text_right_image_normal_padding"),
      top: $r("app.float.left_text_right_image_normal_padding"),
      bottom: $r("app.float.left_text_right_image_bottom_padding")
    })
    .backgroundColor($r("app.color.news_background"))
    .borderRadius($r("app.float.normal_border_radius"))
  }
}