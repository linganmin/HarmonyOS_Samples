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
import { SearchTicketListView } from './SearchTicketListView';

@Component
export struct SearchTicketTabView {
  @StorageLink('breakPoint') breakPoint: string = CommonConstants.BREAK_POINT_LG;
  @State tabArray: Array<number> = [CommonConstants.NUMBER_ZERO, CommonConstants.NUMBER_ONE];
  @State focusIndex: number = CommonConstants.NUMBER_ZERO;
  @State pre: number = CommonConstants.NUMBER_ZERO;
  @State index: number = CommonConstants.NUMBER_ZERO;
  @State test: boolean = false;
  @Link date: number;
  private controller: TabsController = new TabsController();

  build() {
    Flex({ direction: FlexDirection.Column }) {
      Row() {
        Stack({ alignContent: Alignment.TopStart }) {
          Row()
            .height(CommonConstants.NINETY_PERCENT)
            .width(CommonConstants.FULL_WIDTH_PERCENT)
            .backgroundColor($r('app.color.search_ticket_background'))
            .borderRadius({ topLeft: $r('app.float.hotel_grade_border'), topRight: $r('app.float.hotel_grade_border') })
          Flex({ direction: FlexDirection.Row }) {
            ForEach(CommonConstants.SEARCH_TICKET_BAR, (item: string, index) => {
              if (this.focusIndex != index) {
                Column() {
                  Text(item)
                    .height(CommonConstants.FULL_WIDTH_PERCENT)
                    .textAlign(TextAlign.Center)
                    .font({ size: $r('app.float.room_date_font_size'), weight: CommonConstants.FONT_WEIGHT_500 })
                }
                .justifyContent(FlexAlign.SpaceBetween)
                .alignItems(HorizontalAlign.Center)
                .height(CommonConstants.FULL_WIDTH_PERCENT)
                .onClick(() => {
                  this.focusIndex = index;
                })
                .width(CommonConstants.FIFTY_PERCENT)
              } else {
                Column() {
                  Text(item)
                    .height(CommonConstants.FULL_WIDTH_PERCENT)
                    .textAlign(TextAlign.Center)
                    .font({ size: $r('app.float.room_date_font_size'), weight: CommonConstants.FONT_WEIGHT_500 })
                    .fontColor(Color.Blue)
                }
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                .width(CommonConstants.FIFTY_PERCENT)
                .height(CommonConstants.FULL_WIDTH_PERCENT)
              }
            }, (item: string) => JSON.stringify(item))
          }
          .zIndex(CommonConstants.NUMBER_TWO)
          .borderRadius({ topLeft: $r('app.float.hotel_grade_border'), topRight: $r('app.float.hotel_grade_border') })
          .backgroundColor(Color.Transparent)
          .height(CommonConstants.FULL_WIDTH_PERCENT)
          .width(CommonConstants.FULL_WIDTH_PERCENT)

          if (this.focusIndex === CommonConstants.NUMBER_ZERO) {
            Image($r('app.media.phone_left'))
              .width(CommonConstants.FIFTY_PERCENT)
              .zIndex(CommonConstants.NUMBER_ONE)
          } else {
            Image($r('app.media.phone_right'))
              .width(CommonConstants.FIFTY_PERCENT)
              .margin({ left: CommonConstants.FIFTY_PERCENT })
              .zIndex(CommonConstants.NUMBER_ONE)
          }

        }
        .height(CommonConstants.FULL_WIDTH_PERCENT)
        .width(CommonConstants.FULL_WIDTH_PERCENT)
      }
      .borderRadius($r('app.float.hotel_grade_border'))
      .height($r('app.float.hotel_bar_height'))
      .width(CommonConstants.FULL_WIDTH_PERCENT)

      Tabs({ barPosition: BarPosition.Start, controller: this.controller }) {
        ForEach(this.tabArray, (item: number, index: number) => {
          TabContent() {
            SearchTicketListView({ date: this.date })
              .height(CommonConstants.FULL_WIDTH_PERCENT)
              .width(CommonConstants.FULL_WIDTH_PERCENT)
          }
          .borderRadius({
            bottomLeft: $r('app.float.hotel_grade_border'),
            bottomRight: $r('app.float.hotel_grade_border')
          })
        }, (item: number) => JSON.stringify(item))
      }
      .height(CommonConstants.FULL_WIDTH_PERCENT)
      .width(CommonConstants.FULL_WIDTH_PERCENT)
      .backgroundColor($r('app.color.search_ticket_background'))
      .width(CommonConstants.FULL_WIDTH_PERCENT)
      .barHeight(CommonConstants.NUMBER_ZERO)
      .animationDuration(CommonConstants.NUMBER_ONE_HUNDRED)
      .onChange((index: number) => {
        this.focusIndex = index;
      })
    }
    .backgroundColor($r('app.color.search_ticket_background'))
    .height(CommonConstants.FULL_WIDTH_PERCENT)
    .width(CommonConstants.FULL_WIDTH_PERCENT)
    .borderRadius($r('app.float.calendar_card_border'))
  }
}
