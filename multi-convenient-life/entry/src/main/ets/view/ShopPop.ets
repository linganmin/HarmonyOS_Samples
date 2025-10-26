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

import { ShopMenuData } from '../viewmodel/ShopDisplayViewModel';
import { BreakpointConstants } from '../constants/BreakpointConstants';
import { CommonConstants } from '../constants/CommonConstants';

@Component
export struct ShopPop {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @StorageLink('showPopUpChange') showPopUpChange: boolean = false;
  private shopMenuItem = new ShopMenuData().getMenuList()[0];

  build() {
    Column() {
      if (this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG) {
        Row() {
          Text($r('app.string.select_specification'))
            .fontSize($r('app.float.delicious_font'))
            .lineHeight($r('app.float.specification_line_height'))
            .fontWeight(CommonConstants.FONT_WEIGHT_700)
          Image($r('app.media.ic_public_close_pop'))
            .width($r('app.float.tx1_width'))
            .height($r('app.float.tx1_width'))
            .onClick(() => {
              this.showPopUpChange = false;
            })
        }
        .width(CommonConstants.FULL_PERCENT)
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({
          top: $r('app.float.margin_small'),
          bottom: $r('app.float.eight_padding')
        })
      }

      Row() {
        Image($r('app.media.MenuGoods1'))
          .width($r('app.float.goods_width'))
          .aspectRatio(1)
        Column() {
          Text(this.shopMenuItem.getDishName())
            .fontSize($r('app.float.food_data_font'))
            .fontWeight(CommonConstants.FONT_WEIGHT_700)
            .margin({
              bottom: $r('app.float.flag_margin_right')
            })
          Text(this.shopMenuItem.getDishTag())
            .fontSize($r('app.float.delivery_font'))
            .fontWeight(CommonConstants.FONT_WEIGHT_400)
            .fontColor($r('app.color.currency_symbol'))
            .margin({
              bottom: $r('app.float.flag_margin_right')
            })
          Text(this.shopMenuItem.getDishProfile())
            .fontSize($r('app.float.delivery_font'))
            .fontWeight(CommonConstants.FONT_WEIGHT_400)
            .fontColor($r('app.color.sixty_black'))
            .margin({
              bottom: $r('app.float.swiper_margin_bottom')
            })
          Row() {
            Text($r('app.string.currency_symbol'))
              .fontSize($r('app.float.add_cart_font'))
              .fontWeight(CommonConstants.FONT_WEIGHT_400)
              .margin({
                right: $r('app.float.back_margin_bottom')
              })
            Text(this.shopMenuItem.getDishPrice())
              .fontSize($r('app.float.plants_language_font'))
              .fontWeight(CommonConstants.FONT_WEIGHT_400)
              .margin({
                right: $r('app.float.price_margin_dish')
              })
            Text(CommonConstants.CURRENCY_SYMBOL + ' ' + this.shopMenuItem.getDishOriginalPrice())
              .fontSize($r('app.float.add_cart_font'))
              .fontWeight(CommonConstants.FONT_WEIGHT_400)
              .decoration({ type: TextDecorationType.LineThrough })
              .fontColor($r('app.color.forty_black'))
          }
          .width(CommonConstants.FULL_PERCENT)
        }
        .padding({
          left: $r('app.float.eight_padding')
        })
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .margin({
        bottom: $r('app.float.margin_small')
      })

      Row() {
        Text($r('app.string.count'))
          .fontSize($r('app.float.add_cart_font'))
          .fontWeight(CommonConstants.FONT_WEIGHT_700)
        Blank()
        Row() {
          Text($r('app.string.minuses'))
          TextInput({ text: '1' })
            .backgroundColor($r('app.color.five_white'))
            .width(CommonConstants.SELF_ADAPTING)
            .fontSize($r('app.float.delivery_font'))
            .fontWeight(CommonConstants.FONT_WEIGHT_400)
            .padding({
              top: $r('app.float.filtering_padding_tb'),
              bottom: $r('app.float.filtering_padding_tb'),
              right: $r('app.float.avatar_padding_left'),
              left: $r('app.float.avatar_padding_left')
            })
            .height($r('app.float.search_width'))
            .borderRadius(0)
            .margin({
              left: $r('app.float.flag_margin_right'),
              right: $r('app.float.flag_margin_right')
            })
          Text($r('app.string.add_symbol'))
        }
      }
      .width(CommonConstants.FULL_PERCENT)
      .margin({
        bottom: $r('app.float.margin_small')
      })

      Column() {
        Text($r('app.string.tastes'))
          .fontSize($r('app.float.add_cart_font'))
          .fontWeight(CommonConstants.FONT_WEIGHT_700)
          .alignSelf(ItemAlign.Start)
          .margin({
            bottom: $r('app.float.eight_padding')
          })
        Row() {
          Text($r('app.string.not_spicy'))
            .width(CommonConstants.TWENTY_FOUR_PERCENT)
            .fontSize($r('app.float.delivery_font'))
            .height($r('app.float.food_padding_left'))
            .textAlign(TextAlign.Center)
            .borderColor($r('app.color.swiper_choose_background'))
            .borderWidth(1)
            .borderStyle(BorderStyle.Solid)
            .borderRadius($r('app.float.text_margin_bottom'))
        }
        .width(CommonConstants.FULL_PERCENT)
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .margin({
        bottom: $r('app.float.margin_small')
      })

      Text($r('app.string.chosen'))
        .fontColor(Color.White)
        .fontWeight(CommonConstants.FONT_WEIGHT_700)
        .fontSize($r('app.float.reviews_font'))
        .textAlign(TextAlign.Center)
        .width(CommonConstants.FULL_PERCENT)
        .backgroundColor($r('app.color.currency_symbol'))
        .borderRadius($r('app.float.line_height'))
        .height($r('app.float.tx2_width'))
    }
    .padding({
      left: $r('app.float.padding_small'),
      right: $r('app.float.padding_small'),
      bottom: $r('app.float.padding_small')
    })
  }
}