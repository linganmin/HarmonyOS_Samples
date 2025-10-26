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
import { Category, getCategories } from '../../models/Home';

@Component
export struct Categories {
  @StorageProp('breakpoint') breakpoint: Breakpoint = 'sm';

  getDataByBp<T>(data: Record<string, T>): T {
    return data[this.breakpoint];
  }

  build() {
    List({ space: this.getDataByBp({ 'sm': 0, 'md': 36 }) }) {
      ForEach(getCategories(), (category: Category) => {
        ListItem() {
          Column() {
            Image(category.image)
              .height(this.getDataByBp({ 'sm': 40, 'md': 68 }))
            Text(category.title)
              .fontSize(12)
          }
        }
        .width(this.getDataByBp({ 'sm': '20%', 'md': 64 }))
      }, (category: Category) => JSON.stringify(category))
    }
    .width('100%')
    .margin({ bottom: 10 })
    .listDirection(Axis.Horizontal)
    .lanes(this.getDataByBp({ 'sm': 2, 'md': 1 }))
    .scrollBar(BarState.Off)
  }
}