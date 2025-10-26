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
import { getRecommendData, Product } from '../../models/Home';

@Component
export struct Recommend {
  @StorageProp('breakpoint') breakpoint: Breakpoint = 'sm';
  @Consume('navPageInfos') navPageInfos: NavPathStack;

  getDataByBp<T>(data: Record<string, T>): T {
    return data[this.breakpoint];
  }

  filterRecommendData(): Product[] {
    const endIndex = this.breakpoint === 'sm' ? 2 : 3;
    return getRecommendData().slice(0, endIndex);
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.recommend_title'))
          .fontSize(16)
          .fontWeight(500)
        Blank()
        Text($r('app.string.button_more_text'))
          .fontSize(14)
          .opacity(0.6)
        Image($r('app.media.arrow_right'))
          .width(24)
          .height(24)
          .opacity(0.6)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .height(48)
      Row() {
        ForEach(this.filterRecommendData(), (product: Product) => {
          Column() {
            Image(product.image)
              .width('100%')
              .aspectRatio(1.29)
            Text(product.title)
              .fontSize(14)
              .fontWeight(500)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Text(product.info)
              .height(16)
              .fontSize(12)
              .opacity(0.4)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin(2)
            Text(product.feature)
              .fontSize(9)
              .fontColor('#D0092D')
              .padding({ left: 4, right: 4 })
              .border({
                width: 1,
                color: '#66D0092D',
                radius: 4
              })
            Text(product.price)
              .fontSize(14)
              .fontColor('#D0092D')
              .fontWeight(500)
              .margin(4)
            Text(product.comment)
              .fontSize(10)
              .opacity(0.4)
          }
          .width(this.getDataByBp({ 'sm': '50%', 'md': '33%' }))
          .onClick(() => this.navPageInfos.pushPath({ name: 'ProductDetail' }))
        }, (product: Product) => JSON.stringify(product))
      }
      .width('100%')
      .borderRadius(16)
      .backgroundColor(Color.White)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .borderRadius(16)
    .backgroundColor(Color.White)
    .padding({ left: 12, right: 12, bottom: 12 })
  }
}