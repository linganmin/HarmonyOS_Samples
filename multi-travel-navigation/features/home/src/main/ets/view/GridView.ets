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

import { FunctionType, Common } from '@ohos/commons/Index';
import { HomeConstants } from '../constants/HomeConstants';

@Component
export struct GridView {
  @Link columnHeight: number;

  build() {
    Grid() {
      ForEach(HomeConstants.FUNCTIONS, (item: FunctionType) => {
        GridItem() {
          Column() {
            Image(item.icon)
              .width(item.id < HomeConstants.FUNCTION_SIZE_JUDGE ?
                $r('app.float.function_icon_size_big') : $r('app.float.function_icon_size_small'))
              .height(item.id < HomeConstants.FUNCTION_SIZE_JUDGE ?
                $r('app.float.function_icon_size_big') : $r('app.float.function_icon_size_small'))

            Text(item.desc)
              .fontSize($r('app.float.tip_font_size'))
              .fontColor($r('app.color.black_90'))
              .padding({ top: $r('app.float.text_space') })
          }
          .padding({ top: $r('app.float.grid_item_padding') })
        }
        .visibility((item.id >= HomeConstants.FUNCTION_SIZE_JUDGE && this.columnHeight <= Common.HEIGHT_MIDDLE) ?
          Visibility.None : Visibility.Visible)
      }, (item: FunctionType) => item.id.toString())
    }
    .scrollBar(BarState.Off)
    .height(this.columnHeight <= Common.HEIGHT_MIDDLE ?
      $r('app.float.grid_height_part') : $r('app.float.grid_height_full'))
    .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
  }
}