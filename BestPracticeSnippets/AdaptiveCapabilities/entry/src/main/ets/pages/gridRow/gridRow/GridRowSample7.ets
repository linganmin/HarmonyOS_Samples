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

import { ColorArr } from '../../../common/ColorEntity';

// [Start GridRowSample7]
@Entry
@Component
struct GridRowSample7 {
  private elements: ColorArr[] = [
    { index: 1, color: $r('sys.color.ohos_id_color_palette_aux1') },
    { index: 2, color: $r('sys.color.ohos_id_color_palette_aux2') },
    { index: 3, color: $r('sys.color.ohos_id_color_palette_aux3') },
    { index: 4, color: $r('sys.color.ohos_id_color_palette_aux4') },
    { index: 5, color: $r('sys.color.ohos_id_color_palette_aux5') },
    { index: 6, color: $r('sys.color.ohos_id_color_palette_aux6') }
  ];

  build() {
    GridRow({ columns: { sm: 12, md: 12, lg: 12 } }) {
      ForEach(this.elements, (item: ColorArr) => {
        GridCol({
          span: { sm: 6, md: 4, lg: 3 },
          order: { lg: (6 - item.index) }
        }) {
          Row() {
            Text(`${item.index}`)
              .fontSize(24)
          }
          .justifyContent(FlexAlign.Center)
          .backgroundColor(item.color)
          .height(30)
          .width('100%')
        }
      }, (item: ColorArr, index: number) => (item.index + index).toString())
    }
  }
}
// [End GridRowSample7]