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

@Component
export struct Information {
  build() {
    Column() {
      Text($r('app.string.product_info_title'))
        .fontSize(14)
        .fontWeight(500)
        .margin({ bottom: 8 })
      Text($r('app.string.product_info_content'))
        .fontSize(12)
        .fontColor('#CF0A2C')
        .margin({ bottom: 16 })
      Row() {
        Text($r('app.string.product_info_type'))
          .fontSize(12)
          .fontColor('#CF0A2C')
          .margin({ right: 4 })
        Text($r('app.string.product_info_des'))
          .fontSize(12)
        Blank()
        Image($r('app.media.arrow_right'))
          .width(8)
          .height(16)
          .opacity(0.4)
      }
      .padding({ left: 8, right: 8 })
      .borderRadius(14)
      .backgroundColor('#1ACF0A2C')
      .width('100%')
    }
    .width('100%')
    .backgroundColor(Color.White)
    .padding(12)
    .borderRadius(16)
    .margin({ top: 12, bottom: 12 })
  }
}
