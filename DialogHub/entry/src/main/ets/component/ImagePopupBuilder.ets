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
export class ImagePopupParams {
  onCancel: () => void;

  constructor(onCancel: () => void) {
    this.onCancel = onCancel;
  }
}

@Builder
export function ImagePopupBuilder(param: ImagePopupParams) {
  Row() {
    Text($r('app.string.Image_popup_builder_title'))
      .fontColor($r('app.color.item_text_color'))
      .fontSize($r('app.float.font_size_regular'))
    Image($r('app.media.icon_close_pure'))
      .width($r('app.float.image_popup_close_size'))
      .height($r('app.float.image_popup_close_size'))
      .margin({ left: $r('app.float.image_popup_close_margin') })
      .onClick(() => {
        param.onCancel();
      })
  }
  .padding($r('app.float.image_popup_builder_padding'))
  .height($r('app.float.image_popup_builder_height'))
}