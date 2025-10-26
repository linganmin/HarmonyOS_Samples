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
import { SearchTicketDateItem } from '../viewmodel/SearchTicketDateItem';
import { TicketItem } from '../viewmodel/TicketItem';

@Component
export struct SearchTopView {
  @State currentIndex: number = 0;
  @Link date: number;
  @StorageLink('breakPoint') breakPoint: string = CommonConstants.BREAK_POINT_LG;
  @Consume('ticketItems') ticketItems: Array<TicketItem>;
  @Consume('pageInfos') pageInfos : NavPathStack;

  getDateTicket() {
    let dateTicket: Array<TicketItem> = [];
    CommonConstants.TICKET_MESSAGE.forEach((element) => {
      if (element.date === CommonConstants.SEARCH_DATE_MESSAGE[this.date].getDate()) {
        dateTicket.push(element);
      }
    })
    return dateTicket;
  }

  getDateItems(breakPoint: string) {
    if (breakPoint === CommonConstants.BREAK_POINT_SM) {
      return CommonConstants.SEARCH_DATE_MESSAGE.slice(CommonConstants.NUMBER_ZERO, CommonConstants.NUMBER_SIX);
    } else if (breakPoint === CommonConstants.BREAK_POINT_MD) {
      return CommonConstants.SEARCH_DATE_MESSAGE.slice(CommonConstants.NUMBER_ZERO, CommonConstants.NUMBER_SEVEN);
    } else {
      return CommonConstants.SEARCH_DATE_MESSAGE.slice(CommonConstants.NUMBER_ZERO, CommonConstants.NUMBER_SIX);
    }
  }

  build() {
    Column() {
      Row() {
        Row() {
          Image($r('app.media.ic_public_back'))
            .width($r('app.float.week_info_lg_font_size'))
            .margin({ left: $r('app.float.calendar_column_margin') })
            .onClick(() => {
              this.pageInfos.pop();
            })
          Text(CommonConstants.JOURNEY)
            .margin({ left: $r('app.float.calendar_column_margin') })
            .font({ size: $r('app.float.low_price_font_size'), weight: CommonConstants.FONT_WEIGHT_500 })
            .fontColor($r('app.color.start_window_background'))
        }

        Image($r('app.media.more'))
          .margin({ right: $r('app.float.calendar_column_margin') })
          .width($r('app.float.room_date_font_size'))
          .height($r('app.float.room_date_font_size'))
      }
      .margin({ top: $r('app.float.index_page_button_margin') })
      .width(CommonConstants.NINETY_ONE_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        ForEach(this.getDateItems(this.breakPoint), (item: SearchTicketDateItem, index) => {
          Column() {
            Text(item.getWeek())
              .fontColor(this.date == index ? $r('app.color.Calendar_selected_backgroundColor') :
              $r('app.color.start_window_background'))
              .font({ size: 12, weight: CommonConstants.FONT_WEIGHT_500 })
            Text(item.getDate())
              .fontColor(this.date == index ? $r('app.color.Calendar_selected_backgroundColor') :
              $r('app.color.start_window_background'))
              .font({ size: $r('app.float.calendar_money_font_size'), weight: CommonConstants.FONT_WEIGHT_400 })
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .borderRadius($r('app.float.hotel_room_border'))
          .onClick(() => {
            this.date = index;
            this.ticketItems = [];
            this.ticketItems = this.getDateTicket();
          })
          .backgroundColor(this.date == index ? $r('app.color.start_window_background') :
          $r('app.color.Calendar_selected_backgroundColor'))
          .width(new BreakpointType(48, 68,
            55)
            .getValue(this.breakPoint))
          .height($r('app.float.low_price_all_height'))
        })
        Column() {
          Image($r('app.media.calendars'))
            .width($r('app.float.one_night_height'))
          Text($r('app.string.calendar'))
            .font({ size: $r('app.float.hotel_message_font_size'), weight: CommonConstants.FONT_WEIGHT_400 })
            .fontColor($r('app.color.Calendar_font_color'))
        }
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: $r('app.float.index_page_button_margin') })
      .width('95%')
      .height($r('app.float.low_price_all_height'))
    }
    .width(CommonConstants.FULL_WIDTH_PERCENT)
    .height(CommonConstants.FULL_WIDTH_PERCENT)
  }
}