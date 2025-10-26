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
export struct CustomListItem {
  @State title: string | ResourceStr = '';
  @State imgUrl: string | ResourceStr = '';

  build() {
    Column() {
      Row() {
        Image(this.imgUrl)
          .width(40)
          .height(40)
          .borderRadius(20)
          .margin({ right: 8 })
        Column() {
          Text($r('app.string.security'))
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
          Text('12-21 12:00')
            .fontSize(12)
            .fontColor(Color.Black)
            .opacity(0.6)
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Text(this.title)
        .width('100%')
        .fontSize(12)
        .fontColor(Color.Black)
        .opacity(0.6)
        .margin({ top: 12, bottom: 12 })
      Row() {
        Image(this.imgUrl)
          .width('32%')
          .height(72)
          .borderRadius(12)
        Image(this.imgUrl)
          .width('32%')
          .height(72)
          .borderRadius(12)
        Image(this.imgUrl)
          .width('32%')
          .height(72)
          .borderRadius(12)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding(12)
    .borderRadius(16)
    .backgroundColor(Color.White)
  }
}