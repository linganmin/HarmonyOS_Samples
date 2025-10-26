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

import fraudRiskDetectModel from '../model/FraudRiskDetectModel';
import simulatedClickRiskDetectModel from '../model/SimulatedClickRiskDetectModel';

@Entry
@Component
struct Index {
  @State DisplayText: string = '';

  build() {
    Column() {
      Text('BusinessRiskIntelligentDetection')
        .width('100%')
        .height(100)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ left: '30vp' })

      Column() {
        Text($r('app.string.Display_content'))
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
          .margin({ top: '30vp', left: '24vp', bottom: '9.5vp' })
      }
      .width('100%')
      .height('60vp')
      .alignItems(HorizontalAlign.Start)

      Column() {
        Column() {
          Scroll() {
            Text(this.DisplayText)
              .fontColor($r('sys.color.font_primary'))
              .fontSize($r('sys.float.ohos_id_text_size_body1'))
              .lineHeight('19vp')
              .textAlign(TextAlign.Start)
              .width('100%')
          }
          .margin({
            top: '8vp',
            left: '16vp',
            right: '16vp',
            bottom: '21vp'
          })
        }
        .height('350vp')
        .backgroundColor($r('sys.color.comp_background_list_card'))
        .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
        .margin({ left: '12vp', right: '12vp' })
        .align(Alignment.TopStart)
      }
      .width('100%')
      .height('139vp')
      .alignItems(HorizontalAlign.Center)

      Row() {
        Button('FraudRiskDetect', { type: ButtonType.Capsule, stateEffect: true })
          .borderRadius(8)
          .backgroundColor(0x317aff)
          .width('40%')
          .height('7%')
          .margin({
            top: '10vp',
            left: '16vp',
            right: '16vp',
            bottom: '21vp'
          })
          .onClick(() => {
            fraudRiskDetectModel.fraudRiskDetect((result: string) => {
              this.DisplayText = result;
            })
          })
        Button('SimulatedClickRiskDetect', { type: ButtonType.Capsule, stateEffect: true })
          .borderRadius(8)
          .backgroundColor(0x317aff)
          .width('40%')
          .height('7%')
          .margin({
            top: '10vp',
            left: '16vp',
            right: '16vp',
            bottom: '21vp'
          })
          .onClick(() => {
            simulatedClickRiskDetectModel.simulatedClickRiskDetect((result: string) => {
              this.DisplayText = result;
            })
          })
      }
      .height('600vp')
      .width('100%')
    }
    .height('100%')
    .backgroundColor($r('app.color.window_background'))
  }
}