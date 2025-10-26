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

import { BreakpointConstants } from '../constants/BreakpointConstants';
import { ShopInformation } from '../viewmodel/ShopDisplayViewModel';
import { BreakpointType } from '../utils/BreakpointType';
import { CommonConstants } from '../constants/CommonConstants';

@Component
export struct ShopHeader {
  private shopInformation = new ShopInformation();
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @Consume('ifShowSides') ifShowSides: boolean;
  @Consume('pageInfo') pageInfo: NavPathStack;

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Image($r('app.media.shopHeaderImage'))
        .width(CommonConstants.FULL_PERCENT)
        .objectFit(ImageFit.Cover)
        .height($r('app.float.head_image_height'))

      Column() {
        Row() {
          Column() {
            Row() {
              Text(this.shopInformation.getShopName())
                .fontWeight(CommonConstants.FONT_WEIGHT_700)
                .fontSize($r('app.float.delicious_font'))
            }
            .margin({
              bottom: $r('app.float.margin_food')
            })

            Row() {
              Text(JSON.stringify(this.shopInformation.getShopRating()))
                .fontColor($r('app.color.currency_symbol'))
                .fontSize($r('app.float.tabs_font'))
                .fontWeight(CommonConstants.FONT_WEIGHT_700)
                .margin({
                  right: $r('app.float.favor_bottom')
                })
              Text(this.shopInformation.getShopProfile())
                .fontColor($r('app.color.sixty_black'))
                .fontSize($r('app.float.delivery_font'))
                .fontWeight(CommonConstants.FONT_WEIGHT_400)
            }
            .margin({
              bottom: $r('app.float.tabs_padding_tb')
            })

            Row() {
              Text(this.shopInformation.getShopRanking())
                .fontWeight(CommonConstants.FONT_WEIGHT_400)
                .fontColor($r('app.color.currency_symbol'))
                .fontSize($r('app.float.filtering_font'))
                .backgroundColor('#1aed6f21')
                .padding($r('app.float.filtering_padding_lr'))
                .borderRadius($r('app.float.orange_border'))
            }
          }
          .alignItems(HorizontalAlign.Start)

          Blank()
          Image($r('app.media.shopPicture'))
            .width($r('app.float.enlarge_dish_margin_left'))
            .aspectRatio(1)
        }
        .width(CommonConstants.FULL_PERCENT)
        .margin({
          bottom: $r('app.float.favor_bottom')
        })

        Row() {
          Text(this.shopInformation.getShopAnnouncements())
            .fontColor($r('app.color.sixty_black'))
            .fontSize($r('app.float.delivery_font'))
            .fontWeight(CommonConstants.FONT_WEIGHT_400)
            .layoutWeight(1)
        }
        .width(CommonConstants.FULL_PERCENT)
        .margin({
          bottom: $r('app.float.five_margin')
        })

        Row() {
          ForEach(this.shopInformation.getShopTags(), (item: string) => {
            Text(item)
              .fontColor('#E02020')
              .fontSize($r('app.float.filtering_font'))
              .fontWeight(CommonConstants.FONT_WEIGHT_400)
              .borderColor('#E02020')
              .borderWidth($r('app.float.border_width'))
              .borderRadius($r('app.float.add_cart_border'))
              .padding({
                top: $r('app.float.filtering_padding_tb'),
                bottom: $r('app.float.filtering_padding_tb'),
                left: $r('app.float.flag_margin_right'),
                right: $r('app.float.flag_margin_right')
              })
              .margin({
                right: $r('app.float.flag_margin_right')
              })
          })
        }
      }
      .margin({
        top: $r('app.float.shop_margin_top')
      })
      .alignItems(HorizontalAlign.Start)
      .borderRadius({
        topLeft: $r('app.float.img_choose_width'),
        topRight: $r('app.float.img_choose_width')
      })
      .width(CommonConstants.FULL_PERCENT)
      .backgroundColor(Color.White)
      .padding({
        top: $r('app.float.padding_small'),
        left: this.ifShowSides ? new BreakpointType($r('app.float.padding_small'), $r('app.float.padding_small'),
          $r('app.float.common_padding')).getValue(this.currentBreakpoint) :
        new BreakpointType($r('app.float.padding_small'), $r('app.float.common_padding'),
          $r('app.float.common_padding')).getValue(this.currentBreakpoint),
        right: this.ifShowSides ? new BreakpointType($r('app.float.padding_small'), $r('app.float.padding_small'),
          $r('app.float.common_padding')).getValue(this.currentBreakpoint) :
        new BreakpointType($r('app.float.padding_small'), $r('app.float.common_padding'),
          $r('app.float.common_padding')).getValue(this.currentBreakpoint)
      })
    }
  }
}

@Component
export struct ShopSideBar {
  private shopInformation = new ShopInformation()
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @StorageLink('windowTop') windowTop: number = 0;
  @StorageLink('windowBottom') windowBottom: number = 0;
  @Consume('ifShowSides') ifShowSides: boolean;
  @Consume('pageInfo') pageInfo: NavPathStack;

  build() {
    Stack() {
      Image($r('app.media.shopHeaderImage'))
        .height(CommonConstants.FULL_PERCENT)
        .width(CommonConstants.FULL_PERCENT)
        .objectFit(ImageFit.Cover)

      Column() {
        Row() {
          Image($r('app.media.icon_back'))
            .width($r('app.float.common_image'))
            .aspectRatio(1)
            .onClick(() => {
              this.pageInfo.pop()
            })
            .margin({
              right: $r('app.float.back_image_right')
            })
          Image($r('app.media.ic_public_reduce'))
            .width($r('app.float.common_image'))
            .aspectRatio(1)
            .onClick(() => {
              this.ifShowSides = true;
            })
        }
        .width(CommonConstants.FULL_PERCENT)
        .justifyContent(FlexAlign.Start)
        .margin({
          top: this.windowTop
        })

        Column() {
          Row() {
            Text(this.shopInformation.getShopName())
              .fontSize($r('app.float.shop_name_font'))
              .fontWeight(CommonConstants.FONT_WEIGHT_700)
              .fontColor(Color.White)
          }
          .margin({
            bottom: $r('app.float.filtering_margin_right')
          })

          Row() {
            Text(JSON.stringify(this.shopInformation.getShopRating()))
              .fontSize($r('app.float.shop_rating_font'))
              .fontWeight(CommonConstants.FONT_WEIGHT_700)
              .fontColor(Color.White)
          }
          .margin({
            bottom: $r('app.float.filtering_margin_right')
          })

          Row() {
            Text(this.shopInformation.getShopProfile())
              .fontSize($r('app.float.delivery_font'))
              .fontWeight(CommonConstants.FONT_WEIGHT_400)
              .fontColor('#99ffffff')
              .margin({
                right: $r('app.float.filtering_margin_right')
              })
            Text(this.shopInformation.getShopRanking())
              .fontColor(Color.White)
              .fontSize($r('app.float.filtering_font'))
              .fontWeight(CommonConstants.FONT_WEIGHT_400)
              .backgroundColor($r('app.color.ten_white'))
              .borderRadius($r('app.float.add_cart_border'))
              .padding({
                top: $r('app.float.filtering_padding_tb'),
                bottom: $r('app.float.filtering_padding_tb'),
                left: $r('app.float.flag_margin_right'),
                right: $r('app.float.flag_margin_right')
              })
              .margin({
                right: $r('app.float.flag_margin_right')
              })
          }
          .margin({
            bottom: $r('app.float.filtering_margin_right')
          })

          Row() {
            Text(this.shopInformation.getShopAnnouncements())
              .fontSize($r('app.float.delivery_font'))
              .fontWeight(CommonConstants.FONT_WEIGHT_400)
              .fontColor('#99ffffff')
          }
          .margin({
            bottom: $r('app.float.filtering_margin_right')
          })

          Row() {
            ForEach(this.shopInformation.getShopTags(), (item: string) => {
              Text(item)
                .fontColor(Color.White)
                .fontWeight(CommonConstants.FONT_WEIGHT_400)
                .borderColor(Color.White)
                .borderWidth($r('app.float.border_width'))
                .borderRadius($r('app.float.dish_border_bottom'))
                .fontSize($r('app.float.tags_font_size'))
                .padding({
                  top: $r('app.float.filtering_padding_tb'),
                  bottom: $r('app.float.filtering_padding_tb'),
                  left: $r('app.float.flag_margin_right'),
                  right: $r('app.float.flag_margin_right')
                })
                .margin({
                  right: $r('app.float.flag_margin_right')
                })
            }
            )
          }
        }
        .alignItems(HorizontalAlign.Start)
        .width(CommonConstants.FULL_PERCENT)
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        top: $r('app.float.shop_padding_top'),
        left: $r('app.float.padding_header'),
        bottom: $r('app.float.padding_header')
      })
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
      .linearGradient({
        angle: CommonConstants.ANGLE_IMAGE,
        colors: [[CommonConstants.LINEAR_GRADIENT_FIRST, CommonConstants.LINEAR_GRADIENT_INDEX],
          [CommonConstants.LINEAR_GRADIENT_SECOND, 1]]
      })
    }
    .width(CommonConstants.FULL_PERCENT)
  }
}