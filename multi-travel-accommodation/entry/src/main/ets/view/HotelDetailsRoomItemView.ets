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
import { HotelRoomItem } from '../viewmodel/HotelRoomItem';

@Component
export struct HotelDetailsRoomItemView {
  @StorageLink('breakPoint') breakPoint: string = CommonConstants.BREAK_POINT_LG;

  build() {
    Column() {
      ForEach(CommonConstants.HOTEL_ROOMS_MESSAGES, (item: HotelRoomItem) => {
        Flex({ direction: FlexDirection.Row }) {
          if (item.getStandings() === CommonConstants.NUMBER_ONE) {
            Stack({ alignContent: Alignment.TopStart }) {
              Image($r('app.media.salesOne'))
                .width($r('app.float.room_picture_width'))
                .zIndex(CommonConstants.NUMBER_TWO)
              Image($r('app.media.roomOne'))
                .padding({ left: $r('app.float.room_grade_padding') })
                .borderRadius($r('app.float.room_picture_border'))
                .zIndex(CommonConstants.NUMBER_ONE)
                .width($r('app.float.room_true_picture_width'))
            }
            .width($r('app.float.room_all_picture_width'))
            .height(CommonConstants.FULL_WIDTH_PERCENT)
          } else if (item.getStandings() === CommonConstants.NUMBER_TWO) {
            Stack({ alignContent: Alignment.TopStart }) {
              Image($r('app.media.salesTwo'))
                .width($r('app.float.room_picture_width'))
                .zIndex(CommonConstants.NUMBER_TWO)
              Image($r('app.media.roomTwo'))
                .padding({ left: $r('app.float.room_grade_padding') })
                .borderRadius($r('app.float.room_picture_border'))
                .zIndex(CommonConstants.NUMBER_ONE)
                .width($r('app.float.room_true_picture_width'))
            }
            .width($r('app.float.room_all_picture_width'))
            .height(CommonConstants.FULL_WIDTH_PERCENT)
          } else if (item.getStandings() === CommonConstants.NUMBER_THREE) {
            Stack({ alignContent: Alignment.TopStart }) {
              Image($r('app.media.salesThree'))
                .width($r('app.float.room_picture_width'))
                .zIndex(CommonConstants.NUMBER_TWO)
              Image($r('app.media.roomThree'))
                .padding({ left: $r('app.float.room_grade_padding') })
                .borderRadius($r('app.float.room_picture_border'))
                .zIndex(CommonConstants.NUMBER_ONE)
                .width($r('app.float.room_true_picture_width'))
            }
            .width($r('app.float.room_all_picture_width'))
            .height(CommonConstants.FULL_WIDTH_PERCENT)
          } else {
            Stack({ alignContent: Alignment.TopStart }) {
              Image(item.getImage())
                .padding({ left: $r('app.float.room_grade_padding') })
                .borderRadius($r('app.float.room_picture_border'))
                .zIndex(CommonConstants.NUMBER_ONE)
                .width($r('app.float.room_true_picture_width'))
            }
            .width($r('app.float.room_all_picture_width'))
            .height(CommonConstants.FULL_WIDTH_PERCENT)
          }
          Column() {
            Row() {
              Column() {
                Text(CommonConstants.ROOM_MESSAGE_ONE)
                  .font({ size: $r('app.float.room_bundle_font_size'), weight: CommonConstants.FONT_WEIGHT_500 })
                  .fontColor($r('app.color.start_window_background'))
                  .lineHeight($r('app.float.hotel_grade_border'))
              }
              .margin({ right: $r('app.float.hotel_content_margin_top') })
              .height($r('app.float.start_width'))
              .backgroundColor($r('app.color.Calendar_selected_backgroundColor'))
              .borderRadius($r('app.float.calendar_date_border'))

              Text(item.getTitle())
                .width('150vp')
                .font({ size: $r('app.float.week_info_font_size'), weight: CommonConstants.FONT_WEIGHT_500 })
            }
            .width(CommonConstants.FULL_WIDTH_PERCENT)

            Row() {
              Text(item.getConfigureOne())
                .font({ size: $r('app.float.room_config_one_font_size'), weight: CommonConstants.FONT_WEIGHT_400 })
            }
            .margin({ top: $r('app.float.hotel_content_margin_top') })
            .width(CommonConstants.FULL_WIDTH_PERCENT)

            Row() {
              Text(CommonConstants.BREAKFAST_NUMBER + item.getBreakfastNumber())
                .margin({ right: $r('app.float.calendar_column_margin') })
                .fontColor($r('app.color.Calendar_selected_backgroundColor'))
                .font({ size: $r('app.float.room_config_one_font_size'), weight: CommonConstants.FONT_WEIGHT_400 })
              Text($r('app.string.Not_Cancelable'))
                .font({ size: $r('app.float.room_config_one_font_size'), weight: CommonConstants.FONT_WEIGHT_400 })
                .opacity(CommonConstants.OPACITY_FIFTY_PERCENT)
            }
            .margin({ top: $r('app.float.hotel_content_margin_top') })
            .width(CommonConstants.FULL_WIDTH_PERCENT)

            Row() {
              Column() {
                Text(CommonConstants.ROOM_MESSAGE_TWO)
                  .font({ size: $r('app.float.room_bundle_font_size'), weight: CommonConstants.FONT_WEIGHT_500 })
                  .fontColor($r('app.color.start_window_background'))
                  .lineHeight($r('app.float.hotel_grade_border'))
              }
              .margin({ right: $r('app.float.hotel_content_margin_top') })
              .height($r('app.float.room_message_weo_width'))
              .backgroundColor($r('app.color.Calendar_selected_backgroundColor'))
              .borderRadius($r('app.float.room_message_weo_width'))

              Text(item.getConfigureTwo())
                .width('200vp')
                .font({ size: $r('app.float.room_config_one_font_size'), weight: CommonConstants.FONT_WEIGHT_400 })
            }
            .margin({ top: $r('app.float.hotel_content_margin_top') })
            .width(CommonConstants.FULL_WIDTH_PERCENT)

            Row() {
              Text(item.getOriginalPrice())
                .opacity(CommonConstants.OPACITY_FIFTY_PERCENT)
                .font({ size: $r('app.float.calendar_money_font_size'), weight: CommonConstants.FONT_WEIGHT_400 })
                .decoration({ type: TextDecorationType.LineThrough })
              Text(item.getDiscountedPrice())
                .fontColor($r('app.color.Calendar_selected_backgroundColor'))
                .fontSize($r('app.float.room_price_font_size'))
                .fontWeight(CommonConstants.FONT_WEIGHT_500)
                .margin({
                  left: new BreakpointType($r('app.float.calendar_date_border'), $r('app.float.calendar_date_border'),
                    $r('app.float.calendar_date_border')).getValue(this.breakPoint)
                })
              if (item.getRemain()) {
                Stack({ alignContent: Alignment.TopStart }) {
                  Image($r('app.media.remain'))
                    .zIndex(CommonConstants.NUMBER_TWO)
                    .width($r('app.float.low_price_all_height'))
                  Button(CommonConstants.ROOM_MESSAGE_THREE)
                    .margin({
                      top: $r('app.float.hotel_content_margin_top'),
                      left: new BreakpointType($r('app.float.calendar_date_border'),
                        $r('app.float.calendar_date_border'),
                        $r('app.float.calendar_date_border')).getValue(this.breakPoint)
                    })
                    .width($r('app.float.buy_button_width'))
                    .height($r('app.float.receive_height'))
                }
              } else {
                Stack({ alignContent: Alignment.TopStart }) {
                  Button(CommonConstants.ROOM_MESSAGE_THREE)
                    .margin({ top: $r('app.float.hotel_content_margin_top') })
                    .width($r('app.float.buy_button_width'))
                    .height($r('app.float.receive_height'))
                }
              }
            }
            .margin({ top: 10 })
            .width(CommonConstants.FULL_WIDTH_PERCENT)
            .justifyContent(FlexAlign.End)
            .alignItems(VerticalAlign.Bottom)
          }
          .margin({ left: $r('app.float.index_page_button_margin') })
          .height(CommonConstants.FULL_WIDTH_PERCENT)
        }
        .margin({ bottom: $r('app.float.calendar_date_border') })
        .width(CommonConstants.FULL_WIDTH_PERCENT)
        .height(160)

      }, (item: HotelRoomItem) => JSON.stringify(item))
    }
    .width(CommonConstants.FULL_WIDTH_PERCENT)
  }
}
