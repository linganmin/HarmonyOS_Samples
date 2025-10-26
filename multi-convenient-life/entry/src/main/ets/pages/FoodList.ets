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

import { ShopDisplay } from './ShopDisplay';
import { BreakpointConstants } from '../constants/BreakpointConstants';
import { FoodItem } from '../view/FoodItem';
import { FoodListHeader, FoodListTab } from '../view/FoodListHeader';
import { BreakpointType } from '../utils/BreakpointType';
import { FoodDataList, FoodData } from '../viewmodel/FoodListViewModel';
import { CommonConstants } from '../constants/CommonConstants';
import { router } from '@kit.ArkUI';


@Entry
@Component
struct FoodList {
  @StorageLink('currentBreakpoint') @Watch('changeBreakpoint') currentBreakpoint: string =
    BreakpointConstants.BREAKPOINT_LG;
  @StorageLink('windowTop') windowTop: number = 0;
  @StorageLink('windowBottom') windowBottom: number = 0;
  @Provide('pageInfo') pageInfo: NavPathStack = new NavPathStack();
  @Provide('ifShowSides') ifShowSides: boolean = false;
  @Provide('ifShowShopDisplay') ifShowShopDisplay: boolean = false;
  @State foodDataList: FoodData[] = new FoodDataList().getFoodDataList();
  @State chooseIndex: number = 0;
  private scroller: Scroller = new Scroller();

  @Builder
  PageMap() {
    ShopDisplay();
  }

  onBackPress(): boolean | void {
    this.pageInfo.pop();
  }

  changeBreakpoint() {
    if (this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM) {
      this.ifShowSides = false;
    }
  }

  build() {
    Row() {
      Navigation(this.pageInfo) {
        Column() {
          FoodListHeader()
            .padding({
              left: new BreakpointType($r('app.float.padding_small'), $r('app.float.padding_food_md'),
                $r('app.float.common_padding')).getValue(this.currentBreakpoint),
              right: new BreakpointType($r('app.float.padding_small'), $r('app.float.padding_food_md'),
                $r('app.float.common_padding')).getValue(this.currentBreakpoint)
            })
          FoodListTab()
          Scroll(this.scroller) {
            GridRow({
              columns: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG && !this.ifShowSides ?
              BreakpointConstants.GRID_ROW_COLUMNS[5] : 1,
              gutter: { x: BreakpointConstants.GRID_ROW_GUTTER, y: BreakpointConstants.GRID_ROW_GUTTER }
            }) {
              ForEach(this.foodDataList, (item: FoodData, index: number) => {
                GridCol() {
                  FoodItem({ foodData: item, listIndex: index, chooseIndex: this.chooseIndex })
                }
                .onClick(() => {
                  this.ifShowSides = true;
                  this.ifShowShopDisplay = true;
                  this.pageInfo.replacePath({ name: CommonConstants.DEFAULT_ROUTE }, false);
                  this.chooseIndex = index;
                })
              })
            }
            .padding({
              left: this.ifShowSides ? $r('app.float.padding_small') :
              new BreakpointType($r('app.float.padding_small'), $r('app.float.padding_food_md'),
                $r('app.float.common_padding')).getValue(this.currentBreakpoint),
              right: this.ifShowSides ? new BreakpointType($r('app.float.padding_small'), $r('app.float.padding_small'),
                $r('app.float.common_padding')).getValue(this.currentBreakpoint) :
              new BreakpointType($r('app.float.padding_small'), $r('app.float.common_padding'),
                $r('app.float.common_padding')).getValue(this.currentBreakpoint)
            })
            .layoutWeight(1)
          }
          .scrollBarWidth(0)
          .align(Alignment.Top)
          .layoutWeight(1)
          .padding({
            bottom: this.windowBottom
          })
        }
        .padding({
          top: this.windowTop
        })
      }
      .height('100%')
      .hideTitleBar(true)
      .navBarWidthRange(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_MD ?
        [CommonConstants.FIFTY_PERCENT, CommonConstants.FIFTY_PERCENT] :
        [CommonConstants.FORTY_PERCENT, CommonConstants.FORTY_PERCENT])
      .navDestination(this.PageMap)
      .mode(this.ifShowSides && this.currentBreakpoint !== BreakpointConstants.BREAKPOINT_SM ?
      NavigationMode.Split : NavigationMode.Stack)
    }
    .height('100%')
  }
}