/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { CommonConstants } from '../../constants/CommonConstants';
import { BreakpointConstants } from '../../constants/BreakpointConstants';
import { BreakpointType } from '../../utils/BreakpointSystem';

@Component
export struct SearchBarView {
  @StorageProp('topHeight') topHeight: number = CommonConstants.NUMBER_DEFAULT_VALUE;
  @StorageLink(BreakpointConstants.BREAKPOINT_NAME) currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;

  build() {
    Row() {
      Stack({ alignContent: Alignment.Start }) {
        TextInput({ placeholder: $r('app.string.search') })
          .backgroundColor($r('app.color.common_background_3'))
          .height($r('app.float.search_input_height'))
          .fontSize($r('app.float.search_input_font'))
          .padding({
            left: $r('app.float.search_input_left'),
            right: $r('app.float.search_input_right')
          })
          .width(CommonConstants.FULL_PERCENT)
          .enableKeyboardOnFocus(false)
          .focusable(false)

        Image($r('app.media.ic_public_search'))
          .width($r('app.float.search_img_size'))
          .height($r('app.float.search_img_size'))
          .margin({ left: $r('app.float.search_img_left') })
      }
      .alignSelf(ItemAlign.Center)
      .layoutWeight(1);
    }
    .justifyContent(FlexAlign.Center)
    .height($r('app.float.search_bar_height'))
    .margin({
      left: new BreakpointType({
        sm: BreakpointConstants.SEARCHBAR_AND_WATER_FLOW_MARGIN_LEFT_SM,
        md: BreakpointConstants.SEARCHBAR_AND_WATER_FLOW_MARGIN_LEFT_MD,
        lg: BreakpointConstants.SEARCHBAR_AND_WATER_FLOW_MARGIN_LEFT_LG,
        xl: BreakpointConstants.SEARCHBAR_AND_WATER_FLOW_MARGIN_LEFT_LG
      }).getValue(this.currentBreakpoint),
      right: new BreakpointType({
        sm: BreakpointConstants.SEARCHBAR_AND_WATER_FLOW_MARGIN_RIGHT_SM,
        md: BreakpointConstants.SEARCHBAR_AND_WATER_FLOW_MARGIN_RIGHT_MD,
        lg: BreakpointConstants.SEARCHBAR_AND_WATER_FLOW_MARGIN_RIGHT_LG,
        xl: BreakpointConstants.SEARCHBAR_AND_WATER_FLOW_MARGIN_RIGHT_LG
      }).getValue(this.currentBreakpoint)
    })
  }
}