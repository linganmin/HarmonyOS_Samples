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
import { FoodListConstants } from '../constants/FoodListConstants';
import { BreakpointType } from '../utils/BreakpointType';
import { router } from '@kit.ArkUI';


@Component
export struct FoodListHeader {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @StorageLink('pageShow') pageShow: string = 'button';
  @Consume('ifShowSides') ifShowSides: boolean;

  build() {
    Row() {
      Image($r('app.media.icon_back'))
        .width($r('app.float.common_image'))
        .aspectRatio(1)
        .margin({
          right: $r('app.float.back_image_right')
        })
        .onClick(() => {
          this.getUIContext().getRouter().back();
        })
      Blank()
      Stack({ alignContent: Alignment.End }) {
        TextInput({ placeholder: $r('app.string.food_name') })
          .height($r('app.float.food_name_height'))
          .placeholderFont({
            size: $r('app.float.food_data_font'),
            weight: FontWeight.Normal
          })
          .backgroundColor(Color.White)
          .width(CommonConstants.FULL_PERCENT)
          .border({
            width: $r('app.float.food_border_width'),
            color: $r('app.color.food_border_color'),
            radius: $r('app.float.food_border_radius')
          })
          .padding({
            left: $r('app.float.food_padding_left'),
            right: $r('app.float.food_padding_right'),
            top: $r('app.float.food_padding_tb'),
            bottom: $r('app.float.food_padding_tb')
          })
          .enableKeyboardOnFocus(false)
        Image($r('app.media.icon_search'))
          .width($r('app.float.search_width'))
          .aspectRatio(1)
          .position({
            x: $r('app.float.search_position_x'),
            y: $r('app.float.search_position_y')
          })
        Image($r('app.media.icon_voice'))
          .width($r('app.float.voice_width'))
          .offset({
            x: $r('app.float.voice_offset')
          })
      }
      .height($r('app.float.food_height'))
      .width($r('app.float.food_width'))
      .layoutWeight(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM || this.ifShowSides ? 1 : 0)
    }
    .height($r('app.float.food_stack_height'))
    .width(CommonConstants.FULL_PERCENT)
  }
}

@Component
export struct FoodListTab {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;

  build() {
    List() {
      ForEach(FoodListConstants.TABS_LIST, (item: string) => {
        ListItem() {
          Text(item)
            .fontSize($r('app.float.tabs_font'))
            .fontWeight(FontWeight.Normal)
            .padding({
              top: $r('app.float.tabs_padding_tb'),
              bottom: $r('app.float.tabs_padding_tb'),
              left: $r('app.float.twelves_padding'),
              right: $r('app.float.twelves_padding')
            })
            .margin({
              right: $r('app.float.tabs_margin_right')
            })
            .backgroundColor($r('app.color.five_white'))
            .height($r('app.float.tabs_list_height'))
            .borderRadius($r('app.float.tabs_list_radius'))
        }
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .listDirection(Axis.Horizontal)
    .height($r('app.float.tabs_height'))
    .padding({
      top: $r('app.float.twelves_padding'),
      bottom: $r('app.float.twelves_padding'),
      left: new BreakpointType($r('app.float.padding_small'), $r('app.float.tabs_list_padding_left'),
        $r('app.float.common_padding')).getValue(this.currentBreakpoint)
    })
    .scrollBarWidth(0)
  }
}