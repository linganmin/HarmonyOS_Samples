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

export class SheetParams {
  constructor() {
  }

  type: 0 | 1 = 0;
}

@Builder
export function SheetBuilder(params: SheetParams) {
  Column() {
    if (params.type == 1) {
      Image($r('app.media.icon_user'))
        .width($r('app.float.sheet_builder_image_size'))
        .height($r('app.float.sheet_builder_image_size'))
      Text($r('app.string.Login_my_account'))
        .fontWeight(FontWeight.Bold)
        .fontSize($r('app.float.font_size_largest'))
        .fontColor($r('app.color.item_text_color'))
        .margin({
          top: $r('app.float.sheet_builder_text_top_margin'),
          bottom: $r('app.float.sheet_builder_text_bottom_margin')
        })
    }
    AccountBuilder()
    Button($r('app.string.Login'))
      .width(CommonConstant.FULL_LENGTH)
      .height($r('app.float.sheet_login_button_height'))
      .fontSize($r('app.float.font_size_medium'))
      .fontColor(Color.White)
      .fontWeight(FontWeight.Medium)
      .opacity($r('app.float.sheet_login_button_opacity'))
      .margin({ bottom: $r('app.float.sheet_login_button_margin') })
  }
  .width(CommonConstant.FULL_LENGTH)
  .height(CommonConstant.FULL_LENGTH)
  .padding({
    left: $r('app.float.sheet_builder_padding'),
    right: $r('app.float.sheet_builder_padding'),
    top: $r('app.float.sheet_builder_padding_top'),
    bottom: $r('app.float.sheet_builder_padding')
  })
}

@Builder
function AccountBuilder() {
  Column() {
    TextInput({ placeholder: $r('app.string.Sheet_builder_placeholder_phone') })
      .commonTextInput()
    Stack({ alignContent: Alignment.End }) {
      TextInput({ placeholder: $r('app.string.Sheet_builder_placeholder_password') })
        .commonTextInput()
        .padding({ right: $r('app.float.sheet_builder_account_input_padding') })
      Image($r('app.media.icon_eye'))
        .width($r('app.float.sheet_builder_account_eye_size'))
        .height($r('app.float.sheet_builder_account_eye_size'))
        .margin({ right: $r('app.float.sheet_builder_account_eye_margin') })
    }.margin({ top: $r('app.float.sheet_builder_account_input_margin') })
  }.layoutWeight(1)
}

@Extend(TextInput)
function commonTextInput() {
  .placeholderColor($r('app.color.snackbar_builder_input_placeholderColor'))
  .fontSize($r('app.float.font_size_medium'))
  .height($r('app.float.sheet_builder_account_input_height'))
}