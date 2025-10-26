/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

// [Start gestures_conflict_scene5]
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct GesturesConflictScene5 {
  @State message: string = 'Hello World';

  build() {
    Column() {
      Row({ space: 20 }) {
        Button('Button1')
          .width(100)
          .height(40)
          .monopolizeEvents(true)
        Button('Button2')
          .width(200)
          .height(50)
          .onClick(() => {
              try {
                this.getUIContext().getPromptAction().showToast({ message: 'GesturesConflictScene5 Button2 click' });
              } catch (err) {
                let error = err as BusinessError;
                hilog.error(0x0000, 'testTag', `showToast err, code: ${error.code}, mesage: ${error.message}`);
              }
          })
      }
      .margin(20)

      Text(this.message)
        .margin(15)
    }
    .width('100%')
    .gesture(
      TapGesture({ count: 1 })
        .onAction(() => {
          console.info('GesturesConflictScene5 TapGesture onAction.');
        }),
    )
  }
}

// [End gestures_conflict_scene5]