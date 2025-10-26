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

@Entry
@Component
struct Index {
  @Provide('NavPathStack') pageStack: NavPathStack = new NavPathStack();

  build() {
    Navigation(this.pageStack) {
      Column() {
        Column() {
          Text($r('app.string.pick_up'))
            .fontColor(Color.White)
            .fontSize(19)
            .fontWeight(FontWeight.Bold)
            .lineHeight(25)
            .margin({
              top: '7%',
            })
            .textAlign(TextAlign.Center)

          Column() {
            Text($r('app.string.location'))
              .fontColor(Color.White)
              .fontSize(18)
              .fontWeight(FontWeight.Regular)
          }
          .height('90%')
          .justifyContent(FlexAlign.Center)
        }
        .height('55%')

        Row() {
          Column() {
            Image($r('app.media.home'))
              .width(52)
              .height(52)

            Text($r('app.string.go_home'))
              .fontColor(Color.White)
              .fontWeight(FontWeight.Medium)
              .fontSize(15)
              .height(26)
          }
          .onClick(() => {
            this.pageStack.pushPath({ name: 'FindCar' });
          })

          Column() {
            Image($r('app.media.company'))
              .width(52)
              .height(52)

            Text($r('app.string.go_to_company'))
              .fontColor(Color.White)
              .fontWeight(FontWeight.Medium)
              .fontSize(15)
              .height(26)
          }
          .onClick(() => {
            this.pageStack.pushPath({ name: 'FindCar' });
          })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('65%')
      }
      .height('100%')
      .width('100%')
      .borderRadius('50%')
      .backgroundColor(Color.Black)
    }
    .mode(NavigationMode.Stack)
    .height('100%')
    .width('100%')
    .hideToolBar(true)
    .hideTitleBar(true)
    .hideBackButton(true)
  }
}