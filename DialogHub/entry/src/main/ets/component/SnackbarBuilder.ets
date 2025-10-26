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

export class SnackbarParams {
  onCancel: () => void;
  pageInfos: NavPathStack;

  constructor(onCancel: () => void, pageInfos: NavPathStack) {
    this.onCancel = onCancel;
    this.pageInfos = pageInfos;
  }
}

@Builder
export function SnackbarBuilder(params: SnackbarParams) {

  Row() {
    Text($r('app.string.Snackbar_builder_title'))
      .fontColor($r('app.color.item_text_color'))
      .fontSize($r('app.float.font_size_regular'))
    Button($r('app.string.Click_to_move'))
      .onClick(() => {
        params.onCancel();
        params.pageInfos.pushPath({ name: CommonConstant.SKIP_ACTION_PATH, param: CommonConstant.SKIP_ACTION_PATH });
      })
      .width($r('app.float.snackbar_builder_action_width'))
      .height($r('app.float.snackbar_builder_action_height'))
      .backgroundColor($r('app.color.base_blue'))
      .fontWeight(FontWeight.Medium)
      .fontColor(Color.White)
      .fontSize($r('app.float.font_size_regular'))
      .margin({
        left: $r('app.float.snackbar_builder_action_margin'),
        right: $r('app.float.snackbar_builder_action_margin')
      })
      .padding({
        left: $r('app.float.snackbar_builder_action_padding'),
        right: $r('app.float.snackbar_builder_action_padding')
      })
    Image($r('app.media.icon_close_pure'))
      .width($r('app.float.snackbar_builder_close_size'))
      .height($r('app.float.snackbar_builder_close_size'))
      .onClick(() => {
        params.onCancel();
      })
  }
  .padding({
    left: $r('app.float.snackbar_builder_padding'),
    right: $r('app.float.snackbar_builder_padding'),
  })
  .height($r('app.float.snackbar_builder_height'))
  .backgroundColor($r('app.color.snackbar_builder_background'))
}