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

import { deviceInfo } from '@kit.BasicServicesKit';
import { BreakpointConstants } from '../../common/constants/BreakpointConstants';
import { CommonConstants } from '../../common/constants/CommonConstants';
import { ResourceUtil } from '../../common/utils/ResourceUtil';
import { ShoppingCardItem } from './ShoppingCardItem';
import {
  PreferenceDetails,
  PreferenceDetailsList,
  ShoppingBagListViewModel,
  ShoppingBagProduct
} from '../../viewmodel/ShoppingBagListViewModel';
import { ShoppingCardFoot } from './ShoppingCardFoot';
import { ShoppingBagConstants } from '../../common/constants/ShoppingBagConstants';

@Component
export struct ShoppingBagDiscounts {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @StorageLink('topRectHeight') topRectHeight: number = 0;
  private ShoppingBagList: ShoppingBagProduct[] = new ShoppingBagListViewModel().getShoppingBagItemData();
  private PreferenceDetailsList: PreferenceDetails[] = new PreferenceDetailsList().getPreferenceDetailsList();
  private ShoppingBagProductItem: ShoppingBagProduct = this.ShoppingBagList[2];

  build() {
    Column() {
      Scroll() {
        Column() {
          Text(ShoppingBagConstants.SHOPPING_DISCOUNT_TITLES[0])
            .fontSize($r('app.float.bag_discount_font_1'))
            .fontWeight(CommonConstants.FONT_WEIGHT_500)
            .lineHeight($r('app.float.bag_discount_line_1'));
          Text(ShoppingBagConstants.SHOPPING_DISCOUNT_TITLES[1])
            .fontSize($r('app.float.bag_discount_font_2'))
            .lineHeight($r('app.float.bag_discount_line_2'))
            .fontWeight(FontWeight.Normal)
            .padding({
              top: $r('app.float.bag_discount_title_padding_top'),
              bottom: $r('app.float.bag_discount_title_padding_bottom')
            });

          Column() {
            ShoppingCardItem({
              shoppingBagProductItem: this.ShoppingBagProductItem,
              titleEllipsis: true
            });
            Row() {
              Text(ShoppingBagConstants.SHOPPING_DISCOUNT_TITLES[2])
                .fontSize($r('app.float.bag_discount_font_3'))
                .fontColor($r('app.color.product_font_color_2'))
                .fontWeight(CommonConstants.FONT_WEIGHT_500);
              Blank();
              Text(ShoppingBagConstants.SHOPPING_DISCOUNT_TITLES[3])
                .fontSize($r('app.float.bag_discount_font_2'))
                .fontWeight(FontWeight.Normal);
            }
            .height($r('app.float.bag_discount_row_height'))
            .width(CommonConstants.FULL_PERCENT)
            .justifyContent(FlexAlign.Center);

            Row() {
              Text(ShoppingBagConstants.SHOPPING_DISCOUNT_TITLES[4])
                .fontSize($r('app.float.bag_discount_font_3'))
                .fontWeight(CommonConstants.FONT_WEIGHT_500);
              Blank();
              Text(ShoppingBagConstants.SHOPPING_DISCOUNT_TITLES[5])
                .fontSize($r('app.float.bag_discount_font_2'))
                .fontWeight(FontWeight.Normal);
              Image($r('app.media.ic_public_more_list'))
                .height(ResourceUtil.getCommonImgSize()[0])
                .width(ResourceUtil.getCommonImgSize()[0]);
            }
            .justifyContent(FlexAlign.Center)
            .height($r('app.float.bag_discount_row_height'))
            .width(CommonConstants.FULL_PERCENT);
          }
          .backgroundColor($r('app.color.shopping_background_color_1'))
          .padding($r('app.float.bag_discount_padding'))
          .border({ radius: ResourceUtil.getCommonBorderRadius()[6] })
          .margin({ bottom: $r('app.float.bag_discount_margin') });

          Column() {
            ForEach(this.PreferenceDetailsList, (item: PreferenceDetails) => {
              Row() {
                Text(item.getTitle())
                  .fontSize($r('app.float.bag_discount_font_3'))
                  .fontWeight(FontWeight.Normal);
                Blank();
                Text(item.getPrice())
                  .fontSize($r('app.float.bag_discount_font_2'))
                  .fontColor($r('app.color.product_font_color_2'));
              }
              .justifyContent(FlexAlign.Center)
              .height($r('app.float.bag_discount_row_height'))
              .width(CommonConstants.FULL_PERCENT);
            }, (item: PreferenceDetails, index: number) => JSON.stringify(item) + index);
          }
          .backgroundColor($r('app.color.shopping_background_color_1'))
          .padding($r('app.float.bag_discount_padding'))
          .border({ radius: ResourceUtil.getCommonBorderRadius()[6] });
        }
        .width(CommonConstants.FULL_PERCENT)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
        .padding({
          left: ResourceUtil.getPageColPadding().getValue(this.currentBreakpoint),
          right: ResourceUtil.getPageColPadding().getValue(this.currentBreakpoint),
          top: deviceInfo.deviceType === CommonConstants.DEVICE_TYPES[0] ?
          $r('app.float.bag_discount_col_padding_bottom') : this.topRectHeight
        });

      }
      .width(CommonConstants.FULL_PERCENT)
      .scrollBarWidth(0)
      .layoutWeight(1)
      .backgroundColor(ResourceUtil.getCommonBackgroundColor()[0]);

      ShoppingCardFoot({ isMoreDetail: true })
        .margin({
          bottom: deviceInfo.deviceType !== CommonConstants.DEVICE_TYPES[0] ?
          CommonConstants.BOTTOM_RECT_HEIGHT : 0
        });
    }
    .backgroundColor($r('app.color.common_background_1'))
    .layoutWeight(ShoppingBagConstants.SHOPPING_BAG_LAYOUT_WEIGHTS[1])
    .height(CommonConstants.FULL_PERCENT)
    .visibility(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ? Visibility.Visible : Visibility.None);
  }
}