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
import { SearchTicketBarItem } from '../viewmodel/SearchTicketBarItem';
import { TicketItem } from '../viewmodel/TicketItem';
import { SearchTicketTabView } from './SearchTicketTabView';
import { SearchTopView } from './SearchTopView';

@Component
export struct SearchTicketView {
  @State Index: number = CommonConstants.NUMBER_ZERO;
  @State date: number = CommonConstants.NUMBER_ZERO;
  @StorageLink('breakPoint') breakPoint: string = CommonConstants.BREAK_POINT_LG;
  @Provide ticketItems: Array<TicketItem> =
    CommonConstants.TICKET_MESSAGE.slice(CommonConstants.NUMBER_ZERO, CommonConstants.NUMBER_ELEVEN);

  build() {
    if (this.breakPoint !== CommonConstants.BREAK_POINT_LG) {
      Column() {
        Flex({ direction: FlexDirection.Column }) {
          Stack({ alignContent: Alignment.Top }) {
            SearchTopView({ date: this.date })
              .backgroundColor($r('app.color.Calendar_selected_backgroundColor'))
              .width(CommonConstants.FULL_WIDTH_PERCENT)
              .height($r('app.float.calendar_height'))
            SearchTicketTabView({ date: this.date })
              .width(CommonConstants.FULL_WIDTH_PERCENT)
              .height(CommonConstants.AUTO_HEIGHT)
              .margin({ top: $r('app.float.Search_bar_margin_top') })
          }
          .width(CommonConstants.FULL_WIDTH_PERCENT)
          .height(CommonConstants.FULL_WIDTH_PERCENT)

          Row() {
            ForEach(CommonConstants.SEARCH_BAR_MESSAGE, (item: SearchTicketBarItem, index) => {
              Column() {
                Image(item.getImage())
                  .width($r('app.float.week_info_lg_font_size'))
                Text(item.getTitle())
                  .margin({ top: $r('app.float.hotel_content_margin_top') })
                  .font({ size: $r('app.float.calendar_money_font_size'), weight: CommonConstants.FONT_WEIGHT_500 })
              }
              .width($r('app.float.search_bar_height'))
              .height($r('app.float.low_price_all_height'))
              .onClick(() => {
                if (this.Index != index) {
                  this.Index = index;
                }
                if (this.Index === CommonConstants.NUMBER_ONE) {
                  this.ticketItems.sort((a: TicketItem, b: TicketItem) => {
                    let aHour: number =
                      Number.parseInt(a.totalDuration.slice(CommonConstants.NUMBER_ZERO, CommonConstants.NUMBER_ONE));
                    let aMinuter: number =
                      Number.parseInt(a.totalDuration.slice(CommonConstants.NUMBER_TWO, CommonConstants.NUMBER_FOUR))
                    let aTime = aHour * CommonConstants.NUMBER_SIXTY + aMinuter;
                    let bHour: number =
                      Number.parseInt(b.totalDuration.slice(CommonConstants.NUMBER_ZERO, CommonConstants.NUMBER_ONE));
                    let bMinuter: number =
                      Number.parseInt(b.totalDuration.slice(CommonConstants.NUMBER_TWO, CommonConstants.NUMBER_FOUR))
                    let bTime = bHour * CommonConstants.NUMBER_SIXTY + bMinuter;
                    return aTime - bTime;

                  })
                } else if (this.Index === CommonConstants.NUMBER_TWO) {
                  this.ticketItems.sort((a: TicketItem, b: TicketItem) => {
                    let aStartHour: number =
                      Number.parseInt(a.startTime.slice(CommonConstants.NUMBER_ZERO, CommonConstants.NUMBER_TWO));
                    let aStartMinuter: number =
                      Number.parseInt(a.startTime.slice(CommonConstants.NUMBER_THREE, CommonConstants.NUMBER_FIVE))
                    let bStartHour: number =
                      Number.parseInt(b.startTime.slice(CommonConstants.NUMBER_ZERO, CommonConstants.NUMBER_TWO));
                    let bStartMinuter: number =
                      Number.parseInt(b.startTime.slice(CommonConstants.NUMBER_THREE, CommonConstants.NUMBER_FIVE))
                    if (aStartHour - bStartHour !== CommonConstants.NUMBER_ZERO) {
                      return aStartHour - bStartHour;
                    }
                    return aStartMinuter - bStartMinuter;
                  })
                } else if (this.Index === CommonConstants.NUMBER_THREE) {
                  this.ticketItems.sort((a: TicketItem, b: TicketItem) => {
                    return a.money - b.money;
                  })
                } else {
                  return;
                }
              })
            }, (item: SearchTicketBarItem) => JSON.stringify(item))
          }
          .justifyContent(FlexAlign.SpaceAround)
          .width(CommonConstants.FULL_WIDTH_PERCENT)
          .height($r('app.float.buy_button_width'))
          .backgroundColor($r('app.color.start_window_background'))
        }
        .width(CommonConstants.FULL_WIDTH_PERCENT)
        .height(CommonConstants.FULL_WIDTH_PERCENT)
      }
    } else {
      Row() {
        Column() {
          Flex({ direction: FlexDirection.Column }) {
            Stack({ alignContent: Alignment.Top }) {
              SearchTopView({ date: this.date })
                .backgroundColor($r('app.color.Calendar_selected_backgroundColor'))
                .width(CommonConstants.FULL_WIDTH_PERCENT)
                .height($r('app.float.calendar_height'))

              SearchTicketTabView({ date: this.date })
                .width(CommonConstants.FULL_WIDTH_PERCENT)
                .height(CommonConstants.AUTO_HEIGHT)
                .margin({ top: $r('app.float.Search_bar_margin_top') })
            }
            .width(CommonConstants.FULL_WIDTH_PERCENT)
            .height(CommonConstants.FULL_WIDTH_PERCENT)

            Row() {
              ForEach(CommonConstants.SEARCH_BAR_MESSAGE, (item: SearchTicketBarItem, index) => {
                Column() {
                  Image(item.getImage())
                    .width($r('app.float.week_info_lg_font_size'))
                  Text(item.getTitle())
                    .margin({ top: $r('app.float.hotel_content_margin_top') })
                    .font({ size: $r('app.float.calendar_money_font_size'), weight: CommonConstants.FONT_WEIGHT_500 })
                }
                .width($r('app.float.search_bar_height'))
                .height($r('app.float.low_price_all_height'))
                .onClick(() => {
                  if (this.Index != index) {
                    this.Index = index;
                  }
                  if (this.Index === CommonConstants.NUMBER_ONE) {
                    this.ticketItems.sort((a: TicketItem, b: TicketItem) => {
                      let aHour: number =
                        Number.parseInt(a.totalDuration.slice(CommonConstants.NUMBER_ZERO, CommonConstants.NUMBER_ONE));
                      let aMinuter: number =
                        Number.parseInt(a.totalDuration.slice(CommonConstants.NUMBER_TWO, CommonConstants.NUMBER_FOUR))
                      let aTime = aHour * CommonConstants.NUMBER_SIXTY + aMinuter;
                      let bHour: number =
                        Number.parseInt(b.totalDuration.slice(CommonConstants.NUMBER_ZERO, CommonConstants.NUMBER_ONE));
                      let bMinuter: number =
                        Number.parseInt(b.totalDuration.slice(CommonConstants.NUMBER_TWO, CommonConstants.NUMBER_FOUR))
                      let bTime = bHour * CommonConstants.NUMBER_SIXTY + bMinuter;
                      return aTime - bTime;

                    })
                  } else if (this.Index === CommonConstants.NUMBER_TWO) {
                    this.ticketItems.sort((a: TicketItem, b: TicketItem) => {
                      let aStartHour: number =
                        Number.parseInt(a.startTime.slice(CommonConstants.NUMBER_ZERO, CommonConstants.NUMBER_TWO));
                      let aStartMinuter: number =
                        Number.parseInt(a.startTime.slice(CommonConstants.NUMBER_THREE, CommonConstants.NUMBER_FIVE))
                      let bStartHour: number =
                        Number.parseInt(b.startTime.slice(CommonConstants.NUMBER_ZERO, CommonConstants.NUMBER_TWO));
                      let bStartMinuter: number =
                        Number.parseInt(b.startTime.slice(CommonConstants.NUMBER_THREE, CommonConstants.NUMBER_FIVE))
                      if (aStartHour - bStartHour !== CommonConstants.NUMBER_ZERO) {
                        return aStartHour - bStartHour;
                      }
                      return aStartMinuter - bStartMinuter;
                    })
                  } else if (this.Index === CommonConstants.NUMBER_THREE) {
                    this.ticketItems.sort((a: TicketItem, b: TicketItem) => {
                      return a.money - b.money;
                    })
                  } else {
                    return;
                  }
                })
              }, (item: SearchTicketBarItem) => JSON.stringify(item))
            }
            .justifyContent(FlexAlign.SpaceAround)
            .width(CommonConstants.FULL_WIDTH_PERCENT)
            .height($r('app.float.buy_button_width'))
            .backgroundColor($r('app.color.start_window_background'))
          }
          .width(CommonConstants.FULL_WIDTH_PERCENT)
          .height(CommonConstants.FULL_WIDTH_PERCENT)
        }
        .width(CommonConstants.FORTY_PERCENT)
        .height(CommonConstants.FULL_WIDTH_PERCENT)

        Column() {
          Stack({ alignContent: Alignment.BottomEnd }) {
            Column()
              .width(CommonConstants.FULL_WIDTH_PERCENT)
              .backgroundColor($r('app.color.search_blue_background'))
              .height($r('app.float.calendar_height'))
              .zIndex(CommonConstants.NUMBER_TWO)
            Row()
              .width(CommonConstants.FULL_WIDTH_PERCENT)
              .height($r('app.float.hotel_bar_height'))
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

          Column() {
            Image($r("app.media.SearchNoResult"))
              .width($r('app.float.room_all_picture_width'))
            Text($r('app.string.select_train_number'))
              .font({ size: $r('app.float.room_message_weo_width'), weight: CommonConstants.FONT_WEIGHT_400 })
              .opacity(CommonConstants.OPACITY_FORTY_PERCENT)
          }
        }
        .width(CommonConstants.SIXTY_PERCENT)
        .height(CommonConstants.FULL_WIDTH_PERCENT)
      }
    }

  }
}
