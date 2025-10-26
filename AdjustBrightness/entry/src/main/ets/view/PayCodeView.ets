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

import Constants from '../commom/Constants';

@ComponentV2
export default struct PayCodeView {
  private qrCodeValue: string = 'test_QR_code'; // Scan result

  build() {
    Column() {
      Text($r('app.string.user_name'))
        .width(Constants.FULL_PERCENT)
        .margin({ left: 40, right: 40, top: 32 })
        .textAlign(TextAlign.Center)
        .fontSize(20)
        .fontWeight(500)
        .lineHeight(27)

      Stack() {
        QRCode(this.qrCodeValue)
          .width(208)
          .aspectRatio(1)
        Image($r('app.media.ic_comm_pic1'))
          .width(56)
          .aspectRatio(1)
          .borderRadius(28)
      }
      .width(240)
      .aspectRatio(1)
      .borderRadius(12)
      .backgroundColor(Color.White)
      .margin({ top: 16 })

      Row() {
        Text($r('app.string.set_money'))
          .width(136)
          .fontSize(14)
          .fontWeight(500)
          .lineHeight(19)
          .textAlign(TextAlign.Center)
          .fontColor('#0A59F7')
          .margin({ left: 8 })
        Row()
          .width(0.5)
          .height(24)
          .backgroundColor('#0D000000')
          .margin({ left: 8 })
        Text($r('app.string.save_image'))
          .width(136)
          .fontSize(14)
          .fontWeight(500)
          .lineHeight(19)
          .textAlign(TextAlign.Center)
          .fontColor('#0A59F7')
          .margin({ left: 8 })
      }
      .width(304)
      .margin({ top: 12 })
      .height(40)

      Column()
        .width(296)
        .height(0.5)
        .backgroundColor('#0D000000')
        .margin({ top: 13.5 })

      Row() {
        Text($r('app.string.save_money'))
          .width(192)
          .fontSize(16)
          .fontWeight(400)
          .lineHeight(21)
          .textAlign(TextAlign.Start)
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(24)
          .fontColor(['#4D000000'])
          .margin({ left: 100 })
      }
      .alignItems(VerticalAlign.Center)
      .width(304)
      .height(48)
    }
    .width(Constants.FULL_PERCENT)
    .height(437)
    .margin({ top: 8 })
    .backgroundColor('#FAFAFA')
    .borderRadius(16)
  }
}