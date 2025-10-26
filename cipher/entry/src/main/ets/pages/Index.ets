/*
 * Copyright (c) 2022-2023 Huawei Device Co., Ltd.
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

const TAG: string = '[Index]';

@Entry
@Component
struct Index {
  build() {
    Column() {
      Row() {
        Text($r('app.string.entry_MainAbility'))
          .fontSize(20)
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)
      }
      .height('6%')
      .width('100%')
      .padding({ left: 16 })
      .backgroundColor('#0D9FFB')
      .constraintSize({ minHeight: 50 })

      Stack({ alignContent: Alignment.Center }) {
        Column() {
          Button($r('app.string.encrypt'))
            .id('encrypt')
            .margin(10)
            .fontSize(20)
            .width('40%')
            .height('10%')
            .onClick(() => {
              this.getUIContext().getRouter().pushUrl({
                url: 'pages/Second',
                params: paramsInfo
              }).catch((err: BusinessError) => {
                hilog.error(0x0000, TAG, 'push url error: ' + err.code);
              });
            })

          Button($r('app.string.decrypt'))
            .id('decrypt')
            .margin(10)
            .fontSize(20)
            .width('40%')
            .height('10%')
            .onClick(() => {
              this.getUIContext().getRouter().pushUrl({
                url: 'pages/Second',
                params: {
                  flag: false
                }
              }).catch((err: BusinessError) => {
                hilog.error(0x0000, TAG, 'push url error: ' + err.code);
              });
            })
        }
      }
      .height('94%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F1F1')
  }
}

class DataModel {
  flag: boolean = true;
}

let paramsInfo: DataModel = {
  flag: true
};