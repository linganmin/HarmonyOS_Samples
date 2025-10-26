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

export class SimpleCustomParams {
  constructor(text: string, content: string, onCancel: () => void,) {
    this.text = text;
    this.content = content;
    this.onCancel = onCancel;
  }

  text: string;
  content: string;
  onCancel: () => void;
}

@Builder
export function SimpleCustomBuilder(params: SimpleCustomParams) {
  Column() {
    Text(params.text).fontWeight(FontWeight.Bold)
      .fontSize($r('app.float.font_size_large'))
      .fontColor($r('app.color.item_text_color'))
    Text(params.content)
      .fontSize($r('app.float.font_size_medium'))
      .fontColor($r('app.color.item_text_color'))
      .margin({
        top: $r('app.float.simple_custom_content_top_margin'),
        bottom: $r('app.float.simple_custom_content_bottom_margin')
      })
    Button($r('app.string.Shut_down'), { type: ButtonType.Normal })
      .width(CommonConstant.FULL_LENGTH)
      .height($r('app.float.simple_custom_action_height'))
      .fontColor($r('app.color.base_blue'))
      .fontSize($r('app.float.font_size_medium'))
      .fontWeight(FontWeight.Medium)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        params.onCancel();
      })
  }
  .width($r('app.float.simple_custom_builder_width'))
  .backgroundColor(Color.White)
  .padding({
    top: $r('app.float.simple_custom_builder_vertical_padding'),
    bottom: $r('app.float.simple_custom_builder_vertical_padding'),
    left: $r('app.float.simple_custom_builder_horizon_padding'),
    right: $r('app.float.simple_custom_builder_horizon_padding')
  })
}