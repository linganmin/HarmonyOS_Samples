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

@Entry
@Component
struct Index {
  build() {
    Column() {
      Text($r('app.string.EntryAbility_label'))
        .width(CommonConstants.FULL_PERCENT)
        .font({
          size: $r('app.float.All_title_font_size'),
          weight: CommonConstants.FONT_WEIGHT_700
        })
        .margin({
          top: $r('app.float.title_margin_top'),
          left: $r('app.float.title_margin_left')
        })
      Column() {
        Button($r('app.string.encrypt_and_decrypt'))
          .width($r('app.float.button_width'))
          .height($r('app.float.button_height'))
          .margin({ bottom: $r('app.float.button_margin_bottom') })
          .onClick(() => {
            this.getUIContext().getRouter().pushUrl({ url: CommonConstants.ROUTER_PAGES[0] });
          })
        Button($r('app.string.SignatureVerification'))
          .width($r('app.float.button_width'))
          .height($r('app.float.button_height'))
          .margin({ bottom: $r('app.float.button_margin_bottom') })
          .onClick(() => {
            this.getUIContext().getRouter().pushUrl({ url: CommonConstants.ROUTER_PAGES[1] });
          })
        Button($r('app.string.KeyNegotiation'))
          .width($r('app.float.button_width'))
          .height($r('app.float.button_height'))
          .margin({ bottom: $r('app.float.last_button_margin_bottom') })
          .onClick(() => {
            this.getUIContext().getRouter().pushUrl({ url: CommonConstants.ROUTER_PAGES[2] });
          })
      }
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(HorizontalAlign.Center)
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }
}