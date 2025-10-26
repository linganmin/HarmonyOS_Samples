/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

// [Start AgreementPage]
@Component
export struct AgreementPage {
  @Consume('NavPathStack') pageStack: NavPathStack;

  build() {
    NavDestination() {
      Row(){
        Row() {
          Image($r('app.media.chevron_left'))
            .width(16)
            .height(16)
            .margin({ left: 12 })
        }
        .width(40)
        .height(40)
        .borderRadius(48)
        .margin({ top: 42 })
        .backgroundColor('#e6eaeb')
        .onClick(() => {
          this.pageStack.pop();
        })
      }
      .width('100%')
      .padding({
        left: 16,
        right: 16
      })
      Scroll() {
        Column() {
          Image($r('app.media.privacy'))
            .width(30)
            .height(30)
          Text($r('app.string.privacy_title'))
            .fontSize(20)
            .margin({ top: 12 })
            .fontWeight(700)
            .height(28)

          Text($r('app.string.update_date'))
            .fontSize(16)
            .margin({ top: 2 })
            .fontColor(Color.Gray)
            .fontWeight(700)
            .height(28)

          Column() {
            Text($r('app.string.introductory_1'))
              .lineHeight(24)
          }
          .width('100%')
          .margin({ top: 24 })

          Column() {
            Text() {
              Span($r('app.string.introductory_2'))
                .margin({ bottom: 8 })
              Span($r('app.string.introductory_3'))
                .lineHeight(24)
            }
          }
          .width('100%')
          .margin({ top: 24 })
          .alignItems(HorizontalAlign.Start)

          Column() {
            Text() {
              Span($r('app.string.introductory_4'))
                .lineHeight(24)
              Span($r('app.string.introductory_5'))
                .lineHeight(24)
            }
          }
          .width('100%')
          .margin({ top: 24 })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .height('100%')
        .margin({ bottom: 16 })
        .padding({
          left: 12,
          right: 12
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F1F3F5')
      .padding({
        left: 16,
        right: 16
      })
    }
    .hideTitleBar(true)
    .height('100%')
    .backgroundColor('#F1F3F5')
  }
}

// [End AgreementPage]