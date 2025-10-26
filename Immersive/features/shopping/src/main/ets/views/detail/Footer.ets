/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 ("the License");
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

import { Breakpoint } from 'commons';
import { FOOTER_IMAGES } from '../../constants/Detail';

@Component
export struct Footer {
  @StorageProp('breakpoint') breakpoint: Breakpoint = 'sm';

  getDataByBp<T>(data: Record<string, T>): T {
    return data[this.breakpoint];
  }

  getPadding() {
    return this.getDataByBp({ 'sm': 12, 'md': 32 });
  }

  build() {
    Row() {
      ForEach(FOOTER_IMAGES, (image: Resource) => {
        Image(image)
          .width(24)
          .height(24)
          .margin({ right: this.getDataByBp({ 'sm': 12, 'md': 32 }) })
      }, (image: Resource) => JSON.stringify(image))
      Button($r('app.string.button_text_add_to_cart'))
        .height(40)
        .fontSize(16)
        .fontColor('#CF0A2C')
        .fontWeight(500)
        .layoutWeight(this.getDataByBp({ 'sm': 2, 'md': 1 }))
        .backgroundColor('#0D000000')
        .margin({ right: 12, left: 12 })
      Button($r('app.string.button_text_buying'))
        .height(40)
        .fontSize(16)
        .fontColor(Color.White)
        .fontWeight(500)
        .layoutWeight(1)
        .backgroundColor('#CF0A2C')
    }
    .width('100%')
    .backgroundColor('#F1F3F5')
    .padding({
      left: this.getPadding(),
      right: this.getPadding(),
      top: 8,
      bottom: 8
    })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}
