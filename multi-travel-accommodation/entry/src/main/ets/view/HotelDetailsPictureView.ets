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

import { JSON } from '@kit.ArkTS';
import { CommonConstants } from '../commons/constants/CommonConstants';
import { HotelDetailsContentView } from './HotelDetailsContentView';
import { HotelDetailsOrderView } from './HotelDetailsOrderView';
import { HotelDetailsRoomView } from './HotelDetailsRoomView';

@Component
export struct HotelDetailsPictureView {
  @StorageLink('breakPoint') breakPoint: string = CommonConstants.BREAK_POINT_LG;
  @State mainPictureResource: Resource = CommonConstants.HOTEL_PICTURE_MESSAGE[CommonConstants.NUMBER_ZERO];
  @Link topLength: number;
  @Consume('pageInfos') pageInfos : NavPathStack;
  // [Start get_main_picture]
  getMainPicture(index: number) {
    this.mainPictureResource = CommonConstants.HOTEL_PICTURE_MESSAGE[index];
  }
  // [End get_main_picture]

  build() {
    if (this.breakPoint == CommonConstants.BREAK_POINT_SM) {
      Column() {
        Stack({ alignContent: Alignment.Top }) {
          Row() {
            Image($r('app.media.ic_public_back'))
              .width($r('app.float.index_page_button_margin'))
              .onClick(() => {
                this.pageInfos.pop();
              })
            Row() {
              Image($r('app.media.ic_public_favor'))
                .width($r('app.float.index_page_button_margin'))
                .margin({ right: $r('app.float.calendar_column_margin') })
              Image($r('app.media.ic_public_share'))
                .width($r('app.float.index_page_button_margin'))
                .margin({ right: $r('app.float.calendar_column_margin') })
              Image($r('app.media.ic_public_more'))
                .width($r('app.float.index_page_button_margin'))
            }
          }
          .margin({ top: $r('app.float.hotel_bar_margin_top') })
          .justifyContent(FlexAlign.SpaceBetween)
          .width(CommonConstants.NINETY_PERCENT)
          .height($r('app.float.hotel_bar_height'))
          .zIndex(CommonConstants.NUMBER_TWO)

          Column() {
            Image($r("app.media.hotel_phone"))
              .width(CommonConstants.FULL_WIDTH_PERCENT)
          }
          .backgroundColor($r('app.color.font_color_black'))
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .width(CommonConstants.FULL_WIDTH_PERCENT)
          .height(this.topLength)
          .zIndex(CommonConstants.NUMBER_ONE)
          .animation({
            duration: CommonConstants.NUMBER_THOUSAND,
            curve: Curve.EaseOut,
            iterations: CommonConstants.NUMBER_ONE,
            playMode: PlayMode.Normal
          })


          Column() {
            HotelDetailsContentView()
              .width(CommonConstants.FULL_WIDTH_PERCENT)
              .height($r('app.float.hotel_detail_content_height'))
            HotelDetailsOrderView()
              .margin({ top: $r('app.float.hotel_grade_border') })
              .width(CommonConstants.FULL_WIDTH_PERCENT)
              .height($r('app.float.hotel_detail_order_height'))
            HotelDetailsRoomView()
              .margin({ top: $r('app.float.hotel_grade_border') })
              .width(CommonConstants.FULL_WIDTH_PERCENT)

          }
          .margin({ top: this.topLength - CommonConstants.NUMBER_FIFTEEN })
          .animation({
            duration: CommonConstants.NUMBER_THOUSAND,
            curve: Curve.EaseOut,
            iterations: CommonConstants.NUMBER_ONE,
            playMode: PlayMode.Normal
          })
          .backgroundColor($r('app.color.hotel_page_background'))
          .width(CommonConstants.FULL_WIDTH_PERCENT)
          .zIndex(CommonConstants.NUMBER_TWO)
        }
      }
    } else if (this.breakPoint === CommonConstants.BREAK_POINT_MD) {
      Column() {
        Row() {
          Image($r('app.media.ic_public_back_black'))
            .width($r('app.float.index_page_button_margin'))
            .onClick((() => {
              this.pageInfos.pop();
            }))
          Row() {
            Image($r('app.media.ic_public_favor_black'))
              .width($r('app.float.index_page_button_margin'))
              .margin({ right: $r('app.float.hotel_bar_margin_top') })
            Image($r('app.media.ic_public_share_black'))
              .width($r('app.float.index_page_button_margin'))
              .margin({ right: $r('app.float.hotel_bar_margin_top') })
            Image($r('app.media.ic_public_more_black'))
              .width($r('app.float.index_page_button_margin'))
          }
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width(CommonConstants.NINETY_FIVE_PERCENT)
        .height(CommonConstants.TEN_PERCENT)

        Row() {
          Column() {
            Image(this.mainPictureResource)
              .width(CommonConstants.NINETY_PERCENT)
              .borderRadius($r('app.float.calendar_card_border'))
            // [Start scroll_get_main_picture]
            Scroll() {
              Row() {
                ForEach(CommonConstants.HOTEL_PICTURE_MESSAGE, (item: Resource, index: number) => {
                  Column() {
                    Image(item)
                      .width(CommonConstants.THIRTY_PERCENT)
                      .borderRadius($r('app.float.hotel_grade_border'))
                      .margin(index === CommonConstants.NUMBER_FOUR ? {} : { right: CommonConstants.FIVE_PERCENT })
                      .onClick(() => {
                        this.getMainPicture(index);
                      })
                  }
                }, (item: Resource) => JSON.stringify(item))
              }
            }
            .scrollBar(BarState.Off)
            .margin({ top: $r('app.float.calendar_column_margin') })
            .width(CommonConstants.NINETY_PERCENT)
            .scrollable(ScrollDirection.Horizontal)
            // [End scroll_get_main_picture]
          }
          .width(CommonConstants.FIFTY_PERCENT)
          .height(CommonConstants.FULL_WIDTH_PERCENT)

          Scroll() {
            Column() {
              HotelDetailsContentView()
                .width(CommonConstants.FULL_WIDTH_PERCENT)
                .height($r('app.float.hotel_detail_content_height'))
              HotelDetailsOrderView()
                .margin({ top: $r('app.float.hotel_grade_border') })
                .width(CommonConstants.FULL_WIDTH_PERCENT)
                .height($r('app.float.hotel_detail_order_height'))
              HotelDetailsRoomView()
                .margin({ top: $r('app.float.hotel_grade_border') })
                .width(CommonConstants.FULL_WIDTH_PERCENT)
            }
            .backgroundColor($r('app.color.hotel_page_background'))
            .width(CommonConstants.FULL_WIDTH_PERCENT)
            .zIndex(CommonConstants.NUMBER_TWO)
          }
          .scrollBar(BarState.Off)
          .width(CommonConstants.FIFTY_PERCENT)
        }
        .width(CommonConstants.FULL_WIDTH_PERCENT)
        .height(CommonConstants.NINETY_PERCENT)
      }
      .width(CommonConstants.FULL_WIDTH_PERCENT)
      .height(CommonConstants.FULL_WIDTH_PERCENT)
    } else {
      Stack({ alignContent: Alignment.Top }) {
        Row() {
          Image($r('app.media.ic_public_back'))
            .width($r('app.float.index_page_button_margin'))
            .onClick(() => {
              this.pageInfos.pop();
            })
          Row() {
            Image($r('app.media.ic_public_favor_black'))
              .width($r('app.float.index_page_button_margin'))
              .margin({ right: $r('app.float.calendar_column_margin') })
            Image($r('app.media.ic_public_share_black'))
              .width($r('app.float.index_page_button_margin'))
              .margin({ right: $r('app.float.calendar_column_margin') })
            Image($r('app.media.ic_public_more_black'))
              .width($r('app.float.index_page_button_margin'))
          }
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width(CommonConstants.NINETY_FIVE_PERCENT)
        .height(CommonConstants.TEN_PERCENT)
        .zIndex(CommonConstants.NUMBER_TWO)

        Row() {
          // [Start hotel_details_picture_swiper]
          Swiper() {
            ForEach(CommonConstants.HOTEL_PICTURE_MESSAGE, (item: Resource) => {
              Image(item)
                .width('100')
            }, (item: Resource) => JSON.stringify(item))
          }
          .width('40%')
          .height('100%')
          // [End hotel_details_picture_swiper]

          Scroll() {
            Column() {
              HotelDetailsContentView()
                .width(CommonConstants.FULL_WIDTH_PERCENT)
                .height($r('app.float.hotel_detail_content_height'))
              HotelDetailsOrderView()
                .margin({ top: $r('app.float.hotel_grade_border') })
                .width(CommonConstants.FULL_WIDTH_PERCENT)
                .height($r('app.float.hotel_detail_order_height'))
              HotelDetailsRoomView()
                .margin({ top: $r('app.float.hotel_grade_border') })
                .width(CommonConstants.FULL_WIDTH_PERCENT)
            }
            .backgroundColor($r('app.color.hotel_page_background'))
            .width(CommonConstants.FULL_WIDTH_PERCENT)
            .zIndex(CommonConstants.NUMBER_TWO)
          }
          .margin({ top: $r('app.float.hotel_scroll_margin_top') })
          .width(CommonConstants.SIXTY_PERCENT)
          .scrollBar(BarState.Off)
        }
        .width(CommonConstants.FULL_WIDTH_PERCENT)
        .height(CommonConstants.FULL_WIDTH_PERCENT)
      }
    }
  }
}
