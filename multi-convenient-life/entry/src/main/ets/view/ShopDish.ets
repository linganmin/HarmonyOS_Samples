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
import { CommonConstants } from '../constants/CommonConstants';
import { ShopMenuItem } from '../viewmodel/ShopDisplayViewModel';
import { ShopPop } from './ShopPop';

@Component
export struct ShopDish {
  @StorageLink('currentBreakpoint') @Watch('screenChange') currentBreakpoint: string =
    BreakpointConstants.BREAKPOINT_LG;
  @StorageLink('showPopUpChange') @Watch('popUpChange') showPopUpChange: boolean = false;
  @Consume('shopPageInfo') shopPageInfo: NavPathStack;
  @Consume('ifShowShopDisplay') ifShowShopDisplay: boolean;
  @Prop shopMenuItem: ShopMenuItem;
  @Prop showSelectButton: boolean;
  @State showPop: boolean = false;
  @State showPopUp: boolean = false;

  screenChange() {
    if (this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG) {
      this.showPop = false;
    }
  }

  popUpChange() {
    if (!this.showPopUpChange) {
      this.showPopUp = false;
    }
  }

  @Builder
  popBuilder() {
    Column() {
      ShopPop();
    }
  }

  build() {
    Row() {
      Image(this.shopMenuItem.getDishImage())
        .width($r('app.float.goods_width'))
        .aspectRatio(1)
      Column() {
        Text(this.shopMenuItem.getDishName())
          .fontSize($r('app.float.food_data_font'))
          .fontWeight(CommonConstants.FONT_WEIGHT_700)
          .margin({
            bottom: $r('app.float.favor_bottom')
          })
        Text(this.shopMenuItem.getDishTag())
          .fontSize($r('app.float.delivery_font'))
          .fontWeight(CommonConstants.FONT_WEIGHT_400)
          .fontColor($r('app.color.currency_symbol'))
          .margin({
            bottom: $r('app.float.favor_bottom')
          })
        Text(this.shopMenuItem.getDishProfile())
          .fontSize($r('app.float.delivery_font'))
          .fontWeight(CommonConstants.FONT_WEIGHT_400)
          .fontColor($r('app.color.sixty_black'))
          .margin({
            bottom: $r('app.float.profile_margin_bottom')
          })
        Row() {
          Text($r('app.string.currency_symbol'))
            .fontSize($r('app.float.add_cart_font'))
            .fontWeight(CommonConstants.FONT_WEIGHT_400)
            .margin({
              right: $r('app.float.filtering_padding_lr')
            })
          Text(this.shopMenuItem.getDishPrice())
            .fontSize($r('app.float.price_font'))
            .fontWeight(CommonConstants.FONT_WEIGHT_400)
            .margin({
              right: $r('app.float.price_margin_dish')
            })
          Text(CommonConstants.CURRENCY_SYMBOL + ' ' + this.shopMenuItem.getDishOriginalPrice())
            .fontSize($r('app.float.add_cart_font'))
            .fontWeight(CommonConstants.FONT_WEIGHT_400)
            .decoration({
              type: TextDecorationType.LineThrough,
              color: $r('app.color.forty_black')
            })
            .fontColor($r('app.color.forty_black'))
          Blank()
          // [Start bind_sheet_jump]
          Text($r('app.string.select_specification'))
          // [StartExclude bind_sheet_jump]
            .fontSize($r('app.float.delivery_font'))
            .fontWeight(CommonConstants.FONT_WEIGHT_400)
            .fontColor(Color.White)
            .backgroundColor($r('app.color.currency_symbol'))
            .borderRadius($r('app.float.text_radius'))
            .padding({
              top: $r('app.float.back_margin_bottom'),
              bottom: $r('app.float.back_margin_bottom'),
              left: $r('app.float.filtering_margin_right'),
              right: $r('app.float.filtering_margin_right')
            })
            .visibility(this.showSelectButton && this.shopMenuItem.getDishAddOrChoice() === 1 ?
            Visibility.Visible : Visibility.None)
            // [EndExclude bind_sheet_jump]
            .onClick(() => {
              if (this.currentBreakpoint !== BreakpointConstants.BREAKPOINT_LG) {
                this.showPop = true;
              } else {
                this.showPopUp = true;
                this.showPopUpChange = true;
              }
            })
            .bindSheet($$this.showPop, this.popBuilder(), {
              height: SheetSize.FIT_CONTENT,
              backgroundColor: Color.White,
              title: {
                title: $r('app.string.select_specification')
              },
              maskColor: $r('app.color.forty_black')
            })
            .bindPopup(this.showPopUp, {
              builder: this.popBuilder,
              placement: Placement.Left,
              width: $r('app.float.popup_width'),
              mask: { color: $r('app.color.forty_black') },
              onStateChange: (e) => {
                if (!e.isVisible) {
                  this.showPopUp = false;
                }
              }
            })
          // [End bind_sheet_jump]
          Text($r('app.string.add_symbol'))
            .fontSize($r('app.float.delivery_font'))
            .fontWeight(CommonConstants.FONT_WEIGHT_400)
            .fontColor(Color.White)
            .backgroundColor($r('app.color.currency_symbol'))
            .borderRadius($r('app.float.nine_radius'))
            .width($r('app.float.search_width'))
            .height($r('app.float.search_width'))
            .textAlign(TextAlign.Center)
            .visibility(this.showSelectButton && this.shopMenuItem.getDishAddOrChoice() === 0 ?
            Visibility.Visible : Visibility.None)
        }
        .width(CommonConstants.FULL_PERCENT)
      }
      .padding({
        left: $r('app.float.back_image_right')
      })
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

    }
    .onClick(() => {
      this.shopPageInfo.pushPath({ name: CommonConstants.DEFAULT_ROUTE }, false)
      this.ifShowShopDisplay = false
    })
    .margin({
      bottom: $r('app.float.margin_twelves')
    })
    .width(CommonConstants.FULL_PERCENT)

  }
}