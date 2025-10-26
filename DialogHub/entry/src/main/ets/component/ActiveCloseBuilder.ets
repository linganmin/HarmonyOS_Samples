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
import CommonConstant from "../utils/CommonConstant";

export class ActiveCloseParams {
  title: string;
  content: string;
  leftButton: string;
  rightButton: string;
  onCancel: () => void
  action?: () => void;
  actionColor?: ResourceColor;

  constructor(title: string, content: string, leftButton: string, rightButton: string, onCancel: () => void,
    action?: () => void, actionColor?: ResourceColor) {
    this.title = title;
    this.content = content;
    this.leftButton = leftButton;
    this.rightButton = rightButton;
    this.actionColor = actionColor;
    this.onCancel = onCancel;
    this.action = action;
  }
}

@Builder
export function ActiveCloseBuilder(params: ActiveCloseParams) {

  Column() {
    Text(params.title)
      .height($r('app.float.active_close_title_height'))
      .fontWeight(FontWeight.Bold)
      .fontSize($r('app.float.font_size_large'))
      .fontColor($r('app.color.item_text_color'))

    Text(params.content)
      .fontSize($r('app.float.font_size_regular'))
      .fontColor($r('app.color.active_close_content_color'))
      .margin({ bottom: $r('app.float.active_close_content_margin') })

    Row() {
      Button(params.leftButton, { type: ButtonType.Normal })
        .commonButton($r('app.color.base_blue'))
        .onClick(() => {
          params.onCancel();
        })
      Button(params.rightButton, { type: ButtonType.Normal })
        .commonButton(params.actionColor ?? $r('app.color.base_red'))
        .onClick(() => {
          params.action?.();
        })
    }.width(CommonConstant.FULL_LENGTH).justifyContent(FlexAlign.SpaceBetween)
  }
  .width($r('app.float.active_close_builder_width'))
  .height($r('app.float.active_close_builder_height'))
  .padding({ left: $r('app.float.active_close_builder_padding'), right: $r('app.float.active_close_builder_padding') })
}

@Extend(Button)
function commonButton(fontColor: ResourceColor) {
  .width($r('app.float.active_close_action_width'))
  .height($r('app.float.active_close_action_height'))
  .fontSize($r('app.float.font_size_medium'))
  .fontWeight(FontWeight.Medium)
  .fontColor(fontColor)
  .backgroundColor(Color.Transparent)
}