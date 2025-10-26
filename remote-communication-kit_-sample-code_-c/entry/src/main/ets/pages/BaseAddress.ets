/*
 * Copyright (c) 2024-2025 Huawei Device Co., Ltd.
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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import rcpSdk from 'libentry.so';

const kHttpServerAddress = "https://httpbin.org";

@Entry
@Component
struct requestContent {
  @State content: string = ''

  build() {
    Flex({ direction: FlexDirection.Column }) {
      Row() {
        Text('BaseAddress')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ff100f0f')
          .height(30)
          .width(220)
          .margin({ left: 4 })
      }
      .height(32)
      .width(124)
      .margin({ top: 32, left: 12 })

      Divider().color('gray').strokeWidth(1)

      Flex({
        direction: FlexDirection.Column,
        justifyContent: FlexAlign.SpaceBetween
      }) {
        Button('baseAddress-test')
          .width('80%')
          .height(40)
          .margin({ left: '10%' })
          .backgroundColor('#0A59F7')
          .fontColor(Color.White)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .borderRadius(20)
          .onClick(this.getTokenSyn)
      }
      .height(64)
      .margin({ top: 86 })

      Text("result")
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#000')
        .height(30)
        .width(220)
        .margin({ left: 8 })
      TextArea({
        text: this.content
      })
        .width('80%')
        .height(260)
        .margin({ left: '10%', top: '10%' })
        .backgroundColor('0x317aff')
        .fontColor('#ff100f0f')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .borderRadius(10)
    }
    .linearGradient({
      direction: GradientDirection.Top,
      repeating: true,
      colors: [['#FFFFFF', 0], ['#FFFFFF', 1]]
    })
    .height('100%')
    .width('100%')
  }

  private getTokenSyn = async () => {
    try {
      let res = rcpSdk.Get(kHttpServerAddress)
      this.content = `${kHttpServerAddress} 传递成功`
      hilog.info(0x0000, 'testTag', 'rcp sdk Get result: %{public}s', res)
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      hilog.error(0x0000, 'testTag', 'Get push token catch error: %{public}d %{public}s', e.code, e.message);
      console.error(`${kHttpServerAddress} 传递失败` + JSON.stringify(err))
      this.content = `${kHttpServerAddress} 传递失败` + JSON.stringify(err)
    }
  }
}