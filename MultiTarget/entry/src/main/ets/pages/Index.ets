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
import { MainPage } from 'myhar'
import { getName, getTitleName } from 'entry/VersionInfo'

@Entry
@Component
struct Index {
  @State message: string = getName();
  @State titleMessage: Resource = getTitleName();

  build() {
    Column() {
      Column() {
        Text(this.titleMessage)
          .height(40)
          .fontSize(30)
          .fontWeight(FontWeight.Medium)
        Text(this.message)
          .fontSize(14)
          .fontWeight(FontWeight.Normal)
          .fontColor(Color.Black)
          .opacity(0.6)
          .height(19)
          .margin({ top: 2 })
      }
      .height(78)
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({
        left: 12,
        right: 12,
        top: 8,
        bottom: 12
      })

      Row() {
        MainPage()
          .backgroundColor('#F1F3F5')
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}