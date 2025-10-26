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

import { CommonConstants } from '../../common/constants/CommonConstants';
import { ResourceUtil } from '../../common/utils/ResourceUtil';
import { ShoppingBagConstants } from '../../common/constants/ShoppingBagConstants';
import { ShoppingBagListViewModel, ShoppingBagProduct } from '../../viewmodel/ShoppingBagListViewModel';

@Component
export struct ShoppingCardItem {
  @LocalStorageLink('payArray') payArray: Array<boolean> = [false, false, false, false];
  @Prop isPay: boolean;
  private shoppingBagProductItem: ShoppingBagProduct = new ShoppingBagListViewModel().getShoppingBagItemData()[2];
  private titleEllipsis?: boolean;

  build() {
    Row() {
      Column() {
        Row() {
          Image(this.shoppingBagProductItem.getImage())
            .width(ResourceUtil.getCommonImgSize()[7])
            .height(ResourceUtil.getCommonImgSize()[7])
            .border({
              radius: ResourceUtil.getCommonBorderRadius()[3]
            });

          Column() {
            Row() {
              Text(this.shoppingBagProductItem.getName())
                .fontSize($r('app.float.card_item_font_1'))
                .fontWeight(FontWeight.Normal)
                .textOverflow({
                  overflow: TextOverflow.Ellipsis
                })
                .maxLines(this.titleEllipsis === true ? 1 : 2);
            }
            .margin({
              bottom: $r('app.float.card_item_name_margin')
            });

            Row() {
              Text(this.isPay ? ShoppingBagConstants.SHOPPING_PAID : ShoppingBagConstants.SHOPPING_UNPAID)
                .border({
                  color: this.isPay ? $r('app.color.product_font_color_2') :
                  $r('app.color.shop_card_gray_color'),
                  radius: ResourceUtil.getCommonBorderRadius()[1],
                  width: 1
                })
                .fontSize($r('app.float.card_item_font_2'))
                .fontColor(this.isPay ? $r('app.color.product_font_color_2') :
                $r('app.color.shop_card_gray_color'))
                .padding({
                  top: $r('app.float.card_preferential_padding_top'),
                  bottom: $r('app.float.card_preferential_padding_top'),
                  left: $r('app.float.card_preferential_padding_left'),
                  right: $r('app.float.card_preferential_padding_left')
                })
                .margin({ right: $r('app.float.card_preferential_margin') });
            }
            .margin({ bottom: $r('app.float.card_preferential_row_margin') });

            Flex({
              direction: FlexDirection.Row,
              alignItems: ItemAlign.Center,
              wrap: FlexWrap.Wrap
            }) {
              Row() {
                Text(ShoppingBagConstants.SHOPPING_CARD_NAMES[0])
                  .font({
                    size: $r('app.float.card_item_font_3'),
                    weight: CommonConstants.FONT_WEIGHT_500
                  });
                Text(JSON.stringify(this.shoppingBagProductItem.getPrice()))
                  .font({
                    size: $r('app.float.card_item_font_4'),
                    weight: CommonConstants.FONT_WEIGHT_500
                  })
                  .margin({
                    right: $r('app.float.card_price_margin')
                  });
              };

              Blank();
              Row() {
                this.addButton(ShoppingBagConstants.SHOPPING_CARD_NAMES[1]);
                Text(ShoppingBagConstants.SHOPPING_CARD_NAMES[2])
                  .fontSize($r('app.float.card_number_font'))
                  .width($r('app.float.card_number_width'))
                  .margin({
                    left: $r('app.float.card_number_margin'),
                    right: $r('app.float.card_number_margin')
                  })
                  .textAlign(TextAlign.Center);
                this.addButton(ShoppingBagConstants.SHOPPING_CARD_NAMES[3]);
              };
            }
            .width(CommonConstants.FULL_PERCENT);
          }
          .padding({
            left: $r('app.float.card_item_col_padding'),
            bottom: $r('app.float.card_item_col_padding')
          })
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start);
        };
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1);
    }
    .width(CommonConstants.FULL_PERCENT);
  }

  @Builder
  addButton(buttonText: string) {
    Text(buttonText)
      .width($r('app.float.add_button_size'))
      .height($r('app.float.add_button_size'))
      .border({
        radius: ResourceUtil.getCommonBorderRadius()[4],
        width: $r('app.float.add_button_border_width'),
        color: $r('app.color.add_button_border')
      })
      .fontColor($r('app.color.add_button_border'))
      .textAlign(TextAlign.Center);
  }
}