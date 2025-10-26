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

/**
 *  最佳实践：点击响应优化
 */
import router from '@ohos.router';

@Entry
@Component
struct Index {
  build() {
    Column() {
      Row() {
        Image($r("app.media.ic_back"))
          .width(26).height(26)
          .fillColor('#99000000')
          .margin(10)
        Text('新建地址')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 20, top: 20 })
          .alignSelf(ItemAlign.Center)
          .textAlign(TextAlign.Center)
          .layoutWeight(1)

        Image($r('app.media.ic_public_search'))
          .width(26)
          .height(26)
          .fillColor('#99000000')
          .visibility(Visibility.Hidden)
          .margin(10)
      }
      .padding({ left: 5, right: 5 })

      Row() {
        Text("收货人    ")
          .fontWeight(FontWeight.Medium)
          .margin(24)
        Text("请填写收货人姓名").fontSize(15).fontColor(Color.Grey)
      }
      .margin({ top: 15 })

      Divider().height(1).color('#F1F3F5').opacity(0.8).margin({ left: 24, right: 24 })
      Row() {
        Text("手机号码")
          .fontWeight(FontWeight.Medium)
          .margin(24)
        Text("请填写收货人手机号码").fontSize(15).fontColor(Color.Grey)
      }

      Divider().height(1).color('#F1F3F5').opacity(0.8).margin({ left: 24, right: 24 })
      Row() {
        Text("所在地区")
          .fontWeight(FontWeight.Medium)
          .margin(24)
        Text("省市区县、乡镇等").fontSize(15).fontColor(Color.Grey)

        Button('选择')
          .onClick(() => {
            // hiTraceMeter.startTrace("clickCity", 1);
            this.getUIContext().getRouter().pushUrl({ url: "pages/CityListPage", params: { isAsync: false } })
          })
          .fontSize(12)
          .width(56)
          .backgroundColor(Color.Orange)
          .height(24)
          .stateEffect(true)
          .margin({ left: 15 })
          .visibility(Visibility.None)
        Button('选择')
          .onClick(() => {
            // hiTraceMeter.startTrace("clickCity", 1);
            this.getUIContext().getRouter().pushUrl({ url: "pages/CityListPage", params: { isAsync: true } })
          })
          .fontSize(12)
          .width(56)
          .height(24)
          .backgroundColor(Color.Orange)
          .stateEffect(true)
          .margin({ left: 5 })
          .visibility(Visibility.Visible)

      }

      Divider().height(1).color('#F1F3F5').opacity(0.8).margin({ left: 24, right: 24 })
      Row() {
        Text("详细地址")
          .fontWeight(FontWeight.Medium)
          .margin(24)
        Text("街道、楼牌号等").fontSize(15).fontColor(Color.Grey)
      }

      Divider().height(1).color('#F1F3F5').opacity(0.8).margin({ left: 24, right: 24, top: 40 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
  }
}