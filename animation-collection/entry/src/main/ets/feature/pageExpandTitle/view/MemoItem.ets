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

import { MEMO_DATA } from '../model/MockData';
import { MemoInfo } from '../model/MemoInfo';
import Constants from '../common/Constants';

@Component
export default struct MemoItem {
  @State memoItem: MemoInfo = MEMO_DATA[0];

  build() {
    Row() {
      Column({ space: Constants.MEMO_COL_SPACE }) {
        Text($r(this.memoItem.title))
          .fontSize($r('app.float.font_size_normal'))
          .memoTextExpand()
          .fontColor($r('app.color.font_color_light_dark'))
        Text($r(this.memoItem.content))
          .fontSize($r('app.float.font_size_smaller'))
          .memoTextExpand()
          .margin({ top: $r('app.float.layout_10'), bottom: $r('app.float.layout_10') })
          .fontColor($r('app.color.font_color_light_dark'))
        Text(this.memoItem.time)
          .fontSize($r('app.float.font_size_smaller'))
          .memoTextExpand()
          .fontColor(Color.Grey)
      }
      .alignItems(HorizontalAlign.Start)
      .width(Constants.LAYOUT_SEVENTY_PERCENT)

      Image($r(this.memoItem.imageSrc))
        .width($r('app.float.layout_90'))
        .aspectRatio(Constants.MEMO_IMAGE_ASPECT_RATIO)
        .borderRadius($r('app.float.layout_10'))
    }
    .height($r('app.float.layout_110'))
    .backgroundColor($r('app.color.list_item_normal_color'))
    .width(Constants.LAYOUT_MAX_PERCENT)
    .justifyContent(FlexAlign.SpaceBetween)
    .borderRadius($r('app.float.list_item_border_radius'))
    .padding({ left: $r('app.float.list_item_padding'), right: $r('app.float.list_item_padding') })
  }
}

@Extend(Text)
function memoTextExpand() {
  .textOverflow({ overflow: TextOverflow.Ellipsis })
  .maxLines(Constants.MAX_TEXT_LINES)
}