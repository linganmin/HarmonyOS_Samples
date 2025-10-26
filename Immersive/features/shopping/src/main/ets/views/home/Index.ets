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

import { Banner } from './Banner';
import { Categories } from './Categories';
import { Header } from './Header';
import { Recommend } from './Recommend';
import { Welfare } from './Welfare';

@Component
export struct Home {
  build() {
    Column() {
      Header()
      Scroll() {
        Column() {
          Categories()
          Banner()
          Welfare()
            .margin({ top: 12, bottom: 12 })
          Recommend()
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16 })
  }
}