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

// [Start get_str_of_id]
import { hilog, hiTraceMeter } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct GetStrOfId {
  @State message: string = 'getStringSyncAfter';

  aboutToAppear(): void {
    hiTraceMeter.startTrace('getStringSyncAfter', 1);
    // The input parameter of the getStringSync operation directly uses the resource and does use the resource ID
    try {
      this.getUIContext().getHostContext()!.resourceManager.getStringSync($r('app.string.test').id)
    } catch (error) {
      hilog.error(0x0000,'',`getStringSync failed. code=${error.code}, message=${error.message}`);
    }
    hiTraceMeter.finishTrace('getStringSyncAfter', 1)
  }

  build() {
    Column() {
      Row({ space: 5 }) {
        Column() {
          Image($r('app.media.chevron_left'))
            .width(16)
            .height(16)
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#E8E8E8')
        .borderRadius(40)
        .onClick(() => {
          this.getUIContext().getRouter().back({
            url: 'pages/Index'
          });
        })

        Text($r('app.string.get_str_of_id'))
          .fontSize(20)
          .fontWeight(700)
          .height(26)
      }
      .width('100%')
      .height(56)
      .margin({ top: 20 })

      TextArea({ text: this.message })
        .height('40%')
    }
    .height('100%')
    .width('100%')
    .padding(16)
    .backgroundColor('#F5F5F5')
  }
}

// [End get_str_of_id]