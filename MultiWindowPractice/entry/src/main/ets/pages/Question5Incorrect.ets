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
export function Question5IncorrectBuilder() {
  Question5Incorrect()
}

// [Start Question5_incorrect]
@Component
export struct Question5Incorrect {
  build() {
    NavDestination() {
      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center }) {
        Text("Login Page")
          // [StartExclude Question5_incorrect]
          .fontSize(24)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .margin({ top: 30 })
          // [EndExclude Question5_incorrect]
        Text("Login in to access more services")
          // [StartExclude Question5_incorrect]
          .fontSize(16)
          .fontColor($r('sys.color.font_secondary'))
         // [EndExclude Question5_incorrect]

        Image($r('app.media.login_pic'))
          // [StartExclude Question5_incorrect]
          .width(200)
          .height(200)
          .margin({
            bottom: 12,
            top: 35
          })
        // [EndExclude Question5_incorrect]

        Column() {
          TextInput({ placeholder:  "Account" })
            // [StartExclude Question5_incorrect]
            .maxLength(11)
            .type(InputType.Number)
            .inputStyle()

          Line()
            .width('100%')
            .height(0.5)
            .margin({
              left: 12,
              right: 12
            })
            .backgroundColor('#0D182431')
          // [EndExclude Question5_incorrect]

          TextInput({ placeholder:"Password" })
            // [StartExclude Question5_incorrect]
            .maxLength(8)
            .type(InputType.Password)
            .inputStyle()
          // [EndExclude Question5_incorrect]
        }
        // [StartExclude Question5_incorrect]
        .margin({ top: 16 })
        .borderRadius(24)
        // [EndExclude Question5_incorrect]

        Button($r('app.string.login'))
          // [StartExclude Question5_incorrect]
          .width('100%')
          .height(40)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r('sys.color.brand'))
          .margin({ bottom: 12, top: 36 })
        // [EndExclude Question5_incorrect]
      }
      // [StartExclude Question5_incorrect]
      .height('100%')
      .width('100%')
      .align(Alignment.Center)
      .padding(12)
      // [EndExclude Question5_incorrect]
    }
    // [StartExclude Question5_incorrect]
    .hideTitleBar(true)
    .backgroundColor('#F1F3F5')
    .padding({ top: AppStorage.get<number>('statusBarHeight') ?? 0 })
    // [EndExclude Question5_incorrect]
  }
}
// [End Question5_incorrect]

@Extend(TextInput)
function inputStyle() {
  .placeholderColor($r('sys.color.font_secondary'))
  .height(48)
  .fontSize(16)
  .backgroundColor(Color.White)
  .margin({ top: 4 })
  .padding({ left: 12 })
}