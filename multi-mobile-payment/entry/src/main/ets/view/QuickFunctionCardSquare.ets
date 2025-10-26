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

import { Constants } from '../common/Constants';
import { getValueByBreakpoint } from '../pages/Home';
import { QuickFunctionItem } from '../viewmodel/PayHubViewModel';

@Component
export struct QuickFunctionCardSquare {
  @Prop quickFunctionItem: QuickFunctionItem;
  @StorageProp('currentBreakpoint') curBp: string = '';

  build() {
    Row() {
      Row() {
        Image(this.quickFunctionItem.getImg())
          .width(
            getValueByBreakpoint({
              'md': $r('app.float.quick_function_icon_size_md'),
              'lg': $r('app.float.quick_function_icon_size_lg')
            }, this.curBp)
          )
      }
      .width(this.curBp === Constants.BREAKPOINTS[1] ? $r('app.float.quick_function_item_image_size_smaller') :
      $r('app.float.quick_function_item_image_size_bigger'))
      .height(this.curBp === Constants.BREAKPOINTS[1] ? $r('app.float.quick_function_item_image_size_smaller') :
      $r('app.float.quick_function_item_image_size_bigger'))
      .margin({
        right: this.curBp === Constants.BREAKPOINTS[1] ?
        Constants.CONTENT_SPACE[1] :
        Constants.CONTENT_SPACE[6]
      })
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)

      Text(this.quickFunctionItem.getText())
        .fontFamily($r('app.string.normal_font_family'))
        .fontSize($r('app.float.bigger_font_size'))
        .fontColor(Color.White)
        .fontWeight(Constants.FONT_WEIGHT[0])
    }
    .width(Constants.FULL_WIDTH)
    .height(Constants.FULL_HEIGHT)
    .backgroundColor($r('app.color.quick_function_item_background_color'))
    .borderRadius($r('app.float.quick_function_item_border_radius'))
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
  }
}