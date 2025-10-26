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

@Component
export struct LowPriceView {
  @StorageLink('breakPoint') breakPoint: string = CommonConstants.BREAK_POINT_LG;
  @Consume('pageInfos') pageInfos: NavPathStack;
  @State startTime: number = CommonConstants.START_TIME;
  @State stopTime: number = CommonConstants.START_TIME;

  getDate(index: number, item: CalendarItem) {
    if (index === CommonConstants.NUMBER_ZERO) {
      return Number.parseInt(item.date);
    } else {
      return CommonConstants.NUMBER_THIRTY_ONE + Number.parseInt(item.date);
    }
  }

  getIndex(index: number, temp: number, item: CalendarItem) {
    if (item.date === CommonConstants.EMPTY_STRING || item.isLast) {
      return CommonConstants.mAX_TIME;
    }
    if (index === CommonConstants.NUMBER_ZERO) {
      return temp;
    } else {
      return CommonConstants.NUMBER_TWENTY_EIGHT + temp;
    }
  }

  build() {
   NavDestination(){
     Column() {
       Stack({ alignContent: Alignment.Top }) {
         Stack({ alignContent: Alignment.Bottom }) {
           Column() {
             Row() {
               Image($r('app.media.ic_public_back'))
                 .width($r('app.float.index_page_button_margin'))
                 .onClick(() => {
                   this.pageInfos.pop();
                 })
               Text($r('app.string.LowPriceCalendar'))
                 .margin({ left: $r('app.float.one_night_height') })
                 .font({ size: $r('app.float.low_price_font_size'), weight: CommonConstants.FONT_WEIGHT_500 })
                 .fontColor($r('app.color.start_window_background'))
             }
             .width(CommonConstants.NINETY_PERCENT)
             .margin({ top: $r('app.float.index_page_button_margin') })

           }
           .width(CommonConstants.FULL_WIDTH_PERCENT)
           .height($r('app.float.calendar_height'))
           .backgroundColor($r('app.color.Calendar_selected_backgroundColor'))

           Row()
             .width(CommonConstants.FULL_WIDTH_PERCENT)
             .height($r('app.float.week_info_lg_font_size'))
             .blendMode(BlendMode.SRC_IN)
             .linearGradient({
               direction: GradientDirection.Top,
               repeating: false,
               colors: [
                 [Color.White, CommonConstants.NUMBER_ZERO],
                 [$r('app.color.search_blue_background'), CommonConstants.NUMBER_ONE]
               ]
             })
             .zIndex(CommonConstants.NUMBER_THREE)
         }

         Scroll() {
           Column() {
             ForEach(CommonConstants.CALENDAR_TIME_MESSAGE, (item: Array<CalendarItem>, index) => {
               Column() {
                 if (index === CommonConstants.NUMBER_ZERO) {
                   Text($r('app.string.January_2024'))
                     .font({ size: $r('app.float.January_2024_font_size'), weight: CommonConstants.FONT_WEIGHT_500 })
                     .opacity(CommonConstants.OPACITY_NINETY_PERCENT)
                     .margin({ top: $r('app.float.week_info_font_size') })
                 } else {
                   Text($r('app.string.February_2024'))
                     .font({ size: $r('app.float.January_2024_font_size'), weight: CommonConstants.FONT_WEIGHT_500 })
                     .opacity(CommonConstants.OPACITY_NINETY_PERCENT)
                     .margin({ top: $r('app.float.week_info_font_size') })
                 }
                 Row() {
                   ForEach(CommonConstants.WEEK_MESSAGE, (weekInfo: string) => {
                     Column() {
                       Text(weekInfo)
                         .font({ size: 12, weight: CommonConstants.FONT_WEIGHT_500 })
                         .opacity(CommonConstants.OPACITY_NINETY_PERCENT)
                         .textAlign(TextAlign.Center)
                     }
                     .justifyContent(FlexAlign.Center)
                     .width($r('app.float.low_price_height'))
                     .height($r('app.float.low_price_height'))
                   }, (weekInfo: string) => JSON.stringify(weekInfo))
                 }
                 .width(CommonConstants.NINETY_FIVE_PERCENT)
                 .justifyContent(FlexAlign.SpaceBetween)
                 .margin({ top: $r('app.float.January_2024_margin_top') })

                 Grid() {
                   ForEach(item, (dateItem: CalendarItem, temp: number) => {
                     GridItem() {
                       Column() {
                         Text(dateItem.isToday ? $r('app.string.Today') : CommonConstants.EMPTY_STRING)
                           .font({
                             size: $r('app.float.calendar_money_font_size'),
                             weight: CommonConstants.FONT_WEIGHT_200
                           })
                           .fontColor((this.startTime === this.getIndex(index, temp, dateItem)) ||
                             (this.stopTime === this.getIndex(index, temp, dateItem)) ?
                           $r('app.color.start_window_background') : $r('app.color.font_color_black'))
                         Text(dateItem.date)
                           .font({ size: $r('app.float.week_info_font_size'), weight: CommonConstants.FONT_WEIGHT_500 })
                           .opacity(dateItem.isLast ? CommonConstants.OPACITY_FORTY_PERCENT :
                           CommonConstants.OPACITY_FULL_PERCENT)
                           .fontColor((this.startTime === this.getIndex(index, temp, dateItem)) ||
                             (this.stopTime === this.getIndex(index, temp, dateItem)) ?
                           $r('app.color.start_window_background') : $r('app.color.font_color_black'))
                         Text(dateItem.money)
                           .font({
                             size: $r('app.float.calendar_money_font_size'),
                             weight: CommonConstants.FONT_WEIGHT_400
                           })
                           .fontColor((this.startTime === this.getIndex(index, temp, dateItem)) ||
                             (this.stopTime === this.getIndex(index, temp, dateItem)) ?
                           $r('app.color.start_window_background') :
                             dateItem.isLowPrice ? $r('app.color.font_color_red') : $r('app.color.font_color_black'))
                         if (dateItem.isLowPrice) {
                           Text($r('app.string.LowPrice'))
                             .font({
                               size: $r('app.float.calendar_money_font_size'),
                               weight: CommonConstants.FONT_WEIGHT_400
                             })
                             .fontColor((this.startTime === this.getIndex(index, temp, dateItem)) ||
                               (this.stopTime === this.getIndex(index, temp, dateItem)) ?
                             $r('app.color.start_window_background') :
                               dateItem.isLowPrice ? $r('app.color.font_color_red') : $r('app.color.font_color_black'))
                         }
                         if (this.startTime === this.getIndex(index, temp, dateItem)) {
                           Text($r('app.string.MoveInto'))
                             .font({
                               size: $r('app.float.calendar_money_font_size'),
                               weight: CommonConstants.FONT_WEIGHT_400
                             })
                             .fontColor($r('app.color.start_window_background'))
                         }
                         if (this.stopTime === this.getIndex(index, temp, dateItem)) {
                           Text($r('app.string.leave'))
                             .font({
                               size: $r('app.float.calendar_money_font_size'),
                               weight: CommonConstants.FONT_WEIGHT_400
                             })
                             .fontColor($r('app.color.start_window_background'))
                         }
                       }
                       .backgroundColor((this.startTime === this.getIndex(index, temp, dateItem)) ||
                         (this.stopTime === this.getIndex(index, temp, dateItem)) ?
                       $r('app.color.Calendar_selected_backgroundColor') : $r('app.color.start_window_background'))
                       .borderRadius($r('app.float.calendar_date_border'))
                       .onClick(() => {
                         if (this.startTime === CommonConstants.START_TIME) {
                           this.startTime = this.getDate(index, dateItem);
                         } else if (this.stopTime === CommonConstants.START_TIME) {
                           this.stopTime = Math.max(this.startTime, this.getDate(index, dateItem));
                           this.startTime = Math.min(this.startTime, this.getDate(index, dateItem));
                         } else {
                           this.stopTime = Math.max(this.startTime, this.getDate(index, dateItem));
                           this.startTime = Math.min(this.startTime, this.getDate(index, dateItem));
                         }
                       })
                       .justifyContent(FlexAlign.Center)
                       .width($r('app.float.low_price_all_height'))
                       .height($r('app.float.calendar_date_height'))
                     }
                   }, (dateItem: CalendarItem) => JSON.stringify(dateItem))
                 }
                 .width(CommonConstants.NINETY_FIVE_PERCENT)
                 .columnsGap($r('app.float.calendar_column_margin'))
                 .rowsGap($r('app.float.calendar_column_margin'))
                 .columnsTemplate(CommonConstants.GRID_COLUMN_TEMPLATE)
               }
               .backgroundColor($r('app.color.start_window_background'))
               .width(CommonConstants.FULL_WIDTH_PERCENT)
               .height(CommonConstants.FIFTY_FIVE_PERCENT)
               .borderRadius($r('app.float.calendar_card_border'))
               .margin({ bottom: $r('app.float.calendar_column_margin') })
             }, (item: Array<CalendarItem>) => JSON.stringify(item))
           }
           .width(CommonConstants.FULL_WIDTH_PERCENT)
         }
         .scrollBar(BarState.Off)
         .width(CommonConstants.NINETY_ONE_PERCENT)
         .height(CommonConstants.FULL_WIDTH_PERCENT)
         .margin({ top: $r('app.float.calendar_margin_top') })
       }
       .width(CommonConstants.FULL_WIDTH_PERCENT)
       .height(CommonConstants.FULL_WIDTH_PERCENT)
       .backgroundColor($r('app.color.hotel_page_background'))
     }
     .width(CommonConstants.FULL_WIDTH_PERCENT)
     .height(CommonConstants.FULL_WIDTH_PERCENT)
   }
   .hideTitleBar(true)
  }
}