/*
 *   Copyright (c) 2024 Huawei Device Co., Ltd.
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 */

import { HMRouterMgr } from '@hadss/hmrouter';
import { BreakpointConstants } from '../../common/constants/BreakpointConstants';
import { CommonConstants } from '../../common/constants/CommonConstants';
import { ResourceUtil } from '../../common/utils/ResourceUtil';
import { ShoppingBagConstants } from '../../common/constants/ShoppingBagConstants';
import { DetailConstants } from '../../common/constants/DetailConstants';

@Component
export struct ShoppingCardFoot {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @LocalStorageLink('totalPrice') totalPrice: number = 0;
  @LocalStorageLink('selectArray') selectArray: Array<boolean> = [false, true, false, false];
  @LocalStorageLink('payArray') payArray: Array<boolean> = [false, false, false, false];
  @LocalStorageLink('isAllSelected') isAllSelected: boolean = false;
  private isMoreDetail: boolean = false;

  isHidden() {
    return this.payArray.every((item) => {
      return item;
    });
  }

  getSelectNum(): number {
    let count = 0;
    this.payArray.forEach((item, index) => {
      if (!item && this.selectArray[index]) {
        count++;
      }
    });
    return count;
  }

  build() {
    Row() {
      Row() {
        Checkbox()
          .selectedColor($r('app.color.classify_indicator_selected_color'))
          .width($r('app.float.check_box_size'))
          .height($r('app.float.check_box_size'))
          .margin({
            right: $r('app.float.shop_card_check_margin'),
            left: 0
          })
          .border({
            color: ResourceUtil.getCommonBorderColor()[2]
          })
          .shape(CheckBoxShape.ROUNDED_SQUARE)
          .select(this.isAllSelected)
          .onClick(() => {
            this.isAllSelected = !this.isAllSelected;
            if (this.isAllSelected) {
              for (let i = 0; i < this.payArray.length; i++) {
                if (!this.payArray[i]) {
                  this.selectArray[i] = true;
                }
              }
            } else {
              this.selectArray = [false, false, false, false];
            }
          });
        Text(ShoppingBagConstants.SHOPPING_CARD_FOOT_TITLES[0])
          .fontSize($r('app.float.shop_card_font_1'))
          .lineHeight($r('app.float.shop_card_line_1'))
          .fontWeight(FontWeight.Normal);
      }
      .height(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.Start)
      .visibility(this.isHidden() ? Visibility.Hidden : Visibility.Visible);

      Blank();

      Row() {
        Row() {
          Text(ShoppingBagConstants.SHOPPING_CARD_FOOT_TITLES[1])
            .fontSize($r('app.float.shop_card_font_1'))
            .lineHeight($r('app.float.shop_card_line_1'));
          Text(ShoppingBagConstants.SHOPPING_CARD_FOOT_TITLES[2])
            .fontSize($r('app.float.shop_card_font_1'))
            .lineHeight($r('app.float.shop_card_line_2'))
            .fontColor($r('app.color.product_font_color_2'));
          Text(this.totalPrice.toString())
            .fontSize($r('app.float.shop_card_font_2'))
            .lineHeight($r('app.float.shop_card_line_3'))
            .fontColor($r('app.color.product_font_color_2'));
        };

        Button(ShoppingBagConstants.SHOPPING_SETTLEMENT_BUTTON + '(' + this.getSelectNum() + ')',
          { type: ButtonType.Capsule, stateEffect: true })
          .labelStyle({
            font: {
              size: $r('app.float.shop_card_font_2')
            }
          })
          .backgroundColor($r('app.color.shop_card_foot_button'))
          .height($r('app.float.foot_button_height'))
          .width($r('app.float.foot_button_width'))
          .margin({
            left: $r('app.float.foot_button_margin')
          })
          .onClick(() => {
            if (this.totalPrice) {
              HMRouterMgr.to('PayDialogContent')
                .withNavigation('mainNavigationId')
                .withParam({ totalPrice: this.totalPrice, pageUrl: 'shoppingBag' })
                .onResult((info) => {
                  if (info.result === DetailConstants.PAY_INFO[4]) {
                    this.totalPrice = 0;
                    for (let i = 0; i < this.selectArray.length; i++) {
                      if (this.selectArray[i]) {
                        this.payArray[i] = true;
                        this.selectArray[i] = false;
                      }
                    }
                  }
                })
                .pushAsync()
            }
          })
          .id('payWithVoucher');
      }
      .height(CommonConstants.FULL_PERCENT)
      .alignItems(VerticalAlign.Center);
    }
    .justifyContent(FlexAlign.Start)
    .width(CommonConstants.FULL_PERCENT)
    .height($r('app.float.foot_height'))
    .padding({
      left: this.isMoreDetail ? $r('app.float.foot_padding_more') : 0,
      right: this.isMoreDetail ? $r('app.float.foot_padding_more') : 0
    });
  }
}