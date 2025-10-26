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

import { ArcSwiper } from '@kit.ArkUI';
import { CarControlView } from '../view/CarControlView';
import { CarInformationView } from '../view/CarInformationView';

@Entry
@Component
struct Index {
  @State pathStack: NavPathStack = new NavPathStack();
  // [Start borderRadius]
  build() {
    Navigation(this.pathStack) {
      // [StartExclude borderRadius]
      // [Start ArcSwiper]
      ArcSwiper() {
        CarInformationView()
        CarControlView({ pathStack: this.pathStack })
      }
      // [End ArcSwiper]
      // [EndExclude borderRadius]
    }
    .backgroundColor(Color.Black)
    .hideTitleBar(true)
    .hideToolBar(true)
    .height('100%')
    .width('100%')
    .borderRadius('50%')
  }
  // [End borderRadius]
}