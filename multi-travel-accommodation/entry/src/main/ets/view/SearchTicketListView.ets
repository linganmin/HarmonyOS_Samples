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
import { SearchTicketCheckboxItem } from '../viewmodel/SearchTicketCheckboxItem';
import { TicketItem } from '../viewmodel/TicketItem';

@Component
export struct SearchTicketListView {
  @State currentIndex: number = CommonConstants.NUMBER_ZERO;
  @StorageLink('breakPoint') breakPoint: string = CommonConstants.BREAK_POINT_LG;
  @Consume('ticketItems') ticketItems: Array<TicketItem>;
  @Link date: number;
  @State siftCondition: Array<SearchTicketCheckboxItem> = [
    new SearchTicketCheckboxItem(CommonConstants.FILTERING_CRITERIA[CommonConstants.NUMBER_ZERO], false),
    new SearchTicketCheckboxItem(CommonConstants.FILTERING_CRITERIA[CommonConstants.NUMBER_ONE], false),
    new SearchTicketCheckboxItem(CommonConstants.FILTERING_CRITERIA[CommonConstants.NUMBER_TWO], false)
  ];

  getTicketItem(condition: boolean[]) {
    let allTicket: Array<TicketItem> = this.getDateTicket();
    this.ticketItems = [];
    if (condition[CommonConstants.NUMBER_ZERO] && condition[CommonConstants.NUMBER_ONE]) {
      this.ticketItems = this.getDateTicket();
    } else if (!(condition[CommonConstants.NUMBER_ZERO] || condition[CommonConstants.NUMBER_ONE])) {
      this.ticketItems = this.getDateTicket();
    } else {
      if (condition[CommonConstants.NUMBER_ZERO]) {
        allTicket.forEach((element) => {
          if (!element.getWetherTrain()) {
            this.ticketItems.push(element);
          }
        })
        allTicket = this.ticketItems;
      } else {
        allTicket.forEach((element) => {
          if (element.getWetherTrain()) {
            this.ticketItems.push(element);
          }
        })
        allTicket = this.ticketItems;
      }
    }
    if (condition[CommonConstants.NUMBER_TWO]) {
      this.ticketItems.forEach((element) => {
        if (!element.getWetherHasTicket()) {
          this.ticketItems.splice(this.ticketItems.indexOf(element), CommonConstants.NUMBER_ONE);
        }
      })
    }
  }

  getDateTicket() {
    let dateTicket: Array<TicketItem> = [];
    CommonConstants.TICKET_MESSAGE.forEach((element) => {
      if (element.date === CommonConstants.SEARCH_DATE_MESSAGE[this.date].getDate()) {
        dateTicket.push(element);
      }
    })
    return dateTicket;
  }

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center }) {
      Row() {
        Row() {
          ForEach(this.siftCondition, (item: SearchTicketCheckboxItem, index: number) => {
            Checkbox()
              .shape(CheckBoxShape.ROUNDED_SQUARE)
              .onChange((value: boolean) => {
                this.siftCondition[index].setResult(value);
              })
              .margin({ right: $r('app.float.hotel_content_margin_top') })
              .width($r('app.float.checkbox_width'))
            Text(item.getTitle())
              .margin({ right: $r('app.float.hotel_content_margin_top') })
              .font({ size: $r('app.float.hotel_message_font_size'), weight: CommonConstants.FONT_WEIGHT_400 })
              .opacity(CommonConstants.OPACITY_NINETY_PERCENT)
          }, (item: SearchTicketCheckboxItem) => JSON.stringify(item))
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)

        Row() {
          Image($r('app.media.sift'))
            .width($r('app.float.one_night_height'))
          Text($r('app.string.sift'))
            .margin({ left: $r('app.float.hotel_picture_padding') })
            .font({ size: $r('app.float.hotel_message_font_size'), weight: CommonConstants.FONT_WEIGHT_400 })
            .opacity(CommonConstants.OPACITY_NINETY_PERCENT)
        }
        .onClick(() => {
          this.getTicketItem([
            this.siftCondition[CommonConstants.NUMBER_ZERO].getResult(),
            this.siftCondition[CommonConstants.NUMBER_ONE].getResult(),
            this.siftCondition[CommonConstants.NUMBER_TWO].getResult()
          ]);
        })

      }
      .margin({ top: $r('app.float.calendar_column_margin') })
      .width(CommonConstants.NINETY_ONE_PERCENT)

      Row() {
        ForEach(CommonConstants.SEARCH_ADDRESS_BUTTON_MESSAGE, (item: Resource, index: number) => {
          Column() {
            Text(item)
              .font({ size: $r('app.float.hotel_message_font_size'), weight: CommonConstants.FONT_WEIGHT_400 })
              .opacity(CommonConstants.OPACITY_NINETY_PERCENT)
              .textAlign(TextAlign.Center)
          }
          .margin({ right: $r('app.float.calendar_column_margin') })
          .onClick(() => {
            let allTicket = this.getDateTicket();
            this.ticketItems = [];
            if (index === CommonConstants.NUMBER_ZERO || index === CommonConstants.NUMBER_ONE) {
              allTicket.forEach((element) => {
                let startPoint : string = this.getUIContext().getHostContext()!.resourceManager.getStringSync(element.startPoint.id);
                let button: string = this.getUIContext().getHostContext()!.resourceManager.getStringSync(item.id);
                if (startPoint === button) {
                  this.ticketItems.push(element);
                }
              })
            } else {
              allTicket.forEach((element) => {
                let arrivePoint : string = this.getUIContext().getHostContext()!.resourceManager.getStringSync(element.arrivePoint.id);
                let button: string = this.getUIContext().getHostContext()!.resourceManager.getStringSync(item.id);
                if (arrivePoint === button) {
                  this.ticketItems.push(element);
                }
              })
            }

          })
          .justifyContent(FlexAlign.Center)
          .width($r('app.float.hotel_room_Width'))
          .height($r('app.float.receive_height'))
          .borderRadius($r('app.float.hotel_room_border'))
          .backgroundColor($r('app.color.start_window_background'))
        }, (item: string) => JSON.stringify(item))
      }
      .margin({ top: $r('app.float.room_picture_border'), bottom: $r('app.float.room_picture_border') })
      .width(CommonConstants.NINETY_ONE_PERCENT)

      Scroll() {
        Column() {
          ForEach(this.ticketItems, (item: TicketItem) => {
            Column() {
              Row() {
                Column() {
                  Text(item.startTime)
                    .font({ size: $r('app.float.low_price_font_size'), weight: CommonConstants.FONT_WEIGHT_500 })
                    .opacity(CommonConstants.OPACITY_NINETY_PERCENT)
                  Text(item.startPoint)
                    .font({ size: $r('app.float.room_message_weo_width'), weight: CommonConstants.FONT_WEIGHT_400 })
                    .opacity(CommonConstants.OPACITY_EIGHTY_PERCENT)
                }

                Column() {
                  Text(item.tranTrip)
                    .font({ size: $r('app.float.room_date_font_size'), weight: CommonConstants.FONT_WEIGHT_400 })
                    .opacity(CommonConstants.OPACITY_NINETY_PERCENT)
                  Image($r('app.media.arrows'))
                    .width(CommonConstants.TWENTY_TWO_PERCENT)
                  Text(item.totalDuration)
                    .font({ size: $r('app.float.hotel_message_font_size'), weight: CommonConstants.FONT_WEIGHT_400 })
                    .opacity(CommonConstants.OPACITY_FORTY_PERCENT)
                }
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)

                Column() {
                  Text(item.arriveTime)
                    .font({ size: $r('app.float.low_price_font_size'), weight: CommonConstants.FONT_WEIGHT_500 })
                    .opacity(CommonConstants.OPACITY_NINETY_PERCENT)
                  Text(item.arrivePoint)
                    .font({ size: $r('app.float.room_message_weo_width'), weight: CommonConstants.FONT_WEIGHT_400 })
                    .opacity(CommonConstants.OPACITY_EIGHTY_PERCENT)
                }

                Row() {
                  Text(CommonConstants.MONEY)
                    .fontColor($r('app.color.money_color'))
                    .font({ size: $r('app.float.hotel_message_font_size'), weight: CommonConstants.FONT_WEIGHT_400 })
                  Text(item.money + CommonConstants.EMPTY_STRING)
                    .fontColor($r('app.color.money_color'))
                    .font({ size: $r('app.float.week_info_lg_font_size'), weight: CommonConstants.FONT_WEIGHT_500 })
                  Text(CommonConstants.START)
                    .fontColor($r('app.color.money_color'))
                    .font({ size: $r('app.float.hotel_message_font_size'), weight: CommonConstants.FONT_WEIGHT_400 })
                }
                .alignItems(VerticalAlign.Bottom)
              }
              .width(CommonConstants.NINETY_FIVE_PERCENT)
              .justifyContent(FlexAlign.SpaceBetween)

              Row() {
                Row() {
                  Text($r('app.string.second_class_seating'))
                    .font({ size: $r('app.float.hotel_message_font_size'), weight: CommonConstants.FONT_WEIGHT_400 })
                    .opacity(CommonConstants.OPACITY_FORTY_PERCENT)
                    .margin({ right: $r('app.float.hotel_content_margin_top') })
                  Text(item.secondClassNumber.toString())
                    .font({ size: $r('app.float.hotel_message_font_size'), weight: CommonConstants.FONT_WEIGHT_400 })
                    .fontColor($r('app.color.ticket_number'))
                    .margin({ right: $r('app.float.calendar_column_margin') })
                }
                .margin({ right: $r('app.float.calendar_column_margin') })

                Row() {
                  Text($r('app.string.first_class_seating'))
                    .font({ size: $r('app.float.hotel_message_font_size'), weight: CommonConstants.FONT_WEIGHT_400 })
                    .opacity(CommonConstants.OPACITY_FORTY_PERCENT)
                    .margin({ right: $r('app.float.hotel_content_margin_top') })
                  Text(item.firstClassNumber.toString())
                    .font({ size: $r('app.float.hotel_message_font_size'), weight: CommonConstants.FONT_WEIGHT_400 })
                    .fontColor($r('app.color.ticket_number'))
                    .margin({ right: $r('app.float.calendar_column_margin') })
                }
                .margin({ right: $r('app.float.calendar_column_margin') })

                Row() {
                  Text($r('app.string.Business_Seating'))
                    .font({ size: $r('app.float.hotel_message_font_size'), weight: CommonConstants.FONT_WEIGHT_400 })
                    .opacity(CommonConstants.OPACITY_FORTY_PERCENT)
                    .margin({ right: $r('app.float.hotel_content_margin_top') })
                  Text(item.businessNumber.toString())
                    .font({ size: $r('app.float.hotel_message_font_size'), weight: CommonConstants.FONT_WEIGHT_400 })
                    .fontColor($r('app.color.ticket_number'))
                    .margin({ right: $r('app.float.calendar_column_margin') })
                }
                .margin({ right: $r('app.float.calendar_column_margin') })
              }
              .width(CommonConstants.NINETY_FIVE_PERCENT)
            }
            .justifyContent(FlexAlign.SpaceAround)
            .width(CommonConstants.NINETY_ONE_PERCENT)
            .height($r('app.float.room_all_picture_width'))
            .backgroundColor($r('app.color.start_window_background'))
            .margin({ bottom: $r('app.float.calendar_column_margin') })
            .borderRadius($r('app.float.hotel_grade_border'))
          }, (item: TicketItem) => JSON.stringify(item))
        }
      }
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
      .width(CommonConstants.FULL_WIDTH_PERCENT)
      .height(CommonConstants.ONE_HUNDRED_FIFTY_PERCENT)
    }
    .width(CommonConstants.FULL_WIDTH_PERCENT)
    .height(CommonConstants.FULL_WIDTH_PERCENT)
    .backgroundColor($r('app.color.search_ticket_background'))
    .borderRadius($r('app.float.calendar_card_border'))
  }
}
