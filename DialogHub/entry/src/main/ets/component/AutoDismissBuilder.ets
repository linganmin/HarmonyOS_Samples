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
import CommonConstant from "../utils/CommonConstant"

export class AutoDismissParams {
  onCancel: () => void;

  constructor(onCancel: () => void) {
    this.onCancel = onCancel;
  }
}

@Builder
export function AutoDismissBuilder(param: AutoDismissParams) {
  Column() {
    Row() {
      Text($r('app.string.Auto_dismiss_builder_title'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.item_text_color'))
        .fontSize($r('app.float.font_size_large'))
        .layoutWeight(1)
      Image($r('app.media.icon_close'))
        .width($r('app.float.auto_dismiss_close_size'))
        .height($r('app.float.auto_dismiss_close_size'))
        .onClick(() => {
          param.onCancel();
        })
    }.width('100%').alignItems(VerticalAlign.Center)

    Text($r('app.string.Auto_dismiss_builder_content'))
      .fontSize($r('app.float.font_size_regular'))
      .fontColor($r('app.color.auto_dismiss_content_color'))
    Image($r('app.media.bg_phone'))
      .width(CommonConstant.FULL_LENGTH)
      .height($r('app.float.auto_dismiss_content_bg_height'))
      .margin({
        top: $r('app.float.auto_dismiss_content_bg_top_margin'),
        bottom: $r('app.float.auto_dismiss_content_bg_bottom_margin')
      })
    Text($r('app.string.Auto_dismiss_builder_desc'))
      .fontColor($r('app.color.item_text_color'))
      .fontSize($r('app.float.font_size_regular'))
    Row() {
      Text($r('app.string.Auto_dismiss_builder_content_rmb'))
        .fontWeight(FontWeight.Medium)
        .fontSize($r('app.float.font_size_regular'))
        .fontColor($r('app.color.base_red'))
        .alignSelf(ItemAlign.Baseline)
      Text($r('app.string.Auto_dismiss_builder_content_price'))
        .fontWeight(FontWeight.Medium)
        .fontSize($r('app.float.font_size_larger'))
        .fontColor($r('app.color.base_red'))
        .layoutWeight(1)
      Text($r('app.string.Auto_dismiss_builder_content_more'))
        .fontSize($r('app.float.font_size_regular'))
        .fontColor($r('app.color.auto_dismiss_content_color'))
      Image($r('app.media.icon_right'))
        .width($r('app.float.auto_dismiss_right_width'))
        .height($r('app.float.auto_dismiss_right_height'))
    }
    .margin({ top: $r('app.float.auto_dismiss_builder_margin'), bottom: $r('app.float.auto_dismiss_builder_margin') })
    .width(CommonConstant.FULL_LENGTH)

    Row() {
      Button($r('app.string.Not_interested'))
        .commonButton()
      Button($r('app.string.Find_out_more'))
        .commonButton()
    }.justifyContent(FlexAlign.SpaceBetween).width(CommonConstant.FULL_LENGTH)
  }
  .width($r('app.float.auto_dismiss_builder_width'))
  .height($r('app.float.auto_dismiss_builder_height'))
  .padding($r('app.float.auto_dismiss_builder_padding'))
  .alignItems(HorizontalAlign.Start)
}

@Extend(Button)
function commonButton() {
  .width($r('app.float.auto_dismiss_action_width'))
  .height($r('app.float.auto_dismiss_action_height'))
  .fontWeight(FontWeight.Medium)
  .fontSize($r('app.float.font_size_medium'))
  .fontColor($r('app.color.base_blue'))
  .backgroundColor($r('app.color.item_button_background'))
}
