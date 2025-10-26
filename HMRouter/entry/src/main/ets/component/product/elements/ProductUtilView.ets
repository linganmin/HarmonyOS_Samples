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

/**
 * 最佳实践：基于HMRouter路由框架的页面跳转开发实践
 */

import { HMRouterMgr } from '@hadss/hmrouter';
import { CommonConstants } from '../../common/constants/CommonConstants';
import { DetailConstants } from '../../common/constants/DetailConstants';
import { ResourceUtil } from '../../common/utils/ResourceUtil';
import { PayMgr } from '../../pay/PayCard';

@Component
export struct ProductUtilView {
  @Link product: ProductMsg;
  @State param: string = ''

  build() {
    Row() {
      Image($r('app.media.tab_home'))
        .width(24)
        .margin({
          left: 16,
          right: 16
        })
        .onClick(() => {
          // [Start HMRouterMgr_pageUrl]
          HMRouterMgr.to('MainPage')
            .withNavigation('mainNavigationId')
            .withParam(0)
            .popAsync()
          // [End HMRouterMgr_pageUrl]
        });

      Image($r('app.media.ic_public_comments'))
        .width(24)
        .margin({ right: 16 })
        .onClick(() => {
          // [Start HMRouterMgr_pageUrl_home_page]
          HMRouterMgr.to('HomePage')
            .withNavigation('mainNavigationId')
            .withParam(this.param)
            .popAsync()
          // [End HMRouterMgr_pageUrl_home_page]
        })
      Image($r('app.media.tab_shopping_bag'))
        .width(24)
        .margin({ right: 12 });
      Blank();
      Row() {
        Button(DetailConstants.BUTTON_NAMES[0])
          .fontSize($r('app.float.util_button_font'))
          .fontColor($r('app.color.product_font_color_2'))
          .fontWeight(CommonConstants.FONT_WEIGHT_500)
          .height($r('app.float.util_button_height'))
          .layoutWeight(1)
          .constraintSize({ maxWidth: 214 })
          .borderRadius(ResourceUtil.getCommonBorderRadius()[7])
          .backgroundColor($r('app.color.util_button_1'))
          .margin({ right: 12 });

        Button(DetailConstants.BUTTON_NAMES[1])
          .fontSize($r('app.float.util_button_font'))
          .fontColor($r('app.color.product_font_color_1'))
          .fontWeight(CommonConstants.FONT_WEIGHT_500)
          .height($r('app.float.util_button_height'))
          .borderRadius(ResourceUtil.getCommonBorderRadius()[7])
          .backgroundColor($r('app.color.util_button_2'))
          .size({ width: 64 })
          .margin({ right: 12 })
          .onClick(() => {
            HMRouterMgr.to('PayCard')
              .withNavigation('mainNavigationId')
              .withParam({ product: this.product, pageUrl: 'PayCard' })
              .onResult((popInfo: PopInfo)=>{
                if (popInfo.result) {
                  this.product.color = (popInfo.result as ProductMsg).color;
                  this.product.memory = (popInfo.result as ProductMsg).memory;
                  this.product.price = (popInfo.result as ProductMsg).price;
                } else {
                  this.product.color = DetailConstants.COLOR_SELECT_NAME_LIST[PayMgr.getInstance()
                    .getProductChoose(DetailConstants.SELECT_NAME_LIST[0])!];
                  this.product.memory = DetailConstants.CAPACITY_SELECT_NAME_LIST[PayMgr.getInstance()
                    .getProductChoose(DetailConstants.SELECT_NAME_LIST[1])!];
                  if (this.product.memory === DetailConstants.CAPACITY_SELECT_NAME_LIST[0]) {
                    this.product.price = DetailConstants.CUSTOMER_SERVICE_CONTENTS[1];
                  } else {
                    this.product.price = DetailConstants.CUSTOMER_SERVICE_CONTENTS[2];
                  }
                }
              })
              .pushAsync()
          });
      }.justifyContent(FlexAlign.End)
      .layoutWeight(1);

    }
    .width(CommonConstants.FULL_PERCENT)
    .margin({ top: 4 });
  }
}

export class ProductMsg {
  color: string;
  memory: string;
  price: string;

  constructor(color: string, memory: string, price: string) {
    this.color = color;
    this.memory = memory;
    this.price = price;
  }
}