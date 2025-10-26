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

import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from '../utils/Logger';

const TAG: string = 'PickerPage';

@Entry
@Component
struct Index {
  @State testCaseSteps: number = 0;
  @State showProgressBar: boolean = false;
  @State errCount: number = 0;
  @State totalCount: number = 0;
  uiContext = this.getUIContext()

  build() {
    Row() {
      Column() {
        Button('视频处理', { type: ButtonType.Normal, stateEffect: true })
          .borderRadius(10)
          .onClick(() => {
            Logger.info(TAG, 'Picker init VideoPage ')
            this.uiContext.getRouter()
              .pushUrl({
                url: 'pages/VideoPage',
              }, router.RouterMode.Standard)
              .then(() => {
                Logger.info(TAG, 'pushUrl success');
              })
              .catch((err: BusinessError) => {
                Logger.warn(TAG, `pushUrl failed, code=${err.code}, message=${err.message}`)
              })
          })
          .margin('30')
        if (this.showProgressBar) {
          Progress({ value: 0, total: 100, type: ProgressType.Linear })
            .value(this.testCaseSteps)
            .width('80%');
          //Text(this.testCase.finishedTestcaseNum + ' / ' + this.testCase.totalTestcaseNum).margin(10)
          Text(this.errCount + ' fail').fontColor(Color.Red)
          Text(this.totalCount + ' pass').fontColor(Color.Green)
        }
      }
      .width('100%')
    }
    .height('100%')
  }
}

