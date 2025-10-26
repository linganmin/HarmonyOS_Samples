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

import { CommonConstants } from '../common/constant/CommonConstants';

@Component
export struct MultiStatusButton {
  @State status: number = 2; //0不可用，1可用，2选中
  @State text: string = 'NONE';

  build() {
    Column() {
      if (this.status === 0) {
        Text(this.text)
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
          .fontColor($r('app.color.color_space_item_disable_font_color'))
          .backgroundColor($r('app.color.color_space_item_disable_bg_color'))
          .borderRadius(16)
          .padding({left: $r('app.float.color_space_item_padding_left')})
          .margin({top: $r('app.float.color_space_item_margin_left')})
      } else if (this.status === 1) {
        Text(this.text)
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
          .fontColor($r('app.color.color_space_item_enable_font_color'))
          .backgroundColor($r('app.color.color_space_item_enable_bg_color'))
          .borderRadius(16)
          .padding({left: $r('app.float.color_space_item_padding_left')})
          .margin({top: $r('app.float.color_space_item_margin_left')})
          .onTouch(()=>{
            this.status = 2;
          })
      } else if (this.status === 2) {
        Text(this.text)
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
          .fontColor($r('app.color.color_space_item_checked_font_color'))
          .backgroundColor($r('app.color.color_space_item_checked_bg_color'))
          .borderRadius(16)
          .padding({left: $r('app.float.color_space_item_padding_left')})
          .margin({top: $r('app.float.color_space_item_margin_left')})
          .borderWidth(1)
          .borderColor($r('app.color.space_item_checked_border_color'))
      }
    }
    .margin({top: $r('app.float.item_margin_top')})
    .width(CommonConstants.FULL_PERCENT)
    .height($r('app.float.sheet_item_height'))
  }
}
