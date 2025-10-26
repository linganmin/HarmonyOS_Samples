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
export function Question5CorrectBuilder() {
  Question5Correct()
}

// [Start Question5_correct]
@Component
export struct Question5Correct {
  build() {
    NavDestination() {
      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center }) {
        Text("Login Page")
          // [StartExclude Question5_correct]
          .fontSize(24)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
            // [EndExclude Question5_correct]
          .displayPriority(4)

        Text("Login in to access more services")
          // [StartExclude Question5_correct]
          .fontSize(16)
          .fontColor($r('sys.color.font_secondary'))
            // [EndExclude Question5_correct]
          .displayPriority(3)

        Image($r('app.media.login_pic'))
          // [StartExclude Question5_correct]
          .width(200)
          .height(200)
          .margin({
            bottom: 12,
            top: 35
          })
            // [EndExclude Question5_correct]
          .displayPriority(2)

        Column() {
          TextInput({ placeholder: "Account" })
            // [StartExclude Question5_correct]
            .maxLength(11)
            .type(InputType.Number)
            .inputStyle()
          // [EndExclude Question5_correct]

          TextInput({ placeholder: "Password" })
            // [StartExclude Question5_correct]
            .maxLength(8)
            .type(InputType.Password)
            .inputStyle()
          // [EndExclude Question5_correct]
        }
        // [StartExclude Question5_correct]
        .margin({ top: 16 })
        .borderRadius(24)
        // [EndExclude Question5_correct]
        .displayPriority(5)
        // [StartExclude Question5_correct]
        Blank()
          .height(24)
          .displayPriority(3)
        // [EndExclude Question5_correct]
        Button($r('app.string.login'))
          // [StartExclude Question5_correct]
          .width('100%')
          .height(40)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r('sys.color.brand'))
          .margin({ bottom: 12, top: 16 })
            // [EndExclude Question5_correct]
          .displayPriority(5)
      }
      // [StartExclude Question5_correct]
      .height('100%')
      .width('100%')
      .align(Alignment.Center)
      .padding(12)
      // [EndExclude Question5_correct]
    }
    // [StartExclude Question5_correct]
    .hideTitleBar(true)
    .backgroundColor('#F1F3F5')
    .padding({ top: AppStorage.get<number>('statusBarHeight') ?? 0 })
    // [EndExclude Question5_correct]
  }
}
// [End Question5_correct]

@Extend(TextInput)
function inputStyle() {
  .placeholderColor($r('sys.color.font_secondary'))
  .height(48)
  .fontSize(16)
  .backgroundColor(Color.White)
  .margin({ top: 4 })
  .padding({ left: 12 })
}