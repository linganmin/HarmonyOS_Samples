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

import Constants from '../common/Constants';

@Entry
@Component
struct BottomWithBar {
  private maxLength: number = 6;
  private strokeWidth: number = 1;

  build() {
    Column() {
      Row() {
        Text($r('app.string.enter_the_verification_code'))
          .fontSize($r('app.float.font_size_l'))
          .fontWeight(FontWeight.Medium)
      }
      .height($r('app.float.list_padding_top'))

      Row() {
        Text($r('app.string.Verification_code_sent_to'))
          .fontSize($r('app.float.font_size_m'))
          .fontColor($r('app.color.phone_color'))
          .fontWeight(FontWeight.Regular)
        Text($r('app.string.phone_number1'))
          .fontSize($r('app.float.font_size_m'))
          .fontColor($r('app.color.theme_color'))
          .fontWeight(FontWeight.Regular)
      }
      .margin({
        top: $r('app.float.row_width'),
        bottom: $r('app.float.margin_bottom_one')
      })

      Row() {
        TextInput()
          .backgroundColor(Color.Transparent)
          .width(Constants.EIGHTY_PERCENT)
          .maxLength(this.maxLength)
          .type(InputType.Number)
          .translate({ x: Constants.NEGATIVE_TWELVE })
        Text($r('app.string.reacquire'))
          .fontSize($r('app.float.font_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.theme_color'))
      }
      .width(Constants.EIGHTY_FIVE_PERCENT)

      Divider()
        .strokeWidth(this.strokeWidth)
        .width(Constants.EIGHTY_FIVE_PERCENT)
        .color($r('app.color.line_divider'))
        .margin({
          top: $r('app.float.text_margin'),
          bottom: $r('app.float.divider_bottom')
        })

      Button($r('app.string.login'))
        .backgroundColor($r('app.color.theme_color'))
        .fontColor(Color.White)
        .width(Constants.EIGHTY_FIVE_PERCENT)
        .height($r('app.float.bottom_height'))

    }
    .padding({ top: Constants.LINE_WIDTH })
    .height(Constants.ONE_HUNDRED_PERCENT)
    .width(Constants.ONE_HUNDRED_PERCENT)
  }
}

@Builder
export function getBottomWithBar(name: string): void {
  if (name === 'BottomWithBar') {
    NavDestination() {
      BottomWithBar()
    }
  }
}

export const wrappedBuilderBottomWithBar: WrappedBuilder<[string, number]> = wrapBuilder(getBottomWithBar);