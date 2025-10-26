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

import { CommonConstants } from '../constants/CommonConstants';

@CustomDialog
export struct ShareDialog {
  private controller?: CustomDialogController;

  build() {
    // [Start dialog]
    Scroll() {
      Column() {
        // [StartExclude dialog]
        Image($r('app.media.background_image'))
          .objectFit(ImageFit.Cover)
          .aspectRatio(CommonConstants.IMAGE_ASPECT_RATIO)
          .height($r('app.float.share_image_height'))
          .margin({ bottom: $r('app.float.margin_xl') })
        Text(CommonConstants.SHARE_BUTTON)
          .fontColor($r('app.color.font_blue'))
          .fontWeight(CommonConstants.FONT_WEIGHTS[1])
          .fontSize($r('app.float.font_size_lg'))
        // [EndExclude dialog]
      }
    }
    .scrollBar(BarState.Off)
    .constraintSize({
      minHeight: 0,
      maxHeight: '90%'
    })
    // [End dialog]
    .padding($r('app.float.margin_xl'))
    .borderRadius($r('app.float.margin_xxl'))
    .backgroundColor(Color.White)
  }
}