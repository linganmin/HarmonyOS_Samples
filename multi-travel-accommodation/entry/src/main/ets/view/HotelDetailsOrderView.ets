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

import { CommonConstants } from '../commons/constants/CommonConstants';

@Component
export struct HotelDetailsOrderView {
  @StorageLink('breakPoint') breakPoint: string = CommonConstants.BREAK_POINT_LG;

  build() {
    Column() {
      Row() {
        Row() {
          Text($r('app.string.BookingOffers'))
            .font({ size: $r('app.float.week_info_font_size'), weight: CommonConstants.FONT_WEIGHT_500 })
          Column() {
            Text($r('app.string.Reduced30'))
              .fontColor($r('app.color.Hotel_top_fontColor'))
              .fontSize($r('app.float.calendar_money_font_size'))
              .padding({
                top: $r('app.float.hotel_picture_padding'),
                bottom: $r('app.float.hotel_picture_padding'),
                left: $r('app.float.hotel_padding_picture_left'),
                right: $r('app.float.hotel_padding_picture_left')
              })
          }
          .borderRadius($r('app.float.calendar_date_border'))
          .margin({ left: $r('app.float.hotel_all_grade_margin_top') })
          .backgroundColor($r('app.color.down30_background'))
        }
        .width(CommonConstants.THIRTY_PERCENT)

        Blank()
        Button($r('app.string.receive'))
          .fontSize($r('app.float.hotel_message_font_size'))
          .width($r('app.float.receive_width'))
          .height($r('app.float.receive_height'))
          .backgroundColor($r('app.color.Hotel_top_fontColor'))
      }

      .justifyContent(FlexAlign.SpaceBetween)
      .width(CommonConstants.NINETY_FIVE_PERCENT)
      .height(CommonConstants.FULL_WIDTH_PERCENT)
    }
    .backgroundColor($r('app.color.start_window_background'))
    .borderRadius($r('app.float.calendar_card_border'))
    .width(CommonConstants.FULL_WIDTH_PERCENT)
    .height(CommonConstants.FULL_WIDTH_PERCENT)
  }
}
