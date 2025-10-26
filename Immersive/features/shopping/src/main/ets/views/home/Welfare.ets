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
import { TIP_TEXTS } from '../../constants/Home';
import { getWelfareData, Product } from '../../models/Home';

@Component
export struct Welfare {
  @StorageProp('breakpoint') breakpoint: Breakpoint = 'sm';
  @Consume('navPageInfos') navPageInfos: NavPathStack;

  getDataByBp<T>(data: Record<string, T>): T {
    return data[this.breakpoint];
  }

  filterWelfareData(): Product[] {
    const endIndex = this.breakpoint === 'sm' ? 3 : 6;
    return getWelfareData(this.getUIContext()).slice(0, endIndex);
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.welfare_title'))
          .fontSize(16)
          .fontWeight(500)
        Blank()
        Button($r('app.string.button_vouchers'))
          .backgroundColor('#E64566')
          .height(28)
          .fontColor(Color.White)
          .fontSize(12)
          .fontWeight(500)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .height(48)
      Row() {
        ForEach(this.filterWelfareData(), (product: Product) => {
          Column() {
            Image(product.image)
              .width(this.getDataByBp({ 'sm': 60, 'md': 72 }))
              .aspectRatio(1)
            Text(TIP_TEXTS[0])
              .fontSize(10)
              .width(40)
              .borderRadius(14)
              .backgroundColor('#0D000000')
              .textAlign(TextAlign.Center)
            Text(product.price)
              .fontSize(12)
              .fontWeight(500)
              .margin({ top: 4 })
          }
          .onClick(() => this.navPageInfos.pushPath({ name: 'ProductDetail' }))
        }, (product: Product) => JSON.stringify(product))
      }
      .width('100%')
      .borderRadius(16)
      .backgroundColor(Color.White)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: 16, right: 16, bottom: 8 })
    }
    .borderRadius(16)
    .linearGradient({
      direction: GradientDirection.Right,
      repeating: false,
      colors: [['#4DEDAA68', 0.0], ['#33FFE9C1', 1.0]]
    })
    .padding({ left: 12, right: 12, bottom: 12 })
  }
}