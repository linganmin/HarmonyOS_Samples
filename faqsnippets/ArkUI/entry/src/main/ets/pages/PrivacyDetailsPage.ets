/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

/*
* FAQ:如何使当前页面弹窗在页面跳转返回之后还存在(隐私详情页场景)
*/

// [Start dialog_jump_retained]
@Component
struct DialogJumpRetained {
  @State visible: Visibility = Visibility.None;

  build() {
    Stack() {
      Row() {
        Column() {
          Text('Hello World')
            .fontSize(50)
            .fontWeight(FontWeight.Bold)
          Button('click')
            .onClick(() => {
              if (this.visible === Visibility.Visible) {
                this.visible = Visibility.None;
              } else {
                this.visible = Visibility.Visible;
              }
            })
            .backgroundColor(0x777474)
            .fontColor(0x000000)
        }
        .width('100%')
      }
      .height('100%')
      .backgroundColor(Color.Orange)

      Text('')
        .onClick(() => {
          if (this.visible == Visibility.Visible) {
            this.visible = Visibility.None;
          } else {
            this.visible = Visibility.Visible;
          }
        })
        .width('100%')
        .height('100%')
        .opacity(0.5)
        .backgroundColor(0x000000)
        .visibility(this.visible)
      Column() {
        GridRow({
          columns: {
            xs: 1,
            sm: 4,
            md: 8,
            lg: 12
          },
          breakpoints: {
            value: ['400vp', '600vp', '800vp'],
            reference: BreakpointsReference.WindowSize
          }
        }) {
          GridCol({
            span: {
              xs: 1,
              sm: 2,
              md: 4,
              lg: 8
            },
            offset: {
              xs: 0,
              sm: 1,
              md: 2,
              lg: 2
            }
          }) {
            Column() {
              Text('Privacy Dialog')
                .fontSize(20)
                .margin({
                  top: 10,
                  bottom: 10
                })
              Text('View privacy details?')
                .fontSize(16)
                .margin({ bottom: 10 })
              Flex({ justifyContent: FlexAlign.SpaceAround }) {
                Button('Close Dialog')
                  .onClick(() => {
                    if (this.visible === Visibility.Visible) {
                      this.visible = Visibility.None;
                    } else {
                      this.visible = Visibility.Visible;
                    }
                  }).backgroundColor(0xffffff).fontColor(Color.Black)
                Button('Go to Details')
                  .onClick(() => {
                    this.getUIContext().getRouter().pushUrl({
                      url: 'pages/Second'
                    });
                  })
                  .backgroundColor(0xffffff)
                  .fontColor(Color.Red)
              }
              .margin({ bottom: 10 })
            }
            .backgroundColor(0xffffff)
            .visibility(this.visible)
            .clip(true)
            .borderRadius(20)
          }
        }
      }
      .width('95%')
    }
  }
}
// [End dialog_jump_retained]

// [Start second]
@Entry
@Component
struct Second {
  @State message: string = 'Privacy Details Page';
  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
        Button('Back').onClick(() => {
          this.getUIContext().getRouter().back({
            url: 'pages/DialogJumpRetained'
          });
        })
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End second]