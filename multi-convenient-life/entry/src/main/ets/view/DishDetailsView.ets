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
import { BreakpointType } from '../utils/BreakpointType';
import { DishDetail, DishDetailList } from '../viewmodel/DishDetailViewModel';
import { DishComments } from './DishComments';

@Component
export struct DishDetailsView {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @StorageLink('windowTop') windowTop: number = 0;
  @StorageLink('windowBottom') windowBottom: number = 0;
  @StorageLink('payWidth') payWidth: Length = 0;
  @Consume('ifShowSides') ifShowSides: boolean;
  private dishDetailList: DishDetail[] = new DishDetailList().getDishDetailList();

  build() {
    Column() {
      Column() {
        Row() {
          Text($r('app.string.detailing'))
            .fontSize($r('app.float.amounts_font'))
            .fontWeight(CommonConstants.FONT_WEIGHT_700)
        }
        .width(CommonConstants.FULL_PERCENT)
        .justifyContent(FlexAlign.Start)
        .padding({
          left: this.ifShowSides ? new BreakpointType($r('app.float.twelves_padding'), $r('app.float.twelves_padding'),
            $r('app.float.dish_lg')).getValue(this.currentBreakpoint) :
          new BreakpointType($r('app.float.twelves_padding'), $r('app.float.padding_small'),
            $r('app.float.twelves_padding')).getValue(this.currentBreakpoint),
          bottom: $r('app.float.dish_bottom')
        })
        .border({
          color: $r('app.color.five_white'),
          width: {
            bottom: $r('app.float.dish_border_bottom')
          }
        })

        ForEach(this.dishDetailList, (item: DishDetail) => {
          Row() {
            Text(item.getKey())
              .fontSize($r('app.float.delivery_font'))
              .fontWeight(CommonConstants.FONT_WEIGHT_400)
              .fontColor($r('app.color.sixty_black'))
              .width($r('app.float.key_width'))
            Text(item.getValue())
              .fontSize($r('app.float.delivery_font'))
              .fontWeight(CommonConstants.FONT_WEIGHT_400)
              .fontColor($r('app.color.sixty_black'))
              .layoutWeight(1)
          }
          .alignItems(VerticalAlign.Top)
          .padding({
            left: this.ifShowSides ?
            new BreakpointType($r('app.float.twelves_padding'), $r('app.float.twelves_padding'),
              $r('app.float.dish_lg')).getValue(this.currentBreakpoint) :
            new BreakpointType($r('app.float.twelves_padding'), $r('app.float.padding_small'),
              $r('app.float.twelves_padding')).getValue(this.currentBreakpoint),
            bottom: $r('app.float.dish_bottom'),
            top: $r('app.float.twelves_padding')
          })
          .justifyContent(FlexAlign.Start)
          .width(CommonConstants.FULL_PERCENT)
        }, (item: DishDetail, index: number) => index + JSON.stringify(item))
      }
      .margin({
        left: this.ifShowSides ? new BreakpointType($r('app.float.padding_small'), $r('app.float.padding_small'),
          $r('app.float.common_padding')).getValue(this.currentBreakpoint) :
        new BreakpointType($r('app.float.padding_small'), $r('app.float.common_padding'),
          $r('app.float.zero_padding')).getValue(this.currentBreakpoint),
        right: this.ifShowSides ? new BreakpointType($r('app.float.padding_small'), $r('app.float.padding_small'),
          $r('app.float.common_padding')).getValue(this.currentBreakpoint) :
        new BreakpointType($r('app.float.padding_small'), $r('app.float.common_padding'),
          $r('app.float.common_padding')).getValue(this.currentBreakpoint),
        bottom: $r('app.float.twelves_padding'),
        top: !this.ifShowSides && this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ? this.windowTop : 0
      })
      .backgroundColor(Color.White)
      .borderRadius($r('app.float.dish_border'))
      .padding({
        top: $r('app.float.twelves_padding'),
        bottom: $r('app.float.twelves_padding')
      })

      if (this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG) {
        DishComments()
      }
    }
    .onAreaChange((oldArea: Area, newArea: Area) => {
      this.payWidth = newArea.width;
    })
  }
}