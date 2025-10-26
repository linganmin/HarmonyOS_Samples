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

import { promptAction } from '@kit.ArkUI';

@Builder
export function Question4IncorrectBuilder() {
  Question4Incorrect()
}
// [Start Question4_Incorrect]
@Component
export struct Question4Incorrect {

  @Builder
  customDialogComp() {
    Column() {
      Text('Top')
        // [StartExclude  Question4_Incorrect]
        .height(60)
        .width('100%')
        .textAlign(TextAlign.Center)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .backgroundColor('#2887DA')
        // [EndExclude  Question4_Incorrect]

      Scroll() {
        Text('Middle')
          // [StartExclude  Question4_Incorrect]
          .height('100%')
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .backgroundColor('#18A98D')
          // [EndExclude  Question4_Incorrect]
      }
      .layoutWeight(1)

      Text('Bottom')
        // [StartExclude  Question4_Incorrect]
        .height(60)
        .width('100%')
        .textAlign(TextAlign.Center)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .backgroundColor('#F69C00')
      // [EndExclude  Question4_Incorrect]
    }
    .height(500)
    .justifyContent(FlexAlign.SpaceBetween)
  }

  build() {
    // [StartExclude  Question4_Incorrect]
    NavDestination() {
      Column() {
        Button('Show Dialog')
          .height(40)
          .width('100%')
          .onClick(() => {
            this.getUIContext().getPromptAction().openCustomDialog({
              builder: () => {
                this.customDialogComp();
              }
            });
          })
      }
      .height('100%')
      .width('100%')
      .justifyContent(FlexAlign.End)
      .padding({
        left: 16,
        right: 16
      })
    }
    .hideTitleBar(true)
    .padding({
      top: AppStorage.get<number>('statusBarHeight') ?? 0,
      bottom: (AppStorage.get<number>('naviIndicatorHeight') ?? 0) + 16
    })
    // [EndExclude  Question4_Incorrect]
  }
}
// [End Question4_Incorrect]