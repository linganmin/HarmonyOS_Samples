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

@Component
export struct Mine {
  @Consume('navPathStack') navPathStack: NavPathStack;

  build() {
    Column() {
      Text($r('app.string.my_account'))
        .height(40)
        .fontColor($r('app.color.font_color'))
        .fontSize(30)
        .fontWeight(700)
        .lineHeight(40)
      Row() {
        Image($r('app.media.circle'))
          .width(40)
          .height(40)
          .borderRadius(20)
        Column() {
          Text($r('app.string.xiaoyi'))
            .fontColor($r('app.color.font_color'))
            .fontSize(16)
            .fontWeight(500)
            .lineHeight(22)
          Text('123456789')
            .fontColor($r('app.color.sub_text_color'))
            .fontSize(14)
            .fontWeight(400)
            .lineHeight(18)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 12 })

        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(24)
          .fontColor([$r('app.color.arrow_color')])

      }
      .width('100%')
      .height(80)
      .borderRadius(16)
      .backgroundColor($r('app.color.item_box'))
      .padding(12)
      .margin({ top: 20, bottom: 12 })

      Row() {
        Text($r('app.string.dark_mode'))
          .fontColor($r('app.color.font_color'))
          .fontSize(16)
          .fontWeight(500)
          .lineHeight(22)
        Row() {
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontSize(24)
            .fontColor([$r('app.color.arrow_color')])
        }
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height(56)
      .padding(12)
      .borderRadius(16)
      .backgroundColor($r('app.color.item_box'))
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(() => {
        this.navPathStack.pushPathByName('darkModeSetting', null)
      })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 16, right: 16, top: 64 })
  }
}