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
import { CalendarDialogView } from './CalendarView';
import { HotelDetailsRoomItemView } from './HotelDetailsRoomItemView';

@Component
export struct HotelDetailsRoomView {
  @StorageLink('breakPoint') breakPoint: string = CommonConstants.BREAK_POINT_LG;
  @StorageLink('isShowingCalendar') @Watch('getFoldStatus') isShowingCalendar: boolean = false;
  @Consume('pageInfos') pageInfos : NavPathStack;
  dialogController: CustomDialogController = new CustomDialogController({
    builder: CalendarDialogView({}),
    alignment: DialogAlignment.Center,
    customStyle: true,
    cancel: () => {
      this.cancel();
    }
  })

  cancel(): void {
    this.isShowingCalendar = false;
  }
  // [Start get_fold_status]
  getFoldStatus() {
    if (this.isShowingCalendar) {
      this.dialogController.open();
    } else {
      this.dialogController.close()
    }
  }
  // [End get_fold_status]

  build() {
    Column() {
      Column() {
        Row() {
          Row() {
            Row() {
              Text(CommonConstants.ROOM_BUTTON_MESSAGES[CommonConstants.NUMBER_ZERO])
                .font({ size: $r('app.float.room_date_font_size'), weight: CommonConstants.FONT_WEIGHT_500 })
              Text(CommonConstants.ROOM_BUTTON_MESSAGES[CommonConstants.NUMBER_ONE])
                .margin({ left: $r('app.float.hotel_picture_padding') })
                .font({ size: $r('app.float.hotel_message_font_size'), weight: CommonConstants.FONT_WEIGHT_400 })
            }
            .alignItems(VerticalAlign.Bottom)

            Column() {
              Text(CommonConstants.ROOM_BUTTON_MESSAGES[CommonConstants.NUMBER_TWO])
                .font({ size: $r('app.float.today_font_Size'), weight: CommonConstants.FONT_WEIGHT_400 })
                .height(CommonConstants.FULL_WIDTH_PERCENT)
                .textAlign(TextAlign.Center)
            }
            .margin({ left: $r('app.float.calendar_column_margin'), right: $r('app.float.calendar_column_margin') })
            .width($r('app.float.one_night_width'))
            .height($r('app.float.one_night_height'))
            .borderRadius($r('app.float.calendar_column_margin'))
            .backgroundColor($r('app.color.one_night_background'))

            Row() {
              Text(CommonConstants.ROOM_BUTTON_MESSAGES[CommonConstants.NUMBER_THREE])
                .font({ size: $r('app.float.room_date_font_size'), weight: CommonConstants.FONT_WEIGHT_500 })
              Text(CommonConstants.ROOM_BUTTON_MESSAGES[CommonConstants.NUMBER_FOUR])
                .margin({ left: $r('app.float.hotel_picture_padding') })
                .font({ size: $r('app.float.hotel_message_font_size'), weight: CommonConstants.FONT_WEIGHT_500 })
            }
            .alignItems(VerticalAlign.Bottom)
          }

          Blank()
          Row() {
            // [Start get_fold_status_column]
            Column() {
              Image($r("app.media.cheap_day"))
                .width('15vp')
              Text(CommonConstants.ROOM_BUTTON_MESSAGES[5])
                .font({ size: '8fp', weight: 500 })
                .opacity(0.4)
            }
            .onClick(() => {
              if (this.breakPoint === 'sm') {
                this.pageInfos.pushPath(new NavPathInfo('LowPriceCalendarPage',[]));
              } else {
                this.isShowingCalendar = true;
              }
            })
            // [End get_fold_status_column]
            Column() {
              Image($r('app.media.one'))
                .width($r('app.float.January_2024_margin_top'))
              Text(CommonConstants.ROOM_BUTTON_MESSAGES[CommonConstants.NUMBER_SIX])
                .font({ size: $r('app.float.room_bundle_font_size'), weight: CommonConstants.FONT_WEIGHT_500 })
                .opacity(CommonConstants.OPACITY_FORTY_PERCENT)
            }
            .margin({ left: $r('app.float.calendar_column_margin') })
          }
        }
        .width(CommonConstants.FULL_WIDTH_PERCENT)
        .height($r('app.float.hotel_detail_order_height'))

        Row() {
          Row() {
            Column() {
              Text(CommonConstants.ROOM_BUTTON_MESSAGES[CommonConstants.NUMBER_SEVEN])
                .fontSize($r('app.float.hotel_message_font_size'))
                .textAlign(TextAlign.Center)
                .height(CommonConstants.FULL_WIDTH_PERCENT)
            }
            .margin({ right: $r('app.float.calendar_column_margin') })
            .borderRadius($r('app.float.hotel_room_border'))
            .height($r('app.float.receive_height'))
            .backgroundColor($r('app.color.hotel_card_background'))

            Column() {
              Text(CommonConstants.ROOM_BUTTON_MESSAGES[CommonConstants.NUMBER_EIGHT])
                .fontSize($r('app.float.hotel_message_font_size'))
                .textAlign(TextAlign.Center)
                .height(CommonConstants.FULL_WIDTH_PERCENT)
            }
            .margin({ right: $r('app.float.calendar_column_margin') })
            .borderRadius($r('app.float.hotel_room_border'))
            .height($r('app.float.receive_height'))
            .backgroundColor($r('app.color.hotel_card_background'))

            Column() {
              Text(CommonConstants.ROOM_BUTTON_MESSAGES[CommonConstants.NUMBER_NINE])
                .fontSize($r('app.float.hotel_message_font_size'))
                .textAlign(TextAlign.Center)
                .height(CommonConstants.FULL_WIDTH_PERCENT)
            }
            .margin({ right: $r('app.float.calendar_column_margin') })
            .borderRadius($r('app.float.hotel_room_border'))
            .height($r('app.float.receive_height'))
            .backgroundColor($r('app.color.hotel_card_background'))

            Column() {
              Text(CommonConstants.ROOM_BUTTON_MESSAGES[CommonConstants.NUMBER_TEN])
                .fontSize($r('app.float.hotel_message_font_size'))
                .textAlign(TextAlign.Center)
                .height(CommonConstants.FULL_WIDTH_PERCENT)
            }
            .margin({ right: $r('app.float.calendar_column_margin') })
            .borderRadius($r('app.float.hotel_room_border'))
            .height($r('app.float.receive_height'))
            .backgroundColor($r('app.color.hotel_card_background'))
          }
          .width(CommonConstants.NINETY_FIVE_PERCENT)
        }
        .margin({ bottom: $r('app.float.calendar_column_margin') })
        .width(CommonConstants.FULL_WIDTH_PERCENT)
        .height($r('app.float.receive_height'))

        HotelDetailsRoomItemView()
          .width(CommonConstants.FULL_WIDTH_PERCENT)
      }
      .width(CommonConstants.NINETY_FIVE_PERCENT)
    }
    .borderRadius($r('app.float.calendar_card_border'))
    .width(CommonConstants.FULL_WIDTH_PERCENT)
    .backgroundColor($r('app.color.start_window_background'))
  }
}
