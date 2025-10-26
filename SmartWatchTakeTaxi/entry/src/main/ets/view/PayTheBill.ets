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
export function PayTheBillBuilder() {
  PayTheBill();
}

@Entry
@Component
struct PayTheBill {
  @Consume('NavPathStack') pageStack: NavPathStack;

  build() {
    NavDestination() {
      Column() {
        Column() {
          Text($r('app.string.pay_success'))
            .fontSize(19)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .width(129)
            .height('11%')
            .lineHeight(27)
            .margin({
              top: '7%'
            })
            .textAlign(TextAlign.Center)
          Column() {
            Text() {
              Span($r('app.string.pay_the_bill1'))
                .fontColor(Color.Gray)
                .fontWeight(FontWeight.Regular)
                .fontSize(18)
              Span($r('app.string.pay_the_bill2'))
                .fontColor(Color.White)
                .fontWeight(FontWeight.Regular)
                .fontSize(24)
              Span($r('app.string.pay_the_bill3'))
                .fontColor(Color.Gray)
                .fontWeight(FontWeight.Regular)
                .fontSize(18)
            }
            .height(32)

            Text($r('app.string.thanks_for_use'))
              .fontColor(Color.Gray)
              .fontWeight(FontWeight.Regular)
              .fontSize(18)
              .height(32)
          }
          .justifyContent(FlexAlign.Center)
          .height('80%')
        }
        .height('80%')


        Stack({ alignContent: Alignment.Top }) {
          Circle({
            width: 500,
            height: 500
          })
            .fill('#1F71FF')
          Text($r('app.string.i_know'))
            .fontSize(19)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
            .margin({
              top: 12
            })
        }
        .onClick(() => {
          this.pageStack.pop();
        })
      }
      .height('100%')
      .width('100%')
      .borderRadius('50%')
      .backgroundColor(Color.Black)
      .justifyContent(FlexAlign.Center)
    }
    .hideTitleBar(true)
  }
}