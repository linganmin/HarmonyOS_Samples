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

import { CommonConstants } from '../common/constants/CommonConstants';
import { RouterParam } from '../viewmodel/RouterParam';

@Entry
@Component
struct SignatureVerificationPage {
  build() {
    Column() {
      Row() {
        Button() {
          Image($r('app.media.back'))
            .width($r('app.float.back_height'))
            .height($r('app.float.back_height'))
        }
        .width($r('app.float.back_height'))
        .height($r('app.float.back_height'))
        .type(ButtonType.Circle)
        .backgroundColor($r('app.color.back_button_backgroundColor'))
        .margin({
          left: $r('app.float.title_margin_left'),
          right: $r('app.float.title_margin_right')
        })
        .onClick(() => {
          this.getUIContext().getRouter().back();
        })

        Text($r('app.string.SignatureVerificationSet'))
          .font({
            size: $r('app.float.title_font_size'),
            weight: CommonConstants.FONT_WEIGHT_700
          })
      }
      .alignItems(VerticalAlign.Center)
      .width(CommonConstants.FULL_PERCENT)

      Column() {
        Button(CommonConstants.SIGNATURE_VERIFICATION_MODE[0])
          .width($r('app.float.button_width'))
          .height($r('app.float.button_height'))
          .margin({ bottom: $r('app.float.button_margin_bottom') })
          .onClick(() => {
            this.getUIContext().getRouter().pushUrl({
              url: CommonConstants.SIGNATURE_VERIFICATION_PAGE,
              params: new RouterParam(0)
            });
          })
        Button(CommonConstants.SIGNATURE_VERIFICATION_MODE[1])
          .width($r('app.float.button_width'))
          .height($r('app.float.button_height'))
          .margin({ bottom: $r('app.float.last_button_margin_bottom') })
          .onClick(() => {
            this.getUIContext().getRouter().pushUrl({
              url: CommonConstants.SIGNATURE_VERIFICATION_PAGE,
              params: new RouterParam(1)
            });
          })
      }
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(HorizontalAlign.Center)
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }
}