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
import { CalendarItem } from '../viewmodel/CalendarItem';

@CustomDialog
export struct CalendarDialogView {
  controller: CustomDialogController;
  @StorageLink('breakPoint') breakPoint: string = CommonConstants.BREAK_POINT_LG;
  @State startTime: number = CommonConstants.START_TIME;
  @State stopTime: number = CommonConstants.START_TIME;
  @StorageLink('isShowingCalendar') isShowingCalendar: boolean = false;

  getDate(item: CalendarItem) {
    return Number.parseInt(item.date);
  }

  getIndex(index: number, item: CalendarItem) {
    if (item.date === CommonConstants.EMPTY_STRING || item.isLast) {
      return CommonConstants.mAX_TIME;
    }
    return index;
  }

  build() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
      Row() {
        Text($r('app.string.LowPriceCalendar'))
          .font({ size: $r('app.float.low_price_font_size'), weight: CommonConstants.FONT_WEIGHT_500 })
          .height($r('app.float.low_price_height'))
        Image($r('app.media.close'))
          .width($r('app.float.low_price_height'))
          .height($r('app.float.low_price_height'))
          .onClick(() => {
            this.isShowingCalendar = false;
          })
      }
      .margin({ top: $r('app.float.low_price_margin_top') })
      .width(CommonConstants.NINETY_PERCENT)
      .height($r('app.float.low_price_all_height'))
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Image($r('app.media.Calendar_last'))
          .width($r('app.float.low_price_height'))
        Text($r('app.string.January_2024'))
          .font({ size: $r('app.float.January_2024_font_size'), weight: CommonConstants.FONT_WEIGHT_500 })
          .opacity(CommonConstants.OPACITY_NINETY_PERCENT)
        Image($r('app.media.Calendar_next'))
          .width($r('app.float.low_price_height'))
      }
      .width(CommonConstants.NINETY_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: $r('app.float.January_2024_margin_top') })

      Row() {
        ForEach(CommonConstants.WEEK_MESSAGE, (weekInfo: string) => {
          Column() {
            Text(weekInfo)
              .font({ size: 10, weight: CommonConstants.FONT_WEIGHT_500 })
              .opacity(CommonConstants.OPACITY_NINETY_PERCENT)
              .textAlign(TextAlign.Center)
              .width(CommonConstants.FULL_WIDTH_PERCENT)
          }
          .justifyContent(FlexAlign.Center)
          .width($r('app.float.low_price_all_height'))
          .height($r('app.float.low_price_height'))
        }, (weekInfo: string) => JSON.stringify(weekInfo))
      }
      .width(CommonConstants.NINETY_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: $r('app.float.index_page_button_margin') })

      Column() {
        Grid() {
          ForEach(CommonConstants.CALENDAR_TIME_MESSAGE[0], (item: CalendarItem, index) => {
            GridItem() {
              Column() {
                Text(item.isToday ? $r('app.string.Today') : CommonConstants.EMPTY_STRING)
                  .font({ size: $r('app.float.calendar_money_font_size'), weight: CommonConstants.FONT_WEIGHT_200 })
                  .fontColor((this.startTime === this.getIndex(index, item)) ||
                    (this.stopTime === this.getIndex(index, item)) ? $r('app.color.start_window_background') :
                  $r('app.color.font_color_black'))
                Text(item.date)
                  .font({ size: $r('app.float.week_info_font_size'), weight: CommonConstants.FONT_WEIGHT_500 })
                  .opacity(item.isLast ? CommonConstants.OPACITY_FORTY_PERCENT : CommonConstants.OPACITY_FULL_PERCENT)
                  .fontColor((this.startTime === this.getIndex(index, item)) ||
                    (this.stopTime === this.getIndex(index, item)) ? $r('app.color.start_window_background') :
                  $r('app.color.font_color_black'))
                Text(item.money)
                  .font({ size: $r('app.float.calendar_money_font_size'), weight: CommonConstants.FONT_WEIGHT_400 })
                  .fontColor((this.startTime === this.getIndex(index, item)) ||
                    (this.stopTime === this.getIndex(index, item)) ? $r('app.color.start_window_background') :
                    item.isLowPrice ?
                    $r('app.color.font_color_red') : $r('app.color.font_color_black'))
                if (item.isLowPrice) {
                  Text($r('app.string.LowPrice'))
                    .font({ size: $r('app.float.calendar_money_font_size'), weight: CommonConstants.FONT_WEIGHT_400 })
                    .fontColor((this.startTime === this.getIndex(index, item)) ||
                      (this.stopTime === this.getIndex(index, item)) ? $r('app.color.start_window_background') :
                      item.isLowPrice ?
                      $r('app.color.font_color_red') : $r('app.color.font_color_black'))
                }
                if (this.startTime === this.getIndex(index, item)) {
                  Text($r('app.string.MoveInto'))
                    .font({ size: $r('app.float.calendar_money_font_size'), weight: CommonConstants.FONT_WEIGHT_400 })
                    .fontColor($r('app.color.start_window_background'))
                }
                if (this.stopTime === this.getIndex(index, item)) {
                  Text($r('app.string.leave'))
                    .font({ size: $r('app.float.calendar_money_font_size'), weight: CommonConstants.FONT_WEIGHT_400 })
                    .fontColor($r('app.color.start_window_background'))
                }

              }
              .backgroundColor((this.startTime === this.getIndex(index, item)) ||
                (this.stopTime === this.getIndex(index, item)) ? $r('app.color.Calendar_selected_backgroundColor') :
              $r('app.color.start_window_background'))
              .borderRadius($r('app.float.calendar_date_border'))
              .onClick(() => {
                if (this.startTime === CommonConstants.START_TIME) {
                  this.startTime = this.getDate(item);
                } else if (this.stopTime === CommonConstants.START_TIME) {
                  this.stopTime = Math.max(this.startTime, this.getDate(item));
                  this.startTime = Math.min(this.startTime, this.getDate(item));
                } else {
                  this.stopTime = Math.max(this.startTime, this.getDate(item));
                  this.startTime = Math.min(this.startTime, this.getDate(item));
                }
              })
              .justifyContent(FlexAlign.Center)
              .width($r('app.float.low_price_all_height'))
              .height($r('app.float.calendar_date_height'))
            }
          }, (item: CalendarItem) => JSON.stringify(item))

        }
        .width(CommonConstants.FULL_WIDTH_PERCENT)
        .columnsGap($r('app.float.calendar_column_margin'))
        .rowsGap($r('app.float.calendar_column_margin'))
        .height(CommonConstants.FULL_WIDTH_PERCENT)
        .columnsTemplate(CommonConstants.GRID_COLUMN_TEMPLATE)

      }
      .width(CommonConstants.NINETY_PERCENT)
      .height(CommonConstants.AUTO_HEIGHT)
    }
    .borderRadius($r('app.float.calendar_card_border'))
    .width($r('app.float.calendar_card_width'))
    .height($r('app.float.calendar_card_height'))
    .backgroundColor($r('app.color.start_window_background'))
  }
}
