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

import { ShopHeader, ShopSideBar } from '../view/ShopInformation';
import { BreakpointConstants } from '../constants/BreakpointConstants';
import { BreakpointType } from '../utils/BreakpointType';
import { ShopOrderList } from '../view/ShopOrderList';
import { DishDetails } from './DishDetails';
import { CommonConstants } from '../constants/CommonConstants';

@Component
export struct ShopDisplay {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @StorageLink('windowTop') windowTop: number = 0;
  @StorageLink('windowBottom') windowBottom: number = 0;
  @Provide('shopPageInfo') shopPageInfo: NavPathStack = new NavPathStack();
  @Consume('ifShowShopDisplay') ifShowShopDisplay: boolean;
  @Consume('ifShowSides') ifShowSides: boolean;
  @Consume('pageInfo') pageInfo: NavPathStack;
  @StorageLink('payWidth') payWidth: Length = 0;
  private scroller: Scroller = new Scroller();

  @Builder
  PageMap() {
    DishDetails()
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Navigation(this.shopPageInfo) {
          Stack({ alignContent: Alignment.Top }) {
            Scroll(this.scroller) {
              // [Start flex_change_view]
              Flex({
                direction: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG && !this.ifShowSides ?
                FlexDirection.Row : FlexDirection.Column,
                justifyContent: FlexAlign.Start
              }) {
                ShopHeader()
                  .visibility(this.currentBreakpoint !== BreakpointConstants.BREAKPOINT_LG || this.ifShowSides ?
                  Visibility.Visible : Visibility.None)
                ShopSideBar()
                  .width(CommonConstants.THIRTY_SEVEN_PERCENT)
                  .flexShrink(0)
                  .visibility(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG && !this.ifShowSides ?
                  Visibility.Visible : Visibility.None)
                ShopOrderList()
                  .height(CommonConstants.FULL_PERCENT)
                // [StartExclude flex_change_view]
                Row() {
                  Image($r('app.media.icon_back'))
                    .width($r('app.float.common_image'))
                    .aspectRatio(1)
                    .margin({
                      top: $r('app.float.back_margin_top'),
                      left: $r('app.float.common_margin')
                    })
                    .onClick(() => {
                      this.pageInfo.pop();
                      if (this.ifShowSides) {
                        this.ifShowSides = false;
                      }
                    })
                  Image($r('app.media.ic_public_enlarge'))
                    .width($r('app.float.common_image'))
                    .aspectRatio(1)
                    .margin({
                      top: $r('app.float.back_margin_top'),
                      left: $r('app.float.enlarge_margin_left')
                    })
                    .onClick(() => {
                      this.ifShowSides = false;
                    })
                    .visibility(this.ifShowSides && this.currentBreakpoint !== BreakpointConstants.BREAKPOINT_SM ?
                    Visibility.Visible : Visibility.None)
                  Image($r('app.media.ic_public_reduce'))
                    .width($r('app.float.common_image'))
                    .aspectRatio(1)
                    .margin({
                      top: $r('app.float.back_margin_top'),
                      left: $r('app.float.enlarge_margin_left')
                    })
                    .onClick(() => {
                      this.ifShowSides = true;
                    })
                    .visibility(!this.ifShowSides && this.currentBreakpoint !== BreakpointConstants.BREAKPOINT_SM ?
                    Visibility.Visible : Visibility.None)
                }
                .width(CommonConstants.FULL_PERCENT)
                .backgroundColor('#00ffffff')
                .visibility(this.currentBreakpoint !== BreakpointConstants.BREAKPOINT_LG || this.ifShowSides ?
                Visibility.Visible : Visibility.None)
                .position({
                  top: this.windowTop
                })

                // [EndExclude flex_change_view]
              }
              // [End flex_change_view]
              .layoutWeight(1)
            }
            .scrollBar(BarState.Off)
          }
        }
        .width(CommonConstants.FULL_PERCENT)
        .hideTitleBar(true)
        .hideToolBar(true)
        .navDestination(this.PageMap)
        .mode(NavigationMode.Stack)

        Row() {
          Row() {
            Column() {
              Text($r('app.string.shop_amounts'))
                .fontColor(Color.White)
                .fontSize($r('app.float.amounts_font'))
                .fontWeight(CommonConstants.FONT_WEIGHT_700)
              Text($r('app.string.estimated_delivery'))
                .fontColor('#99ffffff')
                .fontSize($r('app.float.delivery_font'))
                .fontWeight(CommonConstants.FONT_WEIGHT_400)
            }
            .alignItems(HorizontalAlign.Start)

            Blank()
            Text($r('app.string.send_from'))
              .fontColor('#99ffffff')
              .fontSize($r('app.float.send_font'))
              .fontWeight(CommonConstants.FONT_WEIGHT_700)

          }
          .layoutWeight(1)
          .backgroundColor('#232426')
          .height($r('app.float.amounts_height'))
          .borderRadius($r('app.float.amounts_border'))
          .padding({
            left: $r('app.float.common_padding'),
            right: $r('app.float.common_padding')
          })
        }
        .position({
          right: 0,
          bottom: this.windowBottom
        })
        .width(this.ifShowSides || this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ?
        CommonConstants.SELF_ADAPTING : this.ifShowShopDisplay ?
            this.currentBreakpoint === BreakpointConstants.BREAKPOINT_MD ? CommonConstants.SELF_ADAPTING :
            CommonConstants.SIXTY_PERCENT : this.payWidth)
        .padding({
          left: this.ifShowSides ? new BreakpointType($r('app.float.padding_small'), $r('app.float.padding_small'),
            $r('app.float.common_padding')).getValue(this.currentBreakpoint) :
            this.ifShowShopDisplay ? new BreakpointType($r('app.float.padding_small'), $r('app.float.common_padding'),
              $r('app.float.common_padding')).getValue(this.currentBreakpoint) : new BreakpointType(
              $r('app.float.padding_small'), $r('app.float.common_padding'),
              $r('app.float.zero_padding')).getValue(this.currentBreakpoint),
          right: this.ifShowSides ? new BreakpointType($r('app.float.padding_small'), $r('app.float.padding_small'),
            $r('app.float.common_padding')).getValue(this.currentBreakpoint) :
          new BreakpointType($r('app.float.padding_small'), $r('app.float.common_padding'),
            $r('app.float.common_padding')).getValue(this.currentBreakpoint),
        })
      }
      .width(CommonConstants.FULL_PERCENT)
    }
    .width(CommonConstants.FULL_PERCENT)
    .hideTitleBar(true)
    .height(CommonConstants.FULL_PERCENT)
  }
}