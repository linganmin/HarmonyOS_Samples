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
export default struct LeftTextRightImageBgWhite {
  @StorageProp('currentBreakpoint') curBp: string = '';
  @Prop news: News;

  build() {
    Flex({
      justifyContent: FlexAlign.SpaceBetween,
      alignItems: ItemAlign.Center
    }) {
      Column() {
        Text(this.news.getTitle())
          .fontSize($r("app.float.normal_font_size"))
          .width(Constants.FULL_WIDTH)
          .maxLines(Constants.MAX_LINES)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.news.getBrief())
          .opacity(Constants.OPACITY[1])
          .fontSize($r("app.float.brief_font_size"))
          .lineHeight($r("app.float.brief_line_height"))
          .fontWeight(Constants.FONT_WEIGHT[0])
          .fontSize($r("app.float.brief_font_size"))
          .maxLines(Constants.MAX_LINES)
          .maxLines(Constants.MAX_LINES)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .visibility(this.curBp === 'lg' ? Visibility.Visible : Visibility.Hidden)

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
      }
      .margin({ right: $r("app.float.text_margin_image") })
      .flexGrow(1)
      .flexShrink(1)
      .height(Constants.FULL_HEIGHT)
      .justifyContent(FlexAlign.SpaceAround)
      .alignItems(HorizontalAlign.Start)

      Column() {
        Image(this.news.getFirstImage())
          .height(Constants.FULL_HEIGHT)
          .borderRadius($r("app.float.image_border_radius"))
      }
      .aspectRatio(Constants.ASPECT_RATIO)
      .justifyContent(FlexAlign.Center)
      .height(Constants.FULL_HEIGHT)
    }
    .width(Constants.FULL_WIDTH)
    .height($r("app.float.left_text_right_image_height"))
    .padding({
      top: $r("app.float.left_text_right_image_normal_padding"),
      bottom: $r("app.float.left_text_right_image_bottom_padding")
    })
  }
}