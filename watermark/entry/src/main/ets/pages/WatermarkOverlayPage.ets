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

import { NavBar } from '../component/NavBar';
import { Watermark } from '../component/Watermark';

@Entry
@Component
struct OverlayPage {
  @State angle: number = 0;
  // [Start Builder]
  @Builder
  watermarkBuilder() {
    Column() {
      Watermark()
    }
    .hitTestBehavior(HitTestMode.Transparent)
  }
  // [End Builder]
  // [Start Builder]
  build() {
    // [StartExclude Builder]
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center }) {
      NavBar()
      // [EndExclude Builder]
      Column() {
        Image($r('app.media.empty'))
          .width(110)
          .height(88)
          // [StartExclude Builder]
          .rotate({ angle: this.angle })
          .onClick(() => {
            const newAngle = this.angle === 0 ? 180 : 0;
            this.angle = newAngle
          })
        // [EndExclude Builder]
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .layoutWeight(1)
      .overlay(this.watermarkBuilder())
      // [StartExclude Builder]
      .width('100%')
    }
    .width('100%')
    .height('100%')
    // [EndExclude Builder]
  }
  // [End Builder]
}
