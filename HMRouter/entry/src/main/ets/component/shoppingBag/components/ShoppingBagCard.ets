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
import { CommonConstants } from '../../common/constants/CommonConstants';
import { ShoppingBagConstants } from '../../common/constants/ShoppingBagConstants';
import { ResourceUtil } from '../../common/utils/ResourceUtil';
import { ShoppingBagListViewModel, ShoppingBagProduct } from '../../viewmodel/ShoppingBagListViewModel';
import { ShoppingNavModifier } from '../ShoppingNavModifier';
import { ShoppingCardItem } from './ShoppingCardItem';

@Component
export struct ShoppingBagCard {
  @LocalStorageLink('totalPrice') totalPrice: number = 0;
  @LocalStorageLink('selectArray') selectArray: Array<boolean> = [false, false, false, false];
  @LocalStorageLink('payArray') payArray: Array<boolean> = [false, false, false, false];
  @LocalStorageLink('isAllSelected') isAllSelected: boolean = false;
  @Consume('ShoppingNavModifier') modifier: ShoppingNavModifier;
  private ShoppingBagList: ShoppingBagProduct[] = new ShoppingBagListViewModel().getShoppingBagItemData();

  isHidden() {
    return this.payArray.every((item) => {
      return item;
    });
  }

  setAllSelected() {
    this.isAllSelected = this.payArray.every((item, index) => {
      return item || (!item && this.selectArray[index]);
    });
  }

  build() {
    Scroll() {
      Column() {
        Row() {
          CheckboxGroup({ group: 'shoppingCardHuaWei' })
            .selectedColor($r('app.color.classify_indicator_selected_color'))
            .checkboxShape(CheckBoxShape.ROUNDED_SQUARE)
            .width($r('app.float.check_box_size'))
            .height($r('app.float.check_box_size'))
            .margin({ right: $r('app.float.check_box_group_margin') })
            .border({ color: ResourceUtil.getCommonBorderColor()[2] })
            .visibility(this.isHidden() ? Visibility.Hidden : Visibility.Visible);

          Image($r('app.media.shopping_card_logo'))
            .width(ResourceUtil.getCommonImgSize()[0])
            .height(ResourceUtil.getCommonImgSize()[0])
            .margin({ right: $r('app.float.bag_seller_logo_margin') })
            .border({
              radius: ResourceUtil.getCommonBorderRadius()[4],
              width: $r('app.float.bag_seller_logo_border_width'),
              color: ResourceUtil.getCommonBorderColor()[3]
            });

          Text(ShoppingBagConstants.SHOPPING_BAG_TITLES[2])
            .font({
              size: $r('app.float.bag_name_font'),
              weight: CommonConstants.FONT_WEIGHT_500
            })
            .layoutWeight(1);
        }
        .height($r('app.float.bag_card_title_row_height'))
        .width(CommonConstants.FULL_PERCENT);

        List() {
          ForEach(this.ShoppingBagList, (item: ShoppingBagProduct, index: number) => {
            ListItem() {
              Row() {
                Column() {
                  Checkbox({ group: 'shoppingCardHuaWei' })
                    .selectedColor($r('app.color.classify_indicator_selected_color'))
                    .width($r('app.float.check_box_size'))
                    .height($r('app.float.check_box_size'))
                    .margin({
                      right: $r('app.float.bag_card_check_box_margin'),
                      left: 0
                    })
                    .border({
                      color: ResourceUtil.getCommonBorderColor()[2]
                    })
                    .shape(CheckBoxShape.ROUNDED_SQUARE)
                    .select(this.selectArray[index])
                    .onChange((value: boolean) => {
                      this.selectArray[index] = value;
                      if (value) {
                        if (!this.payArray[index]) {
                          this.totalPrice += ShoppingBagConstants.PRODUCT_PRICE_LIST[index];
                        }
                      } else {
                        if (!this.payArray[index]) {
                          this.totalPrice -= ShoppingBagConstants.PRODUCT_PRICE_LIST[index];
                        }
                      }
                      this.setAllSelected();
                    })
                    .visibility(this.payArray[index] ? Visibility.Hidden : Visibility.Visible)
                    .id(item.getName());
                }
                .width($r('app.float.bag_card_check_col_width'))
                .justifyContent(FlexAlign.Center);

                ShoppingCardItem({
                  shoppingBagProductItem: item,
                  titleEllipsis: false,
                  isPay: this.payArray[index]
                })
                  .layoutWeight(1);
              }
              .width(CommonConstants.FULL_PERCENT)
              .padding({
                top: $r('app.float.bag_card_row_padding'),
                bottom: $r('app.float.bag_card_row_padding')
              });
            };
          }, (item: ShoppingBagProduct, index: number) => JSON.stringify(item) + index);
        }
        .onClick(() => {
          this.modifier.attribute?.mode(NavigationMode.Auto);
          setTimeout(() => {
            HMRouterMgr.getPathStack(this.queryNavigationInfo()!.navigationId)?.pushPath({
              name: 'ProductContent'
            }, {
              launchMode: LaunchMode.MOVE_TO_TOP_SINGLETON
            });
          }, 20);

        })
        .scrollBar(BarState.Off)
        .id('productList')
        .width('auto')
        .height('auto');
      }
      .width(CommonConstants.FULL_PERCENT)
      .backgroundColor($r('app.color.shopping_background_color_1'))
      .borderRadius(ResourceUtil.getCommonBorderRadius()[7])
      .padding($r('app.float.bag_card_col_padding'))
      .margin({ bottom: CommonConstants.BOTTOM_RECT_HEIGHT });
    }
    .scrollBar(BarState.Off)
    .layoutWeight(1)
    .width(CommonConstants.FULL_PERCENT);
  }
}