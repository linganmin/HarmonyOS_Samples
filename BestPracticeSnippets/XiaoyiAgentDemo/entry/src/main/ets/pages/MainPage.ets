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
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct HelloWorldPage {
  @State message: string = 'First Page';

  // Jump to the second page
  private navigateToSecond() {
    this.getUIContext().getRouter().pushUrl({ url: 'pages/SecondPage' })
      .then(() => {
        hilog.info(0x000, 'testTag', `pushUrl success`);
      })
      .catch((error: BusinessError) => {
        hilog.error(0x000, 'testTag', `pushUrl failed. code=${error.code}, message=${error.message}`);
      })
  }

  build() {
    Column() {
      Text(this.message)
        .fontSize(30)
        .fontWeight('bold')
        .fontColor('#333333')

      Text($r('app.string.title'))
        .margin({ top: 30 })

      Column() {
        Text($r('app.string.text1'))
          .margin({ top: 10 })
        Text($r('app.string.text2'))
          .margin({ top: 10 })
        Text($r('app.string.text3'))
          .margin({ top: 10 })
      }

      // Add a bottom jump button (more prominent)
      Button($r('app.string.button'), { type: ButtonType.Capsule })
        .width('80%')
        .height(50)
        .margin({ top: 30, bottom: 20 })
        .backgroundColor('#409EFF')
        .fontColor(Color.White)
        .fontSize(18)
        .onClick(() => this.navigateToSecond())
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}