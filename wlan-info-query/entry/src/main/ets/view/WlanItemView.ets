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

import { Constants } from '../common/constants/Constants';

@Component
export struct WlanItemView {
  @Consume pageInfos: NavPathStack;
  @State itemDesc: ResourceStr = $r('app.string.nonSense');
  src: Resource = $r('app.media.icon');
  content: Resource = $r('app.string.nonSense');
  isLinkAddress: boolean = false;
  targetPage?: string = '';

  build() {
    Row() {
      Image(this.src)
        .width($r('app.float.image_width'))
        .aspectRatio(1)
        .fillColor($r('sys.color.ohos_id_color_primary'))

      Column() {
        Text(this.itemDesc)
          .fontSize($r('app.float.info_title_font_size'))
          .lineHeight($r('app.float.info_line_height'))
          .fontWeight(Constants.INFO_TITLE_FONT_WEIGHT)
          .fontColor(this.isLinkAddress ? $r('app.color.connect_font_color') :
            $r('sys.color.ohos_id_color_text_primary'))
          .align(Alignment.Start)
        if (this.content) {
          Text(this.content)
            .fontWeight(FontWeight.Regular)
            .fontSize($r('app.float.info_msg_font_size'))
            .fontColor($r('sys.color.mask_secondary'))
            .margin({ top: $r('app.float.msg_margin_top') })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: $r('app.float.info_margin_left') })

      Blank()

      Image($r('app.media.info_circle'))
        .width($r('app.float.image_width'))
        .aspectRatio(1)
        .onClick(() => {
          if (this.targetPage) {
            this.pageInfos.pushPathByName('pageOne', this.targetPage);
          }
        })
    }
    .height($r('app.float.info_height'))
    .borderRadius($r('app.float.info_border_radius'))
    .width(Constants.FULL_PERCENT)
    .padding({
      left: $r('app.float.info_padding_left'),
      right: $r('app.float.info_padding_left')
    })
  }
}