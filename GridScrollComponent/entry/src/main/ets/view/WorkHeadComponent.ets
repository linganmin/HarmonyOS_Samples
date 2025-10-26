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

@Component
export default struct WorkHeadComponent {
  build() {
    Column() {
      Row({ space: 30 }) {
        Image($r('app.media.album_photo4'))
          .width(40)
          .height(40)
          .borderRadius(20)
          .borderColor(Color.White)
          .borderWidth(1)

        Column({ space: 4 }) {
          Text(" ")
            .fontSize(15)
            .width(60)
            .height(15)
            .opacity(0.8)
            .borderRadius(8)
            .backgroundColor('#ffd4d4d4')

          Text(" ")
            .fontSize(10)
            .width(90)
            .height(10)
            .opacity(0.4)
            .borderRadius(5)
            .backgroundColor('#ffb1afaf')
        }
        .alignItems(HorizontalAlign.Start)

        Row()
          .width('100%')
          .layoutWeight(1)

        Row({ space: 15 }) {
          SymbolGlyph($r('sys.symbol.magnifyingglass'))
            .fontSize(20)
            .fontColor([Color.White])
          SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
            .fontSize(20)
            .fontColor([Color.White])
        }
        .alignSelf(ItemAlign.Start)
      }
      .height(150)
      .alignSelf(ItemAlign.Start)
      .padding({
        top: 20,
        left: 20,
        right: 10,
        bottom: 10
      })

      Column() {
        Row({ space: 30 }) {
          Text() {
            Span('13 ')
              .fontWeight(FontWeight.Bold)
            Span($r('app.string.likes'))
              .fontColor(Color.Gray)
          }
          .fontSize(15)

          Text() {
            Span('46 ')
              .fontWeight(FontWeight.Bold)
            Span($r('app.string.watcher'))
              .fontColor(Color.Gray)
          }
          .fontSize(15)

          Text() {
            Span('30 ')
              .fontWeight(FontWeight.Bold)
            Span($r('app.string.fans'))
              .fontColor(Color.Gray)
          }
          .fontSize(15)
        }
        .justifyContent(FlexAlign.Start)
        .width('100%')

        Row() {
          Text(' ')
            .fontSize(15)
            .width(200)
            .borderRadius(8)
            .backgroundColor('#ffe7e5e5')

          Text() {
            SymbolSpan($r('sys.symbol.square_and_pencil'))
              .fontSize(15)
          }
        }
        .width('100%')
        .margin({
          top: 20
        })
      }
      .backgroundColor(Color.White)
      .width('100%')
      .borderRadius({
        topLeft: 10,
        topRight: 10
      })
      .padding({
        top: 10,
        left: 10,
        bottom: 10
      })
    }
  }
}