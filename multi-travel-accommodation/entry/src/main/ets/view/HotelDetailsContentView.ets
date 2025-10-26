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
import { BreakpointType } from '../commons/utils/BreakpointType';

@Component
export struct HotelDetailsContentView {
  @StorageLink('breakPoint') breakPoint: string = CommonConstants.BREAK_POINT_LG;

  build() {
    Column() {
      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center }) {
        Flex({
          direction: this.breakPoint === CommonConstants.BREAK_POINT_LG ? FlexDirection.Row : FlexDirection.Column
        , alignItems: this.breakPoint === CommonConstants.BREAK_POINT_LG ? ItemAlign.Center : ItemAlign.Start
        }) {
          Row() {
            Text(CommonConstants.HOTEL_NAME)
              .font({
                size: this.breakPoint === CommonConstants.BREAK_POINT_LG ? $r('app.float.week_info_lg_font_size') :
                $r('app.float.week_info_font_size'),
                weight: CommonConstants.FONT_WEIGHT_500
              })
            Image($r('app.media.star_filled'))
              .width(this.breakPoint === CommonConstants.BREAK_POINT_LG ? $r('app.float.start_width') :
              CommonConstants.STAR_WIDTH)
              .margin({ left: $r('app.float.calendar_column_margin') })
            Image($r('app.media.star_filled'))
              .width(this.breakPoint === CommonConstants.BREAK_POINT_LG ? $r('app.float.start_width') :
              CommonConstants.STAR_WIDTH)
            Image($r('app.media.star_filled'))
              .width(this.breakPoint === CommonConstants.BREAK_POINT_LG ? $r('app.float.start_width') :
              CommonConstants.STAR_WIDTH)
            Image($r('app.media.star_filled'))
              .width(this.breakPoint === CommonConstants.BREAK_POINT_LG ? $r('app.float.start_width') :
              CommonConstants.STAR_WIDTH)
            Image($r('app.media.star_filled'))
              .width(this.breakPoint === CommonConstants.BREAK_POINT_LG ? $r('app.float.start_width') :
              CommonConstants.STAR_WIDTH)
          }

          Column() {
            Text(CommonConstants.HOTEL_MESSAGE_ONE)
              .padding({
                left: $r('app.float.hotel_picture_padding'),
                right: $r('app.float.hotel_picture_padding'),
                top: $r('app.float.hotel_picture_padding'),
                bottom: $r('app.float.hotel_picture_padding')
              })
              .fontColor($r('app.color.Hotel_top_fontColor'))
              .fontSize($r('app.float.hotel_message_font_size'))
          }
          .height($r('app.float.hotel_first_width'))
          .backgroundColor($r('app.color.Hotel_top_backgroundColor'))
          .borderRadius($r('app.float.calendar_date_border'))
          .margin({
            left: this.breakPoint === CommonConstants.BREAK_POINT_LG ? $r('app.float.calendar_column_margin') :
            $r('app.float.no_border')
          })
        }
        .margin({ top: $r('app.float.hotel_message_margin_top') })
        .width(CommonConstants.NINETY_FIVE_PERCENT)
        .height($r('app.float.low_price_all_height'))

        Column() {
          Text(CommonConstants.HOTEL_MESSAGE_TWO)
            .width(CommonConstants.FULL_WIDTH_PERCENT)
            .opacity(CommonConstants.OPACITY_FIFTY_PERCENT)
            .fontSize($r('app.float.hotel_message_font_size'))
            .textAlign(TextAlign.Start)
            .fontWeight(CommonConstants.FONT_WEIGHT_400)
        }
        .width(CommonConstants.NINETY_FIVE_PERCENT)
        .margin({ top: $r('app.float.hotel_content_margin_top') })

        Row() {
          Column() {
            Row() {
              Row() {
                Text(CommonConstants.HOTEL_MESSAGE_SIX)
                  .fontSize($r('app.float.week_info_font_size'))
                  .fontColor($r('app.color.Calendar_selected_backgroundColor'))
                Text(CommonConstants.HOTEL_MESSAGE_SEVEN)
                  .fontSize($r('app.float.hotel_message_font_size'))
                  .fontColor($r('app.color.Calendar_selected_backgroundColor'))
              }

              Text(CommonConstants.HOTEL_MESSAGE_EIGHT)
                .fontSize($r('app.float.hotel_message_font_size'))
                .opacity(CommonConstants.OPACITY_FIFTY_PERCENT)
            }
            .margin({ top: $r('app.float.calendar_column_margin') })
            .width(CommonConstants.NINETY_PERCENT)
            .justifyContent(FlexAlign.SpaceBetween)

            Column() {
              Text(CommonConstants.HOTEL_MESSAGE_THREE)
                .fontSize($r('app.float.calendar_money_font_size'))
                .fontWeight(CommonConstants.FONT_WEIGHT_500)
                .textAlign(TextAlign.Start)
                .width(CommonConstants.FULL_WIDTH_PERCENT)
            }
            .width(CommonConstants.NINETY_PERCENT)
            .margin({ top: $r('app.float.calendar_column_margin') })
          }
          .borderRadius($r('app.float.hotel_grade_border'))
          .backgroundColor($r('app.color.card_background'))
          .width(CommonConstants.CARD_ONE_WIDTH)
          .height(CommonConstants.FULL_WIDTH_PERCENT)
          .justifyContent(FlexAlign.Start)

          Column() {
            Row() {
              Column() {
                Column() {
                  Text(CommonConstants.HOTEL_MESSAGE_FOUR)
                    .font({ size: $r('app.float.hotel_message_font_size'), weight: CommonConstants.FONT_WEIGHT_500 })
                    .width(CommonConstants.FULL_WIDTH_PERCENT)
                }
                .width(CommonConstants.SEVENTY_PERCENT)
                .height(CommonConstants.FORTY_PERCENT)

                Column() {
                  Text(CommonConstants.HOTEL_MESSAGE_FIVE)
                    .fontSize($r('app.float.calendar_money_font_size'))
                    .width(CommonConstants.FULL_WIDTH_PERCENT)
                }
                .width(CommonConstants.SEVENTY_PERCENT)
                .height(CommonConstants.TWENTY_PERCENT)
              }

              Column() {
                Image($r('app.media.map'))
                  .height(CommonConstants.SIXTY_PERCENT)
                Text(CommonConstants.HOTEL_MESSAGE_NINE)
                  .opacity(CommonConstants.OPACITY_SIXTY_PERCENT)
                  .font({ size: $r('app.float.calendar_money_font_size'), weight: CommonConstants.FONT_WEIGHT_500 })
              }
              .width(CommonConstants.TWENTY_FIVE_PERCENT)
              .height(CommonConstants.SIXTY_PERCENT)
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width(CommonConstants.NINETY_PERCENT)
          }
          .borderRadius($r('app.float.hotel_grade_border'))
          .justifyContent(FlexAlign.Center)
          .backgroundColor($r('app.color.card_background'))
          .width(CommonConstants.CARD_TWO_WIDTH)
          .height(CommonConstants.FULL_WIDTH_PERCENT)
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width(CommonConstants.NINETY_FIVE_PERCENT)
        .height(CommonConstants.FORTY_PERCENT)
        .margin({ top: $r('app.float.hotel_all_grade_margin_top') })
      }
      .width(CommonConstants.FULL_WIDTH_PERCENT)
    }
    .width(CommonConstants.FULL_WIDTH_PERCENT)
    .height(CommonConstants.FULL_WIDTH_PERCENT)
    .borderRadius(
      {
        bottomLeft: $r('app.float.calendar_card_border'),
        bottomRight: $r('app.float.calendar_card_border'),
        topLeft: new BreakpointType($r('app.float.calendar_card_border'), $r('app.float.no_border'),
          $r('app.float.no_border')).getValue(this.breakPoint),
        topRight: new BreakpointType($r('app.float.calendar_card_border'), $r('app.float.no_border'),
          $r('app.float.no_border')).getValue(this.breakPoint)
      })
    .backgroundColor($r('app.color.start_window_background'))
  }
}
