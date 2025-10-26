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

@Builder
export function Question1IncorrectBuilder() {
  Question1Incorrect()
}

// [Start Question1_incorrect]
@Component
export struct Question1Incorrect {
  build() {
    NavDestination() {
      Column({ space: 12 }) {
        Text('Text1')
          .fontSize(50)
          .width('100%')
          .textAlign(TextAlign.Center)
          .height(350)
          .backgroundColor(Color.Brown)

        Text('Text2')
          .fontSize(50)
          .width('100%')
          .textAlign(TextAlign.Center)
          .height(350)
          .backgroundColor(Color.Orange)
      }
      // [StartExclude  Question1_incorrect]
      .height('100%')
      .width('100%')
      .padding({
        left: 16,
        right: 16
      })
      // [EndExclude  Question1_incorrect]
    }
    // [StartExclude  Question1_incorrect]
    .hideTitleBar(true)
    .padding({
      top: AppStorage.get<number>('statusBarHeight') ?? 0,
      bottom:( AppStorage.get<number>('naviIndicatorHeight') ?? 0) + 16
    })
    // [EndExclude  Question1_incorrect]
  }
}
// [End Question1_incorrect]