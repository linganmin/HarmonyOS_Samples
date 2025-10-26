/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
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

@Component
export struct ToolBar {
  @State icons: Resource[] = [
    $r('app.media.home'),
    $r('app.media.message'),
    $r('app.media.bag')
  ];
  @State isShow: boolean = false;
  @State sheetHeight: number = 538;
  @Consume navPathStack: NavPathStack;

  @Builder
  paymentSheet() {
    Column() {
      Column() {
        Text($r('app.string.huawei_traffic_card'))
          .fontColor($r('app.color.color13'))
          .fontFamily('鸿蒙黑体')
          .fontSize(12)
          .fontWeight(400)
          .lineHeight(16)
          .margin({ top: 15.01 })
        Text($r('app.string.price'))
          .fontColor($r('app.color.color11'))
          .fontFamily('鸿蒙黑体')
          .fontSize(38)
          .fontWeight(500)
          .lineHeight(16)
        Row() {
          List() {
            ListItem() {
              Row() {
                Row() {
                  Image($r('app.media.ic_appicon_wallet'))
                    .width(32)
                    .height(32)
                    .margin({ right: 12 })
                  Text($r('app.string.huawei_wallet_payment'))
                    .fontColor($r('app.color.color11'))
                    .fontFamily('鸿蒙黑体')
                    .fontSize(16)
                    .fontWeight(500)
                    .lineHeight(21)
                }

                Radio({ value: 'checked', group: 'radioGroup' }).checked(true)
              }
              .justifyContent(FlexAlign.SpaceBetween)
              .width('100%')
            }
            .height(56)
            .padding({ left: 8, right: 12 })

            ListItem() {
              Row() {
                Text($r('app.string.no_more_items'))
                  .fontColor($r('app.color.color13'))
                  .fontFamily('鸿蒙黑体')
                  .fontSize(12)
                  .fontWeight(400)
                  .lineHeight(16)
              }
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Center)
              .width('100%')
            }
            .height(40)
          }
          .width('100%')
          .height('100%')
          .divider({
            strokeWidth: 1,
            color: $r('app.color.color7'),
            startMargin: 52,
            endMargin: 12
          })
        }
        .width('100%')
        .height(100)
        .borderRadius(16)
        .backgroundColor(Color.White)
      }
      .height(233)
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 56.99 })

      Button($r('app.string.confirm_payment'))
        .width('100%')
        .fontColor(Color.White)
        .fontSize(16)
        .fontWeight(500)
        .backgroundColor($r('app.color.color2'))
        .margin({ bottom: 56 })
        .onClick(() => {
          this.isShow = false;
          this.navPathStack.pushPathByName('PaymentSuccess', null);
        })

    }
    .width('100%')
    .height(538)
    .borderRadius({ topLeft: 24, topRight: 24 })
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('app.color.color1'))
    .padding({ left: 16, right: 16 })
  }

  build() {
    Row() {
      Row() {
        ForEach(this.icons, (icon: Resource) => {
          Column() {
            Image(icon)
              .width(24)
              .height(24)
          }
          .width(40)
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }, (icon: Resource, index: number) => JSON.stringify(icon) + index)
      }
      .width(120)
      .height('100%')

      Row() {
        Button($r('app.string.add_to_cart'))
          .width(112)
          .height('100%')
          .borderRadius(20)
          .backgroundColor($r('app.color.color7'))
          .fontColor($r('app.color.color2'))
          .fontFamily('鸿蒙黑体')
          .fontSize(16)
          .fontWeight(500)
          .margin({ right: 12 })

        Button($r('app.string.buy'))
          .width(64)
          .height('100%')
          .borderRadius(20)
          .backgroundColor($r('app.color.color2'))
          .fontColor(Color.White)
          .fontFamily('鸿蒙黑体')
          .fontSize(16)
          .fontWeight(500)
          .onClick(() => {
            this.isShow = true;
          })
          .bindSheet($$this.isShow, this.paymentSheet(), {
            height: this.sheetHeight
          })
      }
    }    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .padding({
      top: 8,
      bottom: 8,
      left: 16,
      right: 16
    })
    .width('100%')
    .height(56)
    .backgroundColor($r('app.color.color1'))
  }
}