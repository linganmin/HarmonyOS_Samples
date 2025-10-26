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

export class InputParams {
  onCancel: (input: string) => void;
  inputValue: string = '';

  constructor(onCancel: (input: string) => void, inputValue?: string) {
    this.onCancel = onCancel;
    if (inputValue) {
      this.inputValue = inputValue;
    }
  }
}

@Builder
export function InputBuilder(params: InputParams) {
  Row() {
    TextInput({ placeholder: $r('app.string.Input_builder_placeholder') })
      .onChange((value: string) => {
        params.inputValue = value;
      })
      .layoutWeight(1)
      .height($r('app.float.input_builder_input_height'))
      .borderRadius($r('app.float.input_builder_input_borderRadius'))
    Image($r('app.media.icon_send'))
      .width($r('app.float.input_builder_send_width'))
      .height($r('app.float.input_builder_send_height'))
      .margin({ left: $r('app.float.input_builder_send_margin') })
      .onClick(() => {
        params.onCancel(params.inputValue);
      })
  }
  .padding({
    left: $r('app.float.input_builder_left_padding'),
    right: $r('app.float.input_builder_right_padding'),
  })
  .height($r('app.float.input_builder_height'))
  .width(CommonConstant.FULL_LENGTH)
  .backgroundColor(Color.White)
}