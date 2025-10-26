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
import { ShoppingBagConstants } from '../../common/constants/ShoppingBagConstants';
import { ResourceUtil } from '../../common/utils/ResourceUtil';
import { ShoppingBagCard } from './ShoppingBagCard';
import { ShoppingCardFoot } from './ShoppingCardFoot';

@Component
export struct DetailShoppingBagView {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @StorageLink('topRectHeight') topRectHeight: number = 0;
  @Consume('pageInfos') pageInfos: NavPathStack;
  private isMoreDetail: boolean = false;

  build() {
    Column() {
      Column() {
        Row() {
          Image($r('app.media.ic_public_back'))
            .width(ResourceUtil.getCommonImgSize()[0])
            .height(ResourceUtil.getCommonImgSize()[0])
            .margin({right: $r('app.float.bag_back_margin')})
            .visibility(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM && this.isMoreDetail ?
            Visibility.Visible : Visibility.None)
            .onClick(() => {
              if(this.pageInfos !== undefined) {
                this.pageInfos.pop();
              }
            });
          Text(ShoppingBagConstants.SHOPPING_BAG_TITLES[0])
            .font({
              size: $r('app.float.bag_title_font'),
              weight: CommonConstants.FONT_WEIGHT_500
            });
          Blank();
          Text(ShoppingBagConstants.SHOPPING_BAG_TITLES[1])
            .font({size: $r('app.float.bag_name_font')})
            .opacity(CommonConstants.TEXT_OPACITY[2]);
          Image($r('app.media.icon_close'))
            .width(ResourceUtil.getCommonImgSize()[0])
            .height(ResourceUtil.getCommonImgSize()[0])
            .margin({left: $r('app.float.bag_close_margin')})
            .visibility(this.currentBreakpoint !== BreakpointConstants.BREAKPOINT_SM ? Visibility.Visible :
            Visibility.None)
            .onClick(() => {
              if(this.pageInfos !== undefined) {
                this.pageInfos.pop();
              }
            });
        }
        .height($r('app.float.bag_title_row_height'))
        .width(CommonConstants.FULL_PERCENT);

        ShoppingBagCard();
      }
      .width(CommonConstants.FULL_PERCENT)
      .layoutWeight(1)
      .margin({
        top: deviceInfo.deviceType === CommonConstants.DEVICE_TYPES[0] ? $r('app.float.bag_col_margin') :
        this.topRectHeight
      });

      ShoppingCardFoot()
        .margin({
          bottom: deviceInfo.deviceType !== CommonConstants.DEVICE_TYPES[0] ?
          CommonConstants.BOTTOM_RECT_HEIGHT : 0
        })
        .visibility(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG && !this.isMoreDetail ?
        Visibility.None : Visibility.Visible);
    }
    .padding({
      left: ResourceUtil.getPageColPadding().getValue(this.currentBreakpoint),
      right: ResourceUtil.getPageColPadding().getValue(this.currentBreakpoint)
    })
    .layoutWeight(ShoppingBagConstants.SHOPPING_BAG_LAYOUT_WEIGHTS[0])
    .height(CommonConstants.FULL_PERCENT)
    .border({
      width: {right: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ? 1 : 0},
      color: ResourceUtil.getCommonBorderColor()[1]
    });
  }
}