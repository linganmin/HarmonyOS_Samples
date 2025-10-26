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

// [Start CustomDialogNotDisappear_start]
@Component
export struct CustomDialogNotDisappear {
  @Consume('NavPathStack') pageStack: NavPathStack;

  build() {
    NavDestination() {
      Column() {
        Row() {
          Button('OPEN')
            .fontSize(16)
            .width('100%')
            .borderRadius(20)
            .margin({ bottom: 16 })
            .backgroundColor('#0A59F7')
            .onClick(() => {
              this.pageStack.pushPathByName('DialogPage', '');
            })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .padding({
        left: 16,
        right: 16
      })
      .justifyContent(FlexAlign.End)
    }
  }
}

@Component
export struct DialogPage {
  @Consume('NavPathStack') pageStack: NavPathStack;

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Center }) {
        Column() {
          Row() {
            Text('Title')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
          }
          .width('100%')
          .height(56)
          .justifyContent(FlexAlign.Center)

          Text('This is a dialog content.')
            .fontSize(14)

          Button('CONFIRM')
            .fontSize(16)
            .fontColor('#0A59F7')
            .backgroundColor(Color.White)
            .onClick(() => {
              this.pageStack.pushPathByName('PageOne', 'PageOne Param');
            })
            .width('100%')
            .margin({
              top: 8,
              bottom: 16
            })
        }
        .padding({
          left: 24,
          right: 24
        })
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor(Color.White)
        .borderRadius(32)
        .margin({
          left: 16,
          right: 16
        })
      }
      .height('100%')
      .width('100%')
    }
    .backgroundColor('rgba(0,0,0,0.2)')
    .hideTitleBar(true)
    .mode(NavDestinationMode.DIALOG)
  }
}

@Component
export struct PageOne {
  @Consume('NavPathStack') pageStack: NavPathStack;

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Center }) {
        Column() {
          Row() {
            Image($r('app.media.Back'))
              .width(40)
              .height(40)
              .margin({ right: 8 })
              .onClick(() => {
                this.pageStack.pop();
              })

            Text('Back')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
          }
          .width('100%')
          .height(56)
          .justifyContent(FlexAlign.Start)
        }
        .backgroundColor('#F1F3F5')
        .padding({
          left: 16,
          right: 16
        })
        .height('100%')
        .width('100%')
      }
      .height('100%')
      .width('100%')
    }
    .backgroundColor('#F1F3F5')
    .hideTitleBar(true)
  }
}
// [End CustomDialogNotDisappear_start]