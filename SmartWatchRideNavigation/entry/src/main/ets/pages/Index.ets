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
  pathStack: NavPathStack = new NavPathStack();

  build() {
    Navigation(this.pathStack) {
      Column() {
        Text($r('app.string.scan_QRCode_login'))
          .font({
            size: 19,
            weight: 700
          })
          .fontColor($r('sys.color.white'))
          .margin({ top: 17 })

        Image($r('app.media.QRCode'))
          .width(120)
          .height(120)
          .backgroundColor($r('sys.color.white'))
          .borderRadius(6)
          .margin({ top: 15 })

        Text($r('app.string.please_scan_QRCode_login'))
          .fontColor(Color.White)
          .font({
            size: 18,
            weight: 500
          })
          .margin({ top: 10 })
      }
      .onClick(() => {
        this.pathStack.pushPathByName('SearchPage', null);
      })
      .height('100%')
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Center)
    }
    .backgroundColor(Color.Black)
    .hideTitleBar(true)
    .hideToolBar(true)
    .height('100%')
    .width('100%')
    .borderRadius('50%')
  }
}