/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 ("the License");
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

import { PRODUCT_LABELS } from '../../constants/Detail';

@Component
export struct Discount {
  build() {
    Column() {
      Row() {
        Text('￥12999')
          .fontSize(22)
          .fontWeight(500)
          .fontColor(Color.White)
        Text('￥13999')
          .fontSize(12)
          .opacity(0.6)
          .fontColor(Color.White)
          .decoration({
            type: TextDecorationType.LineThrough,
            color: Color.White
          })
          .lineHeight(20)
        Blank()
        Text($r('app.string.discount_time'))
          .fontSize(9)
          .fontColor(Color.White)
      }
      .width('100%')
      .height(54)
      .padding({ left: 8, right: 8 })
      .borderRadius(8)
      .linearGradient({
        direction: GradientDirection.Right,
        repeating: false,
        colors: [['#FF6354', 0.0], ['#CF0A2C', 1.0]]
      })
      Row() {
        Text($r('app.string.discount_info'))
          .fontSize(12)
          .opacity(0.6)
        Blank()
        Image($r('app.media.arrow_right'))
          .width(8)
          .height(16)
          .opacity(0.4)
      }
      .width('100%')
      .margin({ top: 8, bottom: 8 })
      Row() {
        ForEach(PRODUCT_LABELS, (label: string) => {
          Text(label)
            .height(17)
            .fontSize(10)
            .fontColor('#CF0A2C')
            .opacity(0.6)
            .borderRadius(4)
            .borderColor('#CF0A2C')
            .borderWidth(0.5)
            .padding({ left: 6, right: 6 })
            .margin({ right: 4 })
            .linearGradient({
              direction: GradientDirection.Right,
              repeating: false,
              colors: [['#FAE8E0', 0.0], ['#FFC9C9', 1.0]]
            })
        }, (label: string) => label)
        Blank()
        Text($r('app.string.discount_button_text'))
          .fontColor(Color.White)
          .fontSize(12)
          .width(50)
          .borderRadius(14)
          .height(20)
          .backgroundColor('#B3CF0A2C')
          .textAlign(TextAlign.Center)
      }
      .width('100%')
    }
    .width('100%')
    .backgroundColor(Color.White)
    .padding(12)
    .borderRadius(16)
  }
}
