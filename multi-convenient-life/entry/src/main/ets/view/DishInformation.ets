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
import { BreakpointType } from '../utils/BreakpointType';
import { DishDetailConstants } from '../constants/DishDetailConstants';
import { CommonConstants } from '../constants/CommonConstants';

@Component
export struct DishHead {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @Consume('shopPageInfo') shopPageInfo: NavPathStack;
  @Consume('ifShowSides') ifShowSides: boolean;
  @Consume('ifShowShopDisplay') ifShowShopDisplay: boolean;
  // [Start listen_if_picture_expansion]
  @Link @Watch('resizeImage') ifPictureExpansion: Boolean;
  @Link imageHeightExtension: number;
  @Link imageHeightFold: number;
  @Link imageHeight: number;
  @State @Watch('resizeImage') imageRatio: number = 0;
  @State @Watch('resizeImage') imageWidth: number = 0;

  resizeImage(): void {
    this.imageHeightExtension = this.imageWidth * this.imageRatio;
    this.imageHeightFold = Math.min(380, this.imageHeightExtension);
    if (this.ifPictureExpansion) {
      this.imageHeight = this.imageHeightExtension;
    } else {
      this.imageHeight = this.imageHeightFold;
    }
  }

  build() {
    Column() {
      Stack({
        alignContent: Alignment.TopStart
      }) {
        Image($r('app.media.merchandiseMap'))
          .width(CommonConstants.FULL_PERCENT)
          .height(this.imageHeight)
          .objectFit(ImageFit.Cover)
          .animation({
            duration: 250,
            curve: Curve.EaseOut,
            iterations: 1,
            playMode: PlayMode.Normal
          })
          .onComplete((msg) => {
            this.imageRatio = msg!.height / msg!.width;
          })
          .onAreaChange((oldArea: Area, newArea: Area) => {
            this.imageWidth = Number.parseInt(JSON.stringify(newArea.width));
            if (!this.ifPictureExpansion) {
              this.imageHeight = this.imageHeightFold;
            } else {
              this.imageHeight = this.imageHeightExtension;
            }
          })
        // [StartExclude listen_if_picture_expansion]
        Image($r('app.media.icon_back_white'))
          .width($r('app.float.common_image'))
          .aspectRatio(1)
          .margin({
            left: this.ifShowSides ? new BreakpointType($r('app.float.margin_small'), $r('app.float.margin_small'),
              $r('app.float.common_margin')).getValue(this.currentBreakpoint) :
            new BreakpointType($r('app.float.margin_small'), $r('app.float.common_margin'),
              $r('app.float.common_margin')).getValue(this.currentBreakpoint),
            top: $r('app.float.back_dish_margin')
          })
          .onClick(() => {
            this.shopPageInfo.pop();
            this.ifShowShopDisplay = true;
          })

        Image($r('app.media.ic_public_enlarge_white'))
          .width($r('app.float.common_image'))
          .aspectRatio(1)
          .margin({
            left: this.ifShowSides ?
            new BreakpointType($r('app.float.zero_margin'), $r('app.float.enlarge_dish_margin_left'),
              $r('app.float.enlarge_margin')).getValue(this.currentBreakpoint) :
            new BreakpointType($r('app.float.zero_margin'), $r('app.float.enlarge_margin'),
              $r('app.float.enlarge_margin')).getValue(this.currentBreakpoint),
            top: $r('app.float.back_dish_margin')
          })
          .onClick(() => {
            this.ifShowSides = false;
          })
          .visibility(this.ifShowSides && this.currentBreakpoint !== BreakpointConstants.BREAKPOINT_SM ?
          Visibility.Visible : Visibility.None)

        Image($r('app.media.ic_public_reduce_white'))
          .width($r('app.float.common_image'))
          .aspectRatio(1)
          .margin({
            left: this.ifShowSides ?
            new BreakpointType($r('app.float.zero_margin'), $r('app.float.enlarge_dish_margin_left'),
              $r('app.float.enlarge_margin')).getValue(this.currentBreakpoint) :
            new BreakpointType($r('app.float.zero_margin'), $r('app.float.enlarge_margin'),
              $r('app.float.enlarge_margin')).getValue(this.currentBreakpoint),
            top: $r('app.float.back_dish_margin')
          })
          .onClick(() => {
            this.ifShowSides = true;
          })
          .visibility(!this.ifShowSides && this.currentBreakpoint !== BreakpointConstants.BREAKPOINT_SM ?
          Visibility.Visible : Visibility.None)
        // [EndExclude listen_if_picture_expansion]
      }

      // [StartExclude listen_if_picture_expansion]
      Column() {
        DishMainInformation({ largeMode: false })
      }
      .margin({
        left: this.ifShowSides ? new BreakpointType($r('app.float.margin_small'), $r('app.float.margin_small'),
          $r('app.float.common_margin')).getValue(this.currentBreakpoint) :
        new BreakpointType($r('app.float.margin_small'), $r('app.float.common_margin'),
          $r('app.float.common_margin')).getValue(this.currentBreakpoint),
        right: this.ifShowSides ? new BreakpointType($r('app.float.margin_small'), $r('app.float.margin_small'),
          $r('app.float.common_margin')).getValue(this.currentBreakpoint) :
        new BreakpointType($r('app.float.margin_small'), $r('app.float.common_margin'),
          $r('app.float.common_margin')).getValue(this.currentBreakpoint),
        top: $r('app.float.margin_twelves')
      })
      .padding($r('app.float.twelves_padding'))
      .backgroundColor(Color.White)
      .borderRadius($r('app.float.dish_border'))

      // [EndExclude listen_if_picture_expansion]
    }
    // [StartExclude listen_if_picture_expansion]
    .margin({
      bottom: $r('app.float.margin_twelves')
    })

    // [EndExclude listen_if_picture_expansion]
  }

  // [End listen_if_picture_expansion]
}

@Component
export struct DishSideBar {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @StorageLink('windowTop') windowTop: number = 0;
  @StorageLink('windowBottom') windowBottom: number = 0;
  @Consume('shopPageInfo') shopPageInfo: NavPathStack;
  @Consume('ifShowSides') ifShowSides: boolean;
  @Consume('ifShowShopDisplay') ifShowShopDisplay: boolean;

  build() {
    Column() {
      Row() {
        Image($r('app.media.icon_back'))
          .width($r('app.float.common_image'))
          .aspectRatio(1)
          .margin({
            right: $r('app.float.back_image_right')
          })
          .onClick(() => {
            this.shopPageInfo.pop();
          })
        Image($r('app.media.ic_public_reduce'))
          .width($r('app.float.common_image'))
          .aspectRatio(1)
          .onClick(() => {
            this.ifShowSides = true;
          })
      }
      .margin({
        bottom: $r('app.float.back_margin_bottom'),
        top: this.windowTop
      })
      .justifyContent(FlexAlign.Start)
      .width(CommonConstants.EIGHTY_THREE_PERCENT)

      Image($r('app.media.merchandiseMap'))
        .objectFit(ImageFit.Cover)
        .borderRadius($r('app.float.merchandise_border'))
        .width(CommonConstants.EIGHTY_THREE_PERCENT)
        .flexGrow(1)
        .linearGradient({
          angle: CommonConstants.ANGLE_IMAGE,
          colors: [
            [CommonConstants.LINEAR_GRADIENT_FIRST, CommonConstants.LINEAR_GRADIENT_INDEX],
            [CommonConstants.LINEAR_GRADIENT_SECOND, 1]
          ]
        })

      Row() {
        DishMainInformation({ largeMode: true })
      }
      .flexGrow(0)
      .flexShrink(0)
      .width(CommonConstants.EIGHTY_THREE_PERCENT)
      .padding({
        top: $r('app.float.twelves_padding'),
        bottom: $r('app.float.merchandise_bottom')
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }
}

@Component
export struct DishMainInformation {
  @Prop largeMode: boolean;

  build() {
    Column() {
      Row() {
        Text($r('app.string.delicious_fried'))
          .fontSize(this.largeMode ? $r('app.float.fried_font') : $r('app.float.delicious_font'))
          .fontWeight(CommonConstants.FONT_WEIGHT_700)
          .layoutWeight(1)
        Blank()
        Column() {
          Image($r('app.media.icon_collection'))
            .width($r('app.float.more_width'))
          Text($r('app.string.collections_text'))
            .fontColor($r('app.color.sixty_black'))
            .fontSize($r('app.float.delivery_font'))
        }
      }
      .alignSelf(ItemAlign.Center)
      .width(CommonConstants.FULL_PERCENT)
      .margin({
        bottom: this.largeMode ? $r('app.float.margin_twelves') : $r('app.float.margin_food')
      })

      Row() {
        ForEach(DishDetailConstants.PRODUCT_TAG_LIST, (item: string) => {
          Text(item)
            .backgroundColor('#1aed6f21')
            .fontColor($r('app.color.currency_symbol'))
            .fontSize($r('app.float.filtering_font'))
            .padding({
              top: $r('app.float.filtering_padding_tb'),
              bottom: $r('app.float.filtering_padding_tb'),
              left: $r('app.float.filtering_padding_lr'),
              right: $r('app.float.filtering_padding_lr')
            })
            .margin({
              right: $r('app.float.dish_margin_right')
            })
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .margin({
        bottom: $r('app.float.margin_twelves')
      })

      Text($r('app.string.monthly_sales'))
        .fontColor($r('app.color.sixty_black'))
        .fontSize($r('app.float.delivery_font'))
        .margin({
          bottom: $r('app.float.margin_twelves')
        })
        .alignSelf(ItemAlign.Start)
      Row() {
        Row() {
          Text($r('app.string.currency_symbol'))
            .fontColor($r('app.color.currency_symbol'))
            .fontSize(this.largeMode ? $r('app.float.currency_symbol') : $r('app.float.delivery_font'))
            .margin({
              right: $r('app.float.currency_symbol_margin_right')
            })
          Text($r('app.string.pay_price'))
            .fontColor($r('app.color.currency_symbol'))
            .fontSize(this.largeMode ? $r('app.float.pay_price_font') : $r('app.float.currency_symbol'))
            .fontWeight(CommonConstants.FONT_WEIGHT_700)
            .margin({
              right: $r('app.float.pay_price_margin_right')
            })
          Text($r('app.string.original_price'))
            .fontColor($r('app.color.forty_black'))
            .fontSize(this.largeMode ? $r('app.float.amounts_font') : $r('app.float.filtering_font'))
            .fontWeight(CommonConstants.FONT_WEIGHT_400)
            .decoration({ type: TextDecorationType.LineThrough, color: $r('app.color.forty_black') })
        }
        .alignItems(VerticalAlign.Bottom)

        Blank()
        Text($r('app.string.add_cart'))
          .backgroundColor($r('app.color.currency_symbol'))
          .fontSize($r('app.float.add_cart_font'))
          .fontWeight(CommonConstants.FONT_WEIGHT_700)
          .fontColor(Color.White)
          .width($r('app.float.add_cart_width'))
          .height($r('app.float.add_cart_height'))
          .borderRadius($r('app.float.add_cart_border'))
          .textAlign(TextAlign.Center)
      }
      .width(CommonConstants.FULL_PERCENT)
    }
  }
}