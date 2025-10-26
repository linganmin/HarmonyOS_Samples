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
import { getBannerData, Product } from '../../models/Home';

@Component
export struct Banner {
  @StorageProp('breakpoint') breakpoint: Breakpoint = 'sm';
  @Consume('navPageInfos') navPageInfos: NavPathStack;

  getDataByBp<T>(data: Record<string, T>): T {
    return data[this.breakpoint];
  }

  build() {
    Swiper() {
      ForEach(getBannerData(), (product: Product) => {
        Stack() {
          Image(product.image)
            .height('100%')
            .width('100%')
            .onClick(() => this.navPageInfos.pushPath({ name: 'ProductDetail' }))
          if (product.isLive) {
            Image($r('app.media.icon_is_living'))
              .width(24)
              .height(24)
              .margin(8)
          }
        }
        .alignContent(Alignment.TopEnd)
        .aspectRatio(1)
      }, (product: Product) => JSON.stringify(product))
    }
    .displayCount(this.getDataByBp({ 'sm': 2, 'md': 3 }))
    .indicator(false)
    .itemSpace(14)
  }
}